//
//  AppDelegate.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import NotificationCenter
import UserNotifications
import FirebaseDynamicLinks
import SafariServices
import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate, URLSessionTaskDelegate, MessagingDelegate {

    var window: UIWindow?
    
    typealias CompletionHandler = () -> Void
    
    var completionHandlers = [String: CompletionHandler]()
    
    var sessions = [String: URLSession]()
    
    var tryCount = 0
    
    var safariVC: SFSafariViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBVFiHug5zvdGH0l9-FaXVFqlMdEJjfdw0")

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        Messaging.messaging().isAutoInitEnabled = true
        
        UserDefaults.standard.register(defaults: [
                "tutorialShown": false
                ])
        
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        
        if let lastLogin = UserDefaults.standard.object(forKey: "lastLoginDate") {
            
            let formater = DateFormatter()
            formater.dateFormat = "dd.MM.yyyy HH:mm"
            let lastDate = formater .date(from: lastLogin as! String)
            let nowDate = Date()
            let diff: TimeInterval = nowDate.timeIntervalSince(lastDate!)/60;
            
            if (diff > 30) {
                loginSavedUser()
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissSplashLoader"), object: nil)
            }
            
        } else {
            loginSavedUser()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Utils.cleanupUserDefaultsForPushNotifications()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let sf = safariVC {
            sf.dismiss(animated: true, completion: nil)
        }

        if url.absoluteString.contains("swish/complete") {
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "swishComplete")))
            
            Analytics.logEvent("swish_complete", parameters: [
                "userInfo": "completed" as NSObject
            ])
        }
        
        return true
    }

    func loginSavedUser() {
        
        if UserDefaults.standard.object(forKey: "authToken") != nil {
            let username = UserDefaults.standard.object(forKey: "email") as! String
            let password = UserDefaults.standard.object(forKey: "password") as! String
            let timezone = TimeZone.current.identifier
            let country = Utils.getCountryCodeBySim()
            let locale = LanguageManager.sharedInstance.getStringForKey(key: "locale")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "presentSplashLoader"), object: nil)
            ServerManager.sharedInstance.login(username: username,
                                               password: password,
                                               timezone: timezone,
                                               country: country ?? "",
                                               locale: locale) { (response, success, error) in
                
                if success! {

                    if let jwt = response["jwt"] as? String, let userDict = response["user"] as? NSDictionary {
                        
                        let formater = DateFormatter()
                        formater.dateFormat = "dd.MM.yyyy HH:mm"
                        UserDefaults.standard.set(formater.string(from: Date()), forKey: "lastLoginDate")
                        
                        if let infoDict = response["prices"] as? NSDictionary {
                            DataManager.sharedInstance.prices = PricesModel(dict: infoDict)
                        }
                        
                        ServerManager.sharedInstance.addDevice()

                        UserDefaults.standard.set(jwt, forKey: "authToken")
                        DataManager.sharedInstance.loggedUser = UserModel.init(dict: userDict)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissSplashLoader"), object: nil)

                    } else {
                        if self.tryCount < 3 {
                            self.tryCount += 1
                            self.loginSavedUser()
                            
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissSplashLoader"), object: nil)
                        }
                    }
                    
                } else {
                    Utils.cleanupLocalStorage()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissSplashLoader"), object: nil)
                }
            }
        }
    }
    
    func upload(request: NSURLRequest, data: NSData) {
        // Create a unique identifier for the session.
        let sessionIdentifier = NSUUID().uuidString
        
        let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = directoryURL.appendingPathComponent(sessionIdentifier)
        
        // Write data to cache file.
        data.write(to: fileURL, atomically: true);
        
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        
        let session: URLSession = URLSession(
            configuration:configuration,
            delegate: self,
            delegateQueue: OperationQueue.main
        )
        
        // Store the session, so that we don't recreate it if app resumes from suspend.
        sessions[sessionIdentifier] = session
        
        let task = session.uploadTask(with: request as URLRequest, fromFile: fileURL)
        
        task.resume()
    }
    
    // Called when the app becomes active, if an upload completed while the app was in the background.
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping CompletionHandler) {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        
        if sessions[identifier] == nil {
            
            let session = URLSession(
                configuration: configuration,
                delegate: self,
                delegateQueue: OperationQueue.main
            )
            
            sessions[identifier] = session
        }
        
        completionHandlers[identifier] = completionHandler
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("finished")
    }
    
    //MARK: - Push Notifications
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
    
    private func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UserDefaults.standard.set(true, forKey: "openNotificationOnWakeUp")
        UserDefaults.standard.set(userInfo, forKey: "notificationUserInfo")
        
        switch application.applicationState {
        case .active:
            Utils.addNotificationCount()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushNotificationReceived"), object: nil, userInfo: userInfo)
            break
            
        case .background, .inactive:
            UserDefaults.standard.set(true, forKey: "openNotificationDidLaunch")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openNotifications"), object: nil, userInfo: nil)
            break
            
        default:
            break
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }

    //MARK: - Firebase Dyinamic Link
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            
            guard let url = dynamicLink.url?.absoluteString else { return false }
            
            if url.contains("job") {
                guard let jobId = url.components(separatedBy: "/").last else { return false }
                print("test id from deep link \(jobId)")
            }
            
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return false }
        
        return handleIncomingDynamicLink(url, self.window!)
    }
}

private func handleIncomingDynamicLink(_ url: URL, _ window: UIWindow) -> Bool {
    let jobOffer = OfferModel()
    let storyboard: UIStoryboard = UIStoryboard(name:"JobOffer", bundle: nil)

    let isDynamicLinkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
             guard error == nil,
             let dynamicLink = dynamicLink,
             let jobId = dynamicLink.url?.lastPathComponent else { return }
             jobOffer.id = Int(jobId)!
        
        ServerManager.sharedInstance.getJobById(id: Int(jobId)!) { (response, success, message) in
            if success! {
                let jobOffer = OfferModel.init(dict: response)
                guard let newJobOfferVC = storyboard.instantiateViewController(
                   withIdentifier: "JobOfferViewController") as? JobOfferViewController else { return }
                newJobOfferVC.offer = jobOffer
                (window.rootViewController as? UINavigationController)?.pushViewController(newJobOfferVC, animated: true)
            }
        }
             
         }
     return isDynamicLinkHandled
}




public func openJobFromBackgroundNotification(data: [AnyHashable: Any], _ window: UIWindow) {
    let decoder = JSONDecoder()
    let jobOffer = OfferModel()
    let storyboard: UIStoryboard = UIStoryboard(name:"JobOffer", bundle: nil)

    guard let jobData = data["job"] else { return }
    if let dataBody = jobData as? String {
        let json = dataBody.data(using: .utf8)!
        do {
            let job = try decoder.decode(NotificationResponse.self, from: json)
            var jobImages = [String]()
            for image in job.images {
                jobImages.append(image.fullURL)
            }
            jobOffer.id = job.id
            jobOffer.mainImage = job.mainImage
            jobOffer.imagesURLs = jobImages
            jobOffer.latitude = job.latitude
            jobOffer.longitude = job.longitude

            // Navigate to job
            guard let newJobOfferVC = storyboard.instantiateViewController(
               withIdentifier: "JobOfferViewController") as? JobOfferViewController else { return }
            newJobOfferVC.offer = jobOffer
            (window.rootViewController as? UINavigationController)?.pushViewController(newJobOfferVC, animated: true)


        } catch {
            print(error)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension  AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let data = response.notification.request.content.userInfo
        openJobFromBackgroundNotification(data: data, (window)!)
      // tell the app that we have finished processing the user’s action / response
      completionHandler()
    }
}

//
//  ServerManager.swift
//  WhiteAppSwift
//
//  Created by Priba on 11/29/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ServerManager {
    static let sharedInstance = ServerManager();
    
    let baseUrl = "https://dev.jobdeal.com/api" //TEST
    private let reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")

    func APIUrl(urlExtension:String) -> (String){
        return baseUrl + urlExtension
    }

    func isNetworkReachable() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    func authHeaders() -> HTTPHeaders{
        if let token = UserDefaults.standard.value(forKey: "authToken") as? String,
            let locale = Locale.current.languageCode {
            return [ "Authorization" : token,
                     "locale" : locale]
        } else {
            return [ "Authorization" : "" ]
        }

    }
    
    //MARK: - User
    
    func login(username: String,
               password: String,
               timezone: String,
               country: String,
               locale: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){

        let params : Parameters = [
            "email" : username,
            "password" : password,
            "timezone" : timezone,
            "country" : country,
            "locale" : locale]

        Alamofire.request(APIUrl(urlExtension: "/user/login"), method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in

            switch response.result {

            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")

            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
        
    }
    
    func forgotPassword(email: String, completition: @escaping (_ response: String, _ success: Bool?,  _ message: String) -> ()) {
        let parm : Parameters = ["email" : email]
        
        Alamofire.request(APIUrl(urlExtension: "/user/password/forgot"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: nil).responseString(completionHandler: { (response) in
            
            if response.result.value != nil {
                completition("responseObject", true, "")
            } else {
                completition("", false, "")
            }
        })
    }
    
    func addDevice() {
        let type = 1
        let token = UserDefaults.standard.value(forKey: "fcmToken") ?? ""
        let model = UIDevice.modelName
        let appVersion: String = Bundle.main.releaseVersionNumber!
        let osVersion: String = UIDevice.current.systemVersion
        let parm : Parameters = [
            "type": type,
            "token": token,
            "model": model,
            "appVersion": appVersion,
            "osVersion": osVersion
        ]
        
        Alamofire.request(APIUrl(urlExtension: "/user/device/add"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: self.authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                print(error)
            }
        }
    }
    
    func checkUserMail(email: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let parm : Parameters = [
            "email" : email]
        
        Alamofire.request(APIUrl(urlExtension: "/user/email/check"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
        
    }
    
    func register(creatingUser: UserModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
       
        var roleId = 0
        
        switch creatingUser.role {
        case .visitor:
             roleId = 0
            break
        case .doer:
            roleId = 1
            break
        case .buyer:
            roleId = 5
            break
        }
        
        let country = Utils.getCountryCodeBySim()
        let locale = LanguageManager.sharedInstance.getStringForKey(key: "locale")
        let timezone = TimeZone.current.identifier
        
        let parm : Parameters = [
            "name" : creatingUser.name,
            "surname" : creatingUser.surname,
            "mobile" : creatingUser.mobile,
            "email" : creatingUser.email,
            "password" : creatingUser.password,
            "avatar" : creatingUser.avatar,
            "address" : creatingUser.address,
            "zip" : creatingUser.zip,
            "city" : creatingUser.city,
            "roleId": roleId,
            "country" : country ?? "se",
            "locale" : locale,
            "uid" : creatingUser.uid,
            "timezone" : timezone
        ]
        
        Alamofire.request(APIUrl(urlExtension: "/user/register"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
        
    }
    
    func updateUser(user: UserModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        let country = Locale.current.regionCode
        let locale = LanguageManager.sharedInstance.getStringForKey(key: "locale")
        
        let parm : Parameters = [
            "name" : user.name,
            "surname" : user.surname,
            "mobile" : user.mobile,
            "email" : user.email,
            "avatar" : user.avatar,
            "address" : user.address,
            "zip" : user.zip,
            "city" : user.city,
            "country" : country ?? "se",
            "locale" : locale,
            "aboutMe": user.aboutMe,
            "uid": user.uid
        ]
        
        Alamofire.request(APIUrl(urlExtension: "/user/update"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
        
    }

    func changePassword(old: String, new: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let parm : Parameters = [
            "oldPassword" : old,
            "newPassword" : new]
        
        Alamofire.request(APIUrl(urlExtension: "/user/password"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
        
    }
    
    func uploadAvatarImage(imageData: Data, completition: @escaping (_ response: NSDictionary, _ success: Bool?) -> ()){
        
        let url = baseUrl + "/user/image/upload"
        
        let parameters = ["name": "image"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(imageData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, to:url)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let responseObject = response.result.value as? NSDictionary {
                        completition(responseObject, true)
                    }else{
                        completition([:], false)
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func getCategories(completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/category/all/0"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getUser(id: Int, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/user/get/\(id)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getAddressWith(longitude: Double, latitude: Double, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/directions/address/\(latitude)/\(longitude)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func rateUser(rating: Double, user: UserModel, job: OfferModel, comment: String, rateBuyer: Bool, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/rate/add"
        
        var parm : Parameters = [
            "rate" : rating,
            "comment" : comment,
            "job" : ["id":job.id]]
        
        if rateBuyer {
            parm["buyer"] = ["id" : user.Id]
        } else {
            parm["doer"] = ["id" : user.Id]
        }
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getBuyerRate(user: UserModel, page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/rate/byBuyerId/\(user.Id)/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                if let responseObject = response.result.value as? [NSDictionary]{
                    print(responseObject)
                    completition(responseObject, true, "")
                }
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getDoerRate(user: UserModel, page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/rate/byDoerId/\(user.Id)/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getUserPostedJobs(user: UserModel, page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/buyer/getAll/\(user.Id)/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getUserAppliedJobs(page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/doer/getAll/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getUserAppliedJobsV2(type: Int, page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/doer/v2/getAll/\(type)/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func logOut(){

        Alamofire.request(APIUrl(urlExtension: "/user/logout"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.authHeaders()).responseJSON { response in
            print(response)
        }
        
    }
    
    func deleteAccount(){

        Alamofire.request(APIUrl(urlExtension: "/user/delete"), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: self.authHeaders()).responseJSON { response in
            print(response)
        }
        
    }
    
    func setWishList(){
        
        var locationDict = NSDictionary()
        let wishList = DataManager.sharedInstance.wishListFilter
        
        if wishList.isUsingCustomeLocation {
            locationDict = ["lat":wishList.latitude, "lng":wishList.longitude]
        } else {
            locationDict = ["lat":DataManager.sharedInstance.userLastLocation.latitude, "lng":DataManager.sharedInstance.userLastLocation.longitude]
        }
        
        let parm : Parameters = [
            "currentLocation" : locationDict,
            "filter": wishList.toDictionary()]
        
        Alamofire.request(APIUrl(urlExtension: "/wishlist/update"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: self.authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                print(error)
            }
        }
        
    }
    
    func getWishList(){
        
        Alamofire.request(APIUrl(urlExtension: "/wishlist/get"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode, 200...299 ~= statusCode {
                    let responseObject = response.result.value as! NSDictionary
                    let filterDict = responseObject["filter"] as! NSDictionary
                    print(responseObject)

                    let filter = FilterModel(dict: filterDict)
                    DataManager.sharedInstance.wishListFilter = filter.copy() as! FilterModel
                    
                    print("...HTTP code: \(statusCode)")
                }
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                print(error)
            }
        }
    }
    
    func reportJob(reportText: String, reportUser:UserModel, reportedJob: OfferModel, completition: @escaping (_ response: String, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/report"
        
        let parm : Parameters = [
                    "reportText" : reportText,
                    "job" : reportedJob.toDictionary(),
                    "user" : reportUser.toDictionary()]
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseString { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value
                completition(responseObject ?? "", true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ("[:]" ,false, errMessage)
                print(error)
            }
        }
    }
    
    
    //MARK: - Bank Id
    
    func bankIdAuth(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/bankid/auth"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func bankIdCollect(orderRef: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/bankid/collect"
        
        let parm : Parameters = [
            "orderRef" : orderRef]
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    //MARK: - Bank Id

    func klarnaPayment(completition: @escaping (_ response: String, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/klarna/pay"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseString { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value
                completition(responseObject ?? "", true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ("[:]" ,false, errMessage)
                print(error)
            }
        }
    }
    
    func klarnaJobPayment(type: Int, job:OfferModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/klarna/pay/job/\(type)"
        
        let parm : Parameters = job.toDictionary()
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }
                
                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func klarnaSubscriptionPayment(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/klarna/pay/subscribe"
        
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func klarnaCancelSubscriptionPayment(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/klarna/subscribe/cancel"
        
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func klarnaChooseBidPayment(bid: BidModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/klarna/pay/choose"
        
        let parm : Parameters = bid.toDictionary()
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func klarnaCompletePayment(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let refId = UserDefaults.standard.value(forKey: "lastRefId")
        
        let url = "/payment/klarna/complete/\(refId ?? "")"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func swishJobPayment(type: Int, job:OfferModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/swish/pay/job/\(type)"
        
        let parm : Parameters = job.toDictionary()
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    

    func swishChoosePayment(bid: BidModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/payment/swish/pay/choose"
        let parm : Parameters = bid.toDictionary()
        
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func swishCompletePayment(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let refId = UserDefaults.standard.value(forKey: "lastRefId")
        
        let url = "/payment/swish/complete/\(refId ?? "")"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    //MARK: - Jobs
    
    func uploadJobImage(imageData: Data, completition: @escaping (_ response: NSDictionary, _ success: Bool?) -> ()){
        
        let url = baseUrl + "/job/image/upload"
        
        let parameters = ["name": "image"]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "image",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to:url)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let responseObject = response.result.value as? NSDictionary {
                        completition(responseObject, true)
                    }else{
                        completition([:], false)
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func uploadJobImages(imageDataArray: [Data], completition: @escaping (_ response: [NSDictionary], _ success: Bool?) -> ()){
        
        let url = baseUrl + "/job/image/upload"
        
        let parameters = ["description": "image"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData : MultipartFormData) in
            
            let count = imageDataArray.count
            
            for i in 0..<count{
                multipartFormData.append(imageDataArray[i], withName: "image", fileName: "file.jpg" , mimeType: "image/jpeg")
                
            }
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            print(multipartFormData)
        }, to: url) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let responseObject = response.result.value as? [NSDictionary] {
                        completition(responseObject, true)
                    }else{
                        completition([[:]], false)
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    //Dashboard
    func getJobs(speedy: Bool, delivery: Bool = false, page: Int, sortBy: String, sortDirection: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
       
        var jobType = 0
        if speedy {
            jobType = 1
        } else if delivery {
            jobType = 2
        }
        
        let mainFilter = DataManager.sharedInstance.mainFilter
        
        var locationDict = NSDictionary()
        
        if mainFilter.isUsingCustomeLocation {
            locationDict = ["lat":mainFilter.latitude, "lng":mainFilter.longitude]
        } else {
            locationDict = ["lat":DataManager.sharedInstance.userLastLocation.latitude, "lng":DataManager.sharedInstance.userLastLocation.longitude]
        }
        
        let parm : Parameters = [
            "sortBy": sortBy,
            "sortDirection": sortDirection,
            "currentLocation" : locationDict,
            "filter": mainFilter.toDictionary()]
        
        Alamofire.request(APIUrl(urlExtension: "/job/filter/\(jobType)/\(page)"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getJobById(id: Int, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/get/\(id)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getMapJobs(speedy: Bool, delivery: Bool = false, latitude: Double, longitude: Double, distance: Double, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        var jobType = 0
        if speedy {
            jobType = 1
        } else if delivery {
            jobType = 2
        }
        
        let mainFilter = DataManager.sharedInstance.mainFilter
        
        var locationDict = NSDictionary()
        
        if mainFilter.isUsingCustomeLocation {
            locationDict = ["lat":mainFilter.latitude, "lng":mainFilter.longitude]
        }else{
            locationDict = ["lat":DataManager.sharedInstance.userLastLocation.latitude, "lng":DataManager.sharedInstance.userLastLocation.longitude]
        }
        
        let locationFilterDict : Parameters = ["lng" : longitude,
                                 "lat" : latitude,
                                 "distance" : distance]
        
        var filterDict = mainFilter.toDictionary()
        filterDict["location"] = locationFilterDict
        
        let parm : Parameters = [
            "sortBy": "price",
            "sortDirection": "DESC",
            "currentLocation" : locationDict,
            "filter": filterDict]
        
        print(parm)
                
        Alamofire.request(APIUrl(urlExtension: "/job/filter/\(jobType)/0"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getApplicantsForJobs(page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        Alamofire.request(APIUrl(urlExtension: "/job/buyer/getAll/\(page)"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func addJob(name: String, desc: String, expireAt: String, price: String, address: String, buyerProfile: String, categoryId: Int, property: String, isBoost: Bool,isSpeedy: Bool, code: String, image: [Dictionary<String, Any>], longitude: Double, latitude: Double, isDelivery: Bool, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let parm : Parameters = [
            "name" : name,
            "description" : desc,
            "expireAt" : expireAt,
            "price" : String(price),
            "address" : address,
            "buyerProfile" : buyerProfile,
            "categoryId" : categoryId,
            "property" : property,
            "code" : code,
            "images" : image,
            "isBoost" : isBoost,
            "isSpeedy" : isSpeedy,
            "longitude" : longitude,
            "latitude" : latitude,
            "isDelivery": isDelivery
        ]
        
        Alamofire.request(APIUrl(urlExtension: "/job/add"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:], false, errMessage)
                print(error)
            }
        }
    }
    
    func editJob(id: Int, name: String, desc: String, expireAt: String, price: String, address: String, buyerProfile: String, categoryId: Int, property: String, isBoost: Bool,isSpeedy: Bool, code: String, image: [Dictionary<String, Any>], longitude: Double, latitude: Double, isDelivery: Bool, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let parm : Parameters = [
            "id" : id,
            "name" : name,
            "description" : desc,
            "expireAt" : expireAt,
            "price" : String(price),
            "address" : address,
            "buyerProfile" : buyerProfile,
            "categoryId" : categoryId,
            "property" : property,
            "code" : code,
            "images" : image,
            "isBoost" : isBoost,
            "isSpeedy" : isSpeedy,
            "longitude" : longitude,
            "latitude" : latitude,
            "isDelivery": isDelivery
        ]
        
        Alamofire.request(APIUrl(urlExtension: "/job/edit"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:], false, errMessage)
                print(error)
            }
        }
    }
    
    func uploadImages(request: NSURLRequest, images: [UIImage]) {

        let uuid = NSUUID().uuidString
        let boundary = String(repeating: "-", count: 24) + uuid

        // Open the file
        let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

        let fileURL = directoryURL.appendingPathComponent(uuid)
        let filePath = fileURL.path

        FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)

        let file = FileHandle(forWritingAtPath: filePath)!

        // Write each image to a MIME part.
        let newline = "\r\n"

        for (i, image) in images.enumerated() {

            let partName = "image-\(i)"
            let partFilename = "\(partName).png"
            let partMimeType = "image/png"
            let partData = image.pngData()

            // Write boundary header
            var header = ""
            header += "--\(boundary)" + newline
            header += "Content-Disposition: form-data; name=\"\(partName)\"; filename=\"\(partFilename)\"" + newline
            header += "Content-Type: \(partMimeType)" + newline
            header += newline

            let headerData = header.data(using: String.Encoding.utf8, allowLossyConversion: false)

            print("")
            print("Writing header #\(i)")
            print(header)

            print("Writing data")
            print("\(partData!.count) Bytes")

            // Write data
            file.write(headerData!)
            file.write(partData!)
        }

        // Write boundary footer
        var footer = ""
        footer += newline
        footer += "--\(boundary)--" + newline
        footer += newline

        print("")
        print("Writing footer")
        print(footer)

        let footerData = footer.data(using: String.Encoding.utf8, allowLossyConversion: false)
        file.write(footerData!)

        file.closeFile()
        
        // Add the content type for the request to multipart.
        let outputRequest = request.copy() as! NSMutableURLRequest

        let contentType = "multipart/form-data; boundary=\(boundary)"
        outputRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")


        // Start uploading files.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.upload(request: outputRequest, data: file.availableData as NSData)
    }

    func applyForJob(jobOffer: OfferModel, price: String, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        var myBid = price
        if myBid == "" {
            myBid = String(jobOffer.price)
        }
        
        let parm : Parameters = [
            "job": jobOffer.toDictionary(),
            "price" : myBid]
        
        print(parm)
        
        Alamofire.request(APIUrl(urlExtension: "/job/apply"), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getApplicantsForJob(jobOffer: OfferModel, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/applicants/\(jobOffer.id)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func chooseApplicantForJob(jobOffer: OfferModel, bid: BidModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/applicants/choose/\(jobOffer.id)"
        let parm : Parameters = bid.toDictionary()
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func addBookmarkForJob(jobOffer: OfferModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/bookmark/add"
        let parm : Parameters = jobOffer.toDictionary()

        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func removeBookmarkForJob(jobOffer: OfferModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/bookmark/remove"
        let parm : Parameters = jobOffer.toDictionary()
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func deleteJob(jobOffer: OfferModel, completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/job/delete"
        let parm : Parameters = jobOffer.toDictionary()
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: parm, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getAllBookmarks(page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()){
        
        let url = "/bookmark/all/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    //MARK: - Notifications
    
//    func getUnreadNotificationsCount(completition: @escaping (_ response: [String : Any], _ success: Bool?,  _ message: String) -> ()) {
//        
//        let url = "/notification/unread"
//        
//        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
//            
//            switch response.result {
//                
//            case .success:
//                if let statusCode = response.response?.statusCode {
//                    print("...HTTP code: \(statusCode)")
//                }
//
//                let responseObject = response.result.value as! [String : Any]
//                print(responseObject)
//                completition(responseObject, true, "")
//                
//            case .failure(let error):
//                if let statusCode = response.response?.statusCode {
//                    print("...HTTP code: \(statusCode)")
//                }
//
//                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
//                completition ([:] ,false, errMessage)
//                print(error)
//            }
//        }
//    }
    
    func getNotifications(page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/notification/all/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getNotificationsByType(type: Int, page: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/notification/types/\(type)/\(page)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getNotificationById(id: Int, completition: @escaping (_ response: [NSDictionary], _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/notification/get/\(id)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! [NSDictionary]
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([[:]] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func readNotification(id: Int) {
        
        let url = "/notification/read/\(id)"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
           
        }
    }
    
    func getUnreadNotificationCount(completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/notification/unread"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func getVerificationCode(params: [String : Any], completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/verification/send"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: params, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func verifyCode(params: [String : Any], completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/verification/verify"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: params, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func priceCalculation(params: [String : Any], completition: @escaping (_ response: NSDictionary, _ success: Bool?,  _ message: String) -> ()) {
        
        let url = "/price/calculate"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: params, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                completition(responseObject, true, "")
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let errMessage = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                completition ([:] ,false, errMessage)
                print(error)
            }
        }
    }
    
    func updateUserLocation(params: [String : Any]) {
        
        let url = "/user/location/update"
        
        Alamofire.request(APIUrl(urlExtension: url), method: .post, parameters: params, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { response in
            
            switch response.result {
                
            case .success:
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                let responseObject = response.result.value as! NSDictionary
                print(responseObject)
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    print("...HTTP code: \(statusCode)")
                }

                print(error)
            }
        }
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

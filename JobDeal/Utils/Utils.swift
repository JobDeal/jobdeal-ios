//
//  Utils.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit
import ImageViewer
import CoreTelephony
import CoreLocation
import libPhoneNumber_iOS


class Utils{
    
    static func timePassString(timePass: Int) -> String {
        var str = ""
        
        if timePass == 0 {
            return LanguageManager.sharedInstance.getStringForKey(key: "now")
        }
        
        if timePass < 60{
            str = "\(Int(timePass)) " + LanguageManager.sharedInstance.getStringForKey(key: "minut")
        }else if timePass < 1440{
            
            str = "\(Int(timePass/60)) " + LanguageManager.sharedInstance.getStringForKey(key: "hour")
        }else if timePass < 43200{
            
            str = "\(Int(timePass/1440)) " + LanguageManager.sharedInstance.getStringForKey(key: "day")
        }else if timePass < 518400{
            
            str = "\(Int(timePass/43200)) " + LanguageManager.sharedInstance.getStringForKey(key: "month")
        }else{
            
            str = "\(Int(timePass/518400)) " + LanguageManager.sharedInstance.getStringForKey(key: "year")
        }
        
        return str
    }
    
    static func isIphoneSeriesX() -> Bool {
        
        if(UIApplication.shared.keyWindow!.frame.height >= CGFloat(812.0)){
            return true
        }
        return false
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func getPriceMarkerViewFor(offer:OfferModel)-> UIView!{
        
        let view: PriceMarker = .fromNib()
        view.setPrice(price: String(offer.getFullPriceOnMap()), addBoostColor: offer.isBoost)
        return view
    }
    
    static func getExtendedMarkerViewFor(offer:OfferModel)-> UIView! {
        
        let view: ExtendedMarker = .fromNib()
        view.setOffer(offer: offer)
        return view
    }

    static func recursiveCategoryCaughter(array:[CategoryModel], ids:[Int]) -> [Int] {
        var tmpIds = ids
        for category in array {
            if category.isSelected {
                tmpIds.append(category.id)
            }
            
            tmpIds = recursiveCategoryCaughter(array: category.subCategories, ids: tmpIds)
        }
        return tmpIds
    }
    
    static func getSelectedItemsIds(array: [CategoryModel]) -> [Int] {
        var selectedItems = [Int]()
        
        for cat in array {
            if cat.isSelected {
                selectedItems.append(cat.id)
            }
            for subCat in cat.subCategories {
                if subCat.isSelected {
                    selectedItems.append(subCat.id)
                }
                for subSubCat in subCat.subCategories {
                    if subSubCat.isSelected {
                        selectedItems.append(subSubCat.id)
                    }
                }
            }
        }
            
        return selectedItems
    }
    
    static func getRoundedPrice(price:Float) -> String{
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            // it's an integer
            return "\(Int(price))"
        }
        else {
            // it's an double
            return "\(price)"
        }
    }
    
    static func addNotificationCount() {
        var count = UserDefaults.standard.integer(forKey: "notificationsCount")
        count += 1
        UserDefaults.standard.set(count, forKey: "notificationsCount")
        UserDefaults.standard.synchronize()
    }
    
    static func decreaseNotificationCount() {
        var count = UserDefaults.standard.integer(forKey: "notificationsCount")
        count -= 1
        UserDefaults.standard.set(count, forKey: "notificationsCount")
        UserDefaults.standard.synchronize()
    }
    
    static func getNotificationCountString() -> String {
        let count = UserDefaults.standard.integer(forKey: "notificationsCount")
        return count == 0 ? "" : "\(count)"
    }
    
    static func setNotificationCountString(count: Int){
        UserDefaults.standard.set(0, forKey: "notificationsCount")
        UserDefaults.standard.synchronize()
    }
    
    static func removeNotificationsCount() {
        UserDefaults.standard.set(0, forKey: "notificationsCount")
        DataManager.sharedInstance.loggedUser.notificationCount = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    static func getColorImageForNotificationType(type: NotificationType) -> UIImage {
        switch type {
        case .doerBid:
            return UIImage(named: "orangeNotificationStatus")!
        case .buyerAccepted:
            return UIImage(named: "greenNotificationStatus")!
        case .rateDoer:
            return UIImage(named: "greenNotificationStatus")!
        case .rateBuyer:
            return UIImage(named: "greenNotificationStatus")!
        case .wishListJob:
            return UIImage(named: "orangeNotificationStatus")!
        case .paymentSuccess:
            return UIImage(named: "greenNotificationStatus")!
        case .paymentError:
            return UIImage(named: "greenNotificationStatus")!
        case .unknownType:
            return UIImage()
        }
    }
    
    static func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[+]{1,1}[0-9]{11,}$", options: .caseInsensitive)
        return regex.firstMatch(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count)) != nil
    }
    
    static func getCommonGalleryConfiguration() -> GalleryConfiguration {
        let galleryConfiguration: GalleryConfiguration = [
            GalleryConfigurationItem.activityViewByLongPress(false),
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.none)
        ]
        
        return galleryConfiguration
    }
    
    static func hasNotch() -> Bool {
        let bottom = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
    static func getCountryCodeBySim() -> String?  {
        guard let carrierProviders = CTTelephonyNetworkInfo.init().serviceSubscriberCellularProviders else {
            // Show choose country table view if carrier was not found
            return nil
        }
        
        if carrierProviders.keys.count > 0, let firstProvider = carrierProviders.keys.first {
            guard let carrier = carrierProviders[firstProvider] else {
                // Show choose country table view if carrier was not found
                return nil
            }
            
            if let code = carrier.isoCountryCode {
                return code
            }
            return nil
        }
        return nil
    }
    
    static func getPhoneExtension() -> String?  {
        guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
                return ""
            }

        
        let phoneNumberExtension: NSNumber = phoneUtil.getCountryCode(forRegion: getCountryCodeBySim()?.uppercased())
        return "+" + phoneNumberExtension.stringValue
           
    }
    
    static func cleanupUserDefaultsForPushNotifications() {
        UserDefaults.standard.set(false, forKey: "openNotificationDidLaunch")
        UserDefaults.standard.set(false, forKey: "openNotificationOnWakeUp")
        UserDefaults.standard.set(nil, forKey: "notificationUserInfo")
    }
    
    static func cleanupLocalStorage() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
    }
    
    static func openGoogleMapNavigation(forLocation location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let googleMapScheme = "comgooglemaps://"
        guard let url = URL(string: googleMapScheme) else { return }
        
        if UIApplication.shared.canOpenURL(url) { // check if phone has an google maps app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }}
        else {
            // Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
            }
        }
    }
}

//
//  UserModel.swift
//  JobDeal
//
//  Created by Priba on 12/26/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit

protocol UserModelDelegate {
    func userUpdated(user:UserModel)
}

class UserModel {
    
    var active = false
    var bankid = ""
    var country = ""
    var createdAt = ""
    var currency = ""
    var locale = "en"
    var Id: Int32 = 0
    var name = ""
    var surname = ""
    var mobile = ""
    var email = ""
    var password = ""
    var address = ""
    var avatar = ""
    var zip = ""
    var city = ""
    var buyerRating = 0.0
    var doerRating = 0.0
    var buyerRateCount = 0
    var doerRateCount = 0
    var activeJobs = 0
    var role: UserRole = .visitor
    var isPaid = false
    var subscription = ""
    var notificationCount = 0
    var uid = ""
    var aboutMe = ""
    var buyerRole: BuyerRole = .privateRole
    var image = UIImage()
    var timezone = ""
    
    init(dict:NSDictionary) {
        print(dict)
        
        if let temp = dict["active"] as? Bool {
            active = temp
        }
        
        if let temp = dict["currency"] as? String {
            currency = temp
        }
        
        if let temp = dict["address"] as? String {
            address = temp
        }
        
        if let temp = dict["avatar"] as? String {
            avatar = temp
        }
        
        if let temp = dict["bankId"] as? String {
            bankid = temp
        }
        
        if let temp = dict["city"] as? String {
            city = temp
        }
        
        if let temp = dict["country"] as? String {
            country = temp
        }
        
        if let temp = dict["createdAt"] as? String {
            createdAt = temp
        }
        
        if let temp = dict["email"] as? String {
            email = temp
        }
        
        if let temp = dict["id"] as? Int32 {
            Id = temp
        }
        
        if let temp = dict["locale"] as? String {
            locale = temp
        }
        
        if let temp = dict["mobile"] as? String {
            mobile = temp
        }
        
        if let temp = dict["name"] as? String {
            name = temp
        }
        
        if let temp = dict["surname"] as? String {
            surname = temp
        }
        
        if let temp = dict["zip"] as? String {
            zip = temp
        }
        
        if let temp = dict["notificationCount"] as? Int {
            notificationCount = temp
        }
        
        if let temp = dict["subscription"] as? String  {
            subscription = temp
            isPaid = true
        } else {
            isPaid = false
        }
        
        if let temp = dict["rate"] as? NSDictionary {
            buyerRating = temp["avgBuyer"] as? Double ?? 0
            buyerRateCount = temp["countBuyer"] as? Int ?? 0
            doerRating = temp["avgDoer"] as? Double ?? 0
            doerRateCount = temp["countDoer"] as? Int ?? 0
        }
        
        if let temp = dict["activeJobs"] as? Int {
            activeJobs = temp
        }
        
        role = .buyer

        if let temp = dict["roleId"] as? Int {
            switch temp {
            case 0:
                role = .visitor
                break
            case 1:
                role = .doer
                break
            case 5:
                role = .buyer
                break
            default:
                role = .buyer
                break
            }
        }
        
        if let uid = dict["uid"] as? String {
            self.uid = uid
        }
        
        if let aboutMe = dict["aboutMe"] as? String {
            self.aboutMe = aboutMe
        }
        
        if let timezone = dict["timezone"] as? String {
            self.timezone = timezone
        }
    }
    
    init() {}
    
    func getUserFullName() -> String {
        return name + " " + surname
    }
    
    func getUserDoerRatingString() -> String {
        return "\(doerRating)/\(doerRateCount)"
    }
    
    func getUserBuyerRatingString() -> String {
        return "\(buyerRating)/\(buyerRateCount)"
    }
    
    func copy(with zone: NSZone? = nil) -> UserModel {
        let copy = UserModel()
        
        copy.name = name
        copy.surname = surname
        copy.mobile = mobile
        copy.avatar = avatar
        copy.address = address
        copy.city = city
        copy.password = password
        copy.bankid = bankid
        copy.country = country
        copy.createdAt = createdAt
        copy.email = email
        copy.Id = Id
        copy.locale = locale
        copy.role = role
        copy.zip = zip
        copy.uid = uid
        copy.aboutMe = aboutMe
        copy.timezone = timezone
        
        return copy
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        
        dict["active"] = self.active
        dict["bankId"] = self.bankid
        dict["country"] = self.country
        dict["createdAt"] = self.createdAt
        dict["currency"] = self.currency
        dict["locale"] = self.locale
        dict["id"] = self.Id
        dict["name"] = self.name
        dict["surname"] = self.surname
        dict["mobile"] = self.mobile
        dict["email"] = self.email
        dict["password"] = self.password
        dict["address"] = self.address
        dict["avatar"] = self.avatar
        dict["zip"] = self.zip
        dict["city"] = self.city
        dict["buyerRating"] = self.buyerRating
        dict["doerRating"] = self.doerRating
        dict["isPaid"] = self.isPaid
        dict["uid"] = self.uid
        dict["aboutMe"] = self.aboutMe
        dict["timezone"] = self.timezone
        
        return dict
    }
}

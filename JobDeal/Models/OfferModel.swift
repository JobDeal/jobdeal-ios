//
//  OfferModel.swift
//  JobDeal
//
//  Created by Priba on 12/9/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit

enum JobType {
    case normal
    case speedy
    case boost
    case boostAndSpeedy
}

enum JobStatus {
    case normal
    case seeApplicants
    case doerChoosed
    case boostAndSpeedy
}

enum BuyerRole {
    case privateRole
    case company
}

protocol JobOfferDelegate: class {
    
    func jobOfferUpdated(offer: OfferModel)
    func jobDeleted(offer: OfferModel)
}

class OfferModel {
    
    var address = ""
    var user = UserModel()
    var applicants = [BidModel]()
    var categoryId = 0
    var categoryName = ""
    var category = CategoryModel()
    var code = ""
    var buyerProfile: BuyerRole = .privateRole
    var description = ""
    var id = 0
    var bidCount = 0
    var applicantCount = 0
    var choosedCount = 0
    var isBoost = false
    var isSpeedy = false
    var isDelivery = false
    var name = ""
    var price: Double = 0.0
    var distance: Double = 0.0
    var createdAt = ""
    var expireAtDate = ""
    var expireAt = ""
    var currency = ""
    var property = ""
    var type: JobType = .normal
    var status: JobStatus = .normal
    var bookmarked = false
    var isListPayed = false
    var isApplied = false
    var helpOnTheWay = false
    var isExpired = false
    var isUnderbidderListed = false

    var longitude = 0.0
    var latitude = 0.0
    
    var imagesURLs = [String]()
    var mainImage = ""

    init(){ }
    
    init(dict: NSDictionary) {
        print(dict)
        if let temp = dict["address"] as? String {
            address = temp
        }
        
        if let temp = dict["user"] as? NSDictionary {
            user = UserModel(dict: temp)
        }
        if let temp = dict["category"] as? NSDictionary {
            category = CategoryModel(dict: temp)
        }
        if let temp = dict["applicants"] as? [NSDictionary] {
            for dict in temp {
                let user = BidModel(dict: dict)
                applicants.append(user)
            }
        }
        
        if let temp = dict["buyerProfile"] as? Int {
            switch temp {
                
            case 1: buyerProfile = .privateRole
            case 2: buyerProfile = .company
                
            default:
                buyerProfile = .privateRole
            }
        }
        
        if let temp = dict["categoryId"] as? Int {
            categoryId = temp
        }
        
        if let temp = dict["applicantCount"] as? Int {
            applicantCount = temp
        }
        
        if let temp = dict["choosedCount"] as? Int {
            choosedCount = temp
        }
         
        if let temp = dict["bidCount"] as? Int {
            bidCount = temp
        }
        
        if let temp = dict["code"] as? String {
            code = temp
        }
        
        if let temp = dict["distance"] as? Double {
            distance = temp
        }
        
        if let temp = dict["isBoost"] as? Bool {
            isBoost = temp
        }
        
        if let temp = dict["isDelivery"] as? Bool {
            isDelivery = temp
        }
        
        if let temp = dict["isApplied"] as? Bool {
            isApplied = temp
        }
        
        if let temp = dict["helpOnTheWay"] as? Bool {
            helpOnTheWay = temp
        }
        
        if let temp = dict["isListed"] as? Bool {
            isListPayed = temp
        }
        
        if let temp = dict["isSpeedy"] as? Bool {
            isSpeedy = temp
        }
        
        if let temp = dict["isSpeedy"] as? Bool {
            isSpeedy = temp
        }
        
        if let temp = dict["isBookmarked"] as? Bool {
            bookmarked = temp
        }
        
        if let temp = dict["currency"] as? String {
            currency = temp
        }
        if let temp = dict["createdAt"] as? String {
            createdAt = temp
        }
        if let temp = dict["expireAtDate"] as? String {
            expireAtDate = temp
        }
        if let temp = dict["expireAt"] as? String {
            expireAt = temp
        }
        if let temp = dict["id"] as? Int {
            id = temp
        }
         
        if let temp = dict["images"] as? [Dictionary<String, Any>] {
            for dict in temp{
                
                var url = dict["fullUrl"] as! String
                
                if url.range(of:"///") != nil {
                    url = url.replacingOccurrences(of: "///", with: "/")
                }

                imagesURLs.append(url)
            }
        }
        
        if let temp = dict["name"] as? String {
            name = temp
        }
        
        if let temp = dict["price"] as? Double {
            price = temp
        }
        
        if let temp = dict["property"] as? String {
            property = temp
        }
        
        if let temp = dict["description"] as? String {
            description = temp
        }
        
        if let temp = dict["latitude"] as? Double {
            latitude = temp
        }
        
        if let temp = dict["longitude"] as? Double {
            longitude = temp
        }
        
        if let temp = dict["isExpired"] as? Bool {
            isExpired = temp
        }
        
        if let temp = dict["isUnderbidderListed"] as? Bool {
            isUnderbidderListed = temp
        }
        
        if let temp = dict["type"] as? Int {
            switch temp {
                
            case 1: type = .normal
            case 2: type = .speedy
                    isSpeedy = true
            case 3: type = .boost
                    isBoost = true
            case 4: type = .boostAndSpeedy
                    isSpeedy = true
                    isBoost = true

            default:
                type = .normal
            }
        }
        
        if let temp = dict["status"] as? Int {
            switch temp {
                
            case 1: status = .normal
            case 2: status = .seeApplicants
            case 3: status = .doerChoosed
                
            default:
                status = .normal
            }
        }
        
        if let temp = dict["mainImage"] as? String {
            mainImage = temp
        }
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        
        dict["name"] = self.name
        dict["description"] = self.description
        dict["address"] = self.address
        dict["categoryId"] = self.categoryId
        dict["description"] = self.description
        dict["code"] = self.code
        dict["isBoost"] = self.isBoost
        dict["isSpeedy"] = self.isSpeedy
        dict["isDelivery"] = self.isDelivery
        dict["currency"] = self.currency
        dict["createdAt"] = self.createdAt
        dict["expireAt"] = self.expireAt
        dict["id"] = self.id
        dict["price"] = self.price
        dict["property"] = self.property
        dict["latitude"] = self.latitude
        dict["longitude"] = self.longitude
        dict["isBookmarked"] = self.bookmarked
        dict["helpOnTheWay"] = self.helpOnTheWay
        dict["isExpired"] = self.isExpired
        dict["isUnderbidderListed"] = self.isUnderbidderListed
        
        switch type {
        case .normal : dict["type"] = 1
        case .speedy : dict["type"] = 2
        case .boost : dict["type"] = 3
        case .boostAndSpeedy : dict["type"] = 4
        }
        
        return dict
    }
    
    func getFullPrice() -> String {
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            // it's an integer
               return "\(Int(price)) \(currency)"
        }
        else {
            // it's an double
            return "\(price) \(currency)"
        }
    }
    
    func getFullPriceOnMap() -> String {
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            // it's an integer
            return "\(Int(price))\(currency)"
        } else {
            // it's an double
            return "\(price) \(currency)"
        }
    }
    
    func getDistanceStr() -> String{
        if distance > 1000 {
            return "\(Double(round(distance*10/1000)/10)) km"
        } else {
            return "\(Double(round(distance*10)/10)) m"
        }
    }
}

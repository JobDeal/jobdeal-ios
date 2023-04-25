//
//  FilterModel.swift
//  JobDeal
//
//  Created by Priba on 2/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation


class FilterModel: NSCopying {
    
    var fromPrice: Double = 0
    var toPrice: Double = 3000
    var categoriesIds = [Int]()
    var fromDistance: Double = 0
    var toDistance: Double = 100000
    var helpOnTheWay = true
    
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    var isUsingCustomeLocation = false
    
    init(){}
    
    init(dict: NSDictionary) {
        
        if let tempDict = dict["currentLocation"] as? NSDictionary {
            if let temp = tempDict["longitude"] as? Double{
                longitude = temp
            }
            
            if let temp = tempDict["latitude"] as? Double {
                latitude = temp
            }
        }
        
        if let temp = dict["isUsingCustomeLocation"] as? Bool {
            isUsingCustomeLocation = temp
        }
        
        if let temp = dict["fromPrice"] as? Double {
            fromPrice = temp
        }
        
        if let temp = dict["toPrice"] as? Double {
            toPrice = temp
        }
        
        if let temp = dict["fromDistance"] as? Double {
            fromDistance = temp
        }
        
        if let temp = dict["toDistance"] as? Double {
            toDistance = temp
        }
        
        if let temp = dict["categories"] as? [Int] {
            categoriesIds = temp
        }
        
        if let temp = dict["helpOnTheWay"] as? Bool {
            helpOnTheWay = temp
        }
    }
    
    required init(original: FilterModel) {
        self.fromPrice = original.fromPrice
        self.toPrice = original.toPrice
        self.fromDistance = original.fromDistance
        self.toDistance = original.toDistance
        self.categoriesIds = original.categoriesIds
        self.longitude = original.longitude
        self.latitude = original.latitude
        self.isUsingCustomeLocation = original.isUsingCustomeLocation
        self.helpOnTheWay = original.helpOnTheWay
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return FilterModel(original: self)
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        
        dict["fromPrice"] = self.fromPrice
        dict["toPrice"] = self.toPrice
        dict["fromDistance"] = self.fromDistance
        dict["toDistance"] = self.toDistance
        dict["categories"] = self.categoriesIds
        
        dict["latitude"] = self.latitude
        dict["longitude"] = self.longitude
        dict["isUsingCustomeLocation"] = self.isUsingCustomeLocation
        dict["helpOnTheWay"] = self.helpOnTheWay

        return dict
    }
    
    func saveMainFilterToUserDefaults() {
        UserDefaults.standard.set(self.toDictionary(), forKey: "mainFilter")
        UserDefaults.standard.synchronize()
    }
    
   static func loadMainFilterFromUserDefaults() -> FilterModel {
        if let dict = UserDefaults.standard.value(forKey: "mainFilter") as? NSDictionary {
            return FilterModel(dict: dict)
        }
        return FilterModel()
    }
    
    func saveWishListFilterToUserDefaults() {
        UserDefaults.standard.set(self.toDictionary(), forKey: "wishListFilter")
        UserDefaults.standard.synchronize()
    }
    
    static func loadWishListFromUserDefaults() -> FilterModel {
        if let dict = UserDefaults.standard.value(forKey: "wishListFilter") as? NSDictionary {
            return FilterModel(dict: dict)
        }
        return FilterModel()
    }
}

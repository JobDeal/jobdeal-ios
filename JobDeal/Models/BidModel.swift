//
//  BidModel.swift
//  JobDeal
//
//  Created by Priba on 2/11/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation

class BidModel {
    var bidPrice = 0.0
    var bidId = 0
    
    var bidUser = UserModel()
    var bidJob = OfferModel()
    var choosed = false

    init(){}
    
    init(dict: NSDictionary) {
        if let temp = dict["user"] as? NSDictionary{
            bidUser = UserModel(dict: temp)
        }
        
        if let temp = dict["choosed"] as? Bool{
            choosed = temp
        }
        
        if let temp = dict["job"] as? NSDictionary{
            bidJob = OfferModel(dict: temp)
        }
        
        if let temp = dict["price"] as? Double {
            bidPrice = temp
        }
        
        if let temp = dict["id"] as? Int {
            bidId = temp
        }
    }

    func getFullPrice() -> String{
        if bidPrice.truncatingRemainder(dividingBy: 1) == 0 {
            //it's an integer
            return "\(Int(bidPrice)) \(bidJob.currency)"
        }
        else {
            //it's an double
            return "\(bidPrice) \(bidJob.currency)"
        }
        
        
    }
 
    func toDictionary() -> Dictionary<String, Any>{
        var dict = Dictionary<String, Any>()
        
        dict["price"] = self.bidPrice
        dict["id"] = self.bidId
        dict["choosed"] = self.choosed
        dict["user"] = self.bidUser.toDictionary()
        dict["job"] = self.bidJob.toDictionary()
       
        return dict
    }
}

extension Array where Element: BidModel {
    func deselectAll() {
        for element in self {
            element.choosed = false
        }
    }
}

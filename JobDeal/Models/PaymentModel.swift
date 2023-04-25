//
//  PaymentModel.swift
//  JobDeal
//
//  Created by Priba on 3/20/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation

class PaymentModel {
    var amount: Float = 0.0
    var currency = ""
    var createdAt = ""
    var id = 0

    var job = OfferModel()
    
    var provider = ""
    var refId = ""
    var status = ""
    var type = 0
    var updatedAt = ""
    var user = UserModel()
    var doer = UserModel()

    init(){}
    
    init(dict: NSDictionary) {
        print(dict)
        if let temp = dict["amount"] as? Float{
            amount = temp
        }
        
        if let temp = dict["currency"] as? String{
            currency = temp
        }
        
        if let temp = dict["id"] as? Int{
            id = temp
        }
        
        if let temp = dict["job"] as? NSDictionary{
            job = OfferModel(dict: temp)
        }
        
        if let temp = dict["provider"] as? String{
            provider = temp
        }
        
        if let temp = dict["refId"] as? String{
            refId = temp
        }
        
        if let temp = dict["status"] as? String{
            status = temp
        }
        
        if let temp = dict["type"] as? Int{
            type = temp
        }
        
        if let temp = dict["updatedAt"] as? String{
            updatedAt = temp
        }
        
        if let temp = dict["user"] as? NSDictionary{
            user = UserModel(dict: temp)
        }
        
        if let temp = dict["doer"] as? NSDictionary{
            doer = UserModel(dict: temp)
        }

    }
    
}

//
//  PricesModel.swift
//  JobDeal
//
//  Created by Priba on 3/19/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation


class PricesModel {
    var boost: Float = 0.0
    var choose: Float = 0.0
    var country = ""
    var currency = ""
    var createdAt = ""
    var difference: Float = 0.0
    var fromDate = ""
    var id = 0
    var list: Float = 0.0
    var speedy: Float = 0.0
    var subscribe: Float = 0.0

    init(){}
    
    init(dict: NSDictionary) {
        
        if let temp = dict["boost"] as? Float{
            boost = temp
        }
        
        if let temp = dict["choose"] as? Float{
            choose = temp
        }
        
        if let temp = dict["country"] as? String{
            country = temp
        }
        
        if let temp = dict["createdAt"] as? String{
            createdAt = temp
        }
        
        if let temp = dict["currency"] as? String{
            currency = temp
        }
        
        if let temp = dict["difference"] as? Float{
            difference = temp
        }
        
        if let temp = dict["fromDate"] as? String{
            fromDate = temp
        }
        
        if let temp = dict["id"] as? Int{
            id = temp
        }
        
        if let temp = dict["list"] as? Float{
            list = temp
        }
        
        if let temp = dict["speedy"] as? Float{
            speedy = temp
        }
        
        if let temp = dict["subscribe"] as? Float{
            subscribe = temp
        }
    }
    
}

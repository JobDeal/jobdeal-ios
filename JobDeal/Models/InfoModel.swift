//
//  InfoModel.swift
//  JobDeal
//
//  Created by Priba on 3/5/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation

class InfoModel {
    var minPrice: Float = 100
    var maxPrice: Float = 3000
    var minIosVersion: Double = 1
    var currency: String = ""
    
    init(){}
    
    init(dict: NSDictionary) {

        if let temp = dict["minPrice"] as? Float{
            minPrice = temp
        }
        
        if let temp = dict["maxPrice"] as? Float{
            maxPrice = temp
        }
        
        if let temp = dict["minIosVersion"] as? Double{
            minIosVersion = temp
        }
        
        if let temp = dict["currency"] as? String{
            currency = temp
        }
    }
    
}

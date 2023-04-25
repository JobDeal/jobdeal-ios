//
//  RateModel.swift
//  JobDeal
//
//  Created by Priba on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation

class RateModel {
    
    var dateStr = ""
    var userName = ""
    
    var jobName = ""
    
    var message = ""
    
    var rate: Double = 0.0
    var ratingUser = UserModel()
    var ratingJob = OfferModel()

    init(date: String, userNameI: String, jobNameI: String, messageI: String, rateI: Double) {

        dateStr = date
        userName = userNameI
        jobName = jobNameI
        message = messageI
        rate = rateI
    }
    
    init(dict: NSDictionary) {
        
        if let temp = dict["comment"] as? String {
            message = temp
        }
        
        if let temp = dict["createdAt"] as? String {
            dateStr = temp
        }
        
        if let temp = dict["from"] as? NSDictionary {
            ratingUser = UserModel(dict: temp)
        }
        if let temp = dict["rate"] as? Double {
            rate = temp
        }

        if let temp = dict["job"] as? NSDictionary {
            ratingJob = OfferModel(dict: temp)
        }
    }
}

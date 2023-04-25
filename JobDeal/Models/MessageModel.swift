//
//  MessageModel.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType: Int {
    case unknownType = -1
    case doerBid = 1 // 1
    case buyerAccepted // 2
    case rateDoer // 3
    case rateBuyer // 4
    case wishListJob // 5
    case paymentSuccess // 6
    case paymentError // 7
}

class MessageModel {
    
    var fromId = 0
    var id = 0
    var job = OfferModel()
    var sender = UserModel()
    var timePass = 0
    var type: NotificationType = .doerBid
    var userId = 0
    var body = ""
    var title = ""
    var rate: RateModel?
    var isSeen = false

    init(dict: NSDictionary) {
        print(dict)
        if let temp = dict["fromId"] as? Int {
            fromId = temp
        }
        
        if let temp = dict["id"] as? Int {
            id = temp
        }
        
        if let temp = dict["body"] as? String {
            body = temp
        }
        
        if let temp = dict["title"] as? String {
            title = temp
        }
        
        if let temp = dict["job"] as? NSDictionary {
            job = OfferModel(dict: temp)
        }
        
        if let temp = dict["sender"] as? NSDictionary {
            sender = UserModel(dict: temp)
        }
        
        if let temp = dict["timePass"] as? Int {
            timePass = temp
        }
        if let temp = dict["userId"] as? Int {
            userId = temp
        }
        
        if let temp = dict["type"] as? Int {
            type = NotificationType(rawValue: temp) ?? .unknownType
        }
        
        if let temp = dict["rate"] as? RateModel {
            rate = temp
        }
        
        if let temp = dict["isSeen"] as? Bool {
            isSeen = temp
        }
    }
}


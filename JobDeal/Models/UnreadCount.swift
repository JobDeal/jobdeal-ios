//
//  UnreadCount.swift
//  JobDeal
//
//  Created by Nikola Majstorovic on 22.7.22..
//  Copyright © 2022 Qwertify. All rights reserved.
//

import Foundation

class UnreadCount {
    var unreadCount: Int = 0
    var unreadDoerCount: Int = 0
    var unreadBuyerCount: Int = 0
    
    init(){}
    
    init(dict: NSDictionary) {

        if let temp = dict["unreadCount"] as? Int{
            unreadCount = temp
        }
        
        if let temp = dict["unreadDoerCount"] as? Int{
            unreadDoerCount = temp
        }
        
        if let temp = dict["unreadBuyerCount"] as? Int{
            unreadBuyerCount = temp
        }
        
    }
    
}

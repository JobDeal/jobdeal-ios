//
//  UILabelExtensions.swift
//  JobDeal
//
//  Created by Priba on 12/9/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    
    func setupTitleForKey(key:String, uppercased:Bool = false){
        self.text = LanguageManager.sharedInstance.getStringForKey(key: key, uppercased: uppercased)
    }
    
    func setLabelHalfCornerRadius(){
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
}

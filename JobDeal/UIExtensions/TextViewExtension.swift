//
//  TextViewExtension.swift
//  JobDeal
//
//  Created by Priba on 1/9/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func setupForDarkLayout(){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.separatorColor.cgColor
        self.layer.cornerRadius = 8
                
        textContainerInset = UIEdgeInsets(top: 8,left: 24,bottom: 8,right: 24)
    }
    
    func isInputInvalid()-> Bool{
        
        let trimmedStr = self.text?.trimmingCharacters(in: [" "])
        
        let invalidSpaces = trimmedStr?.split(separator: " ").count == 0
        let invalidLenght = trimmedStr?.count == 0
        return invalidSpaces || invalidLenght
    }
    
    func trimmedString()-> String?{
        return self.text?.trimmingCharacters(in: [" "])
    }
    
    func setupProfileTVDisabledStyle(text:String) {
        self.font?.withSize(14.0)
        self.textColor = UIColor.black
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 8
        self.isUserInteractionEnabled = false
        self.text = text
        self.autocorrectionType = .no
    }
    
    func setupProfileTVEnabledStyle(text:String = "") {
        self.font?.withSize(12.0)
        self.textColor = UIColor.black
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        self.layer.cornerRadius = 8
        self.isUserInteractionEnabled = true
        self.text = text
        self.autocorrectionType = .no
    }
}

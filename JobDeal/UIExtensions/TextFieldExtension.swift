//
//  TextFieldExtension.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit
import TweeTextField

extension TweeAttributedTextField{
    
    func setupLayout(){
        self.setupForLayout()
        
        self.activeLineWidth = 0
        self.infoFontSize = 13
        self.infoTextColor = UIColor.red.withAlphaComponent(0.7)
        self.infoAnimationDuration = 0.1
    }
    
    func setupLayoutV2(){
        self.setupForLayoutV2()
        
        self.activeLineWidth = 0
        self.infoFontSize = 13
        self.infoTextColor = UIColor.red.withAlphaComponent(0.7)
        self.infoAnimationDuration = 0.1        
    }
    
    func setupProfileTFDisabledStyle(text:String){
        
        self.font?.withSize(14.0)
        self.textColor = UIColor.black
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 8
        self.isUserInteractionEnabled = false
        
        self.setLeftPaddingPoints(8.0)
        
        self.placeholder = ""
        self.text = text
        
        self.autocorrectionType = .no
    }
    
    func setupProfileTFEnabledStyle(text:String = "", placeholderKey:String){
        
        self.font?.withSize(12.0)
        self.textColor = UIColor.black
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        self.layer.cornerRadius = 8
        self.isUserInteractionEnabled = true
        
        self.setLeftPaddingPoints(8.0)
        
        self.infoFontSize = 13
        self.infoTextColor = UIColor.red.withAlphaComponent(0.7)
        self.infoAnimationDuration = 0.1

        self.text = text
        self.placeholder = LanguageManager.sharedInstance.getStringForKey(key: placeholderKey)
        
        self.autocorrectionType = .no
    }
}

extension UITextField{
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setupForLayout(){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = 8
        
        self.textColor = UIColor.white
        
        self.setLeftPaddingPoints(8)
        self.setRightPaddingPoints(8)
        
        self.autocorrectionType = .no
    }
    
    func setupForLayoutV2(){
        
        self.textColor = UIColor.black
        self.backgroundColor = UIColor.clear
        
        self.setLeftPaddingPoints(8)
        self.setRightPaddingPoints(8)
        
        self.autocorrectionType = .no
    }
    
    func setupForDarkLayout(){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.separatorColor.cgColor
        self.layer.cornerRadius = 8
        
        self.textColor = UIColor.darkGray
        
        self.setLeftPaddingPoints(24)
        self.setRightPaddingPoints(24)
        
        self.autocorrectionType = .no
    }
    
    func setPlaceholderForKey(key:String, textColor:UIColor = UIColor.white) {
        self.attributedPlaceholder = NSAttributedString(string: LanguageManager.sharedInstance.getStringForKey(key: key),
                                                               attributes: [NSAttributedString.Key.foregroundColor: textColor])
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
    
    func setTextForKey(key:String) {
        self.text = LanguageManager.sharedInstance.getStringForKey(key: key)
    }
}

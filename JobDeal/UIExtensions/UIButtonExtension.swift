//
//  UIButtonExtension.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit
import TransitionButton

extension UIButton {
    
    func setupTitleForKey(key:String, uppercased:Bool = false) {
        self.setTitle(LanguageManager.sharedInstance.getStringForKey(key: key, uppercased: uppercased), for: .normal)
    }
    
    func setupForLayoutTypeBlack() {
        self.layer.cornerRadius = 8
        
        self.backgroundColor = UIColor.black
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    func setupForLayoutDisabled() {
        self.layer.cornerRadius = 8
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    func setupForLayoutTypeUnfiled() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.setHalfCornerRadius()
        
        self.backgroundColor = UIColor.clear
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    func changeSelectedBackground() {
        if self.isSelected {
            self.backgroundColor = UIColor.black
        } else {
            self.backgroundColor = UIColor.separatorColor
        }
    }
}

extension TransitionButton {
    
    func setupForTransitionLayoutTypeBlack() {
        self.setupForLayoutTypeBlack()
        self.cornerRadius = self.layer.cornerRadius
        
        self.spinnerColor = UIColor.white
    }
    
    func setupForTransitionLayoutTypeUpload() {
        self.setupForLayoutTypeBlack()
        self.cornerRadius = self.frame.size.width/2
        self.backgroundColor = UIColor.white
        self.tintColor = UIColor.darkGray
        
        self.spinnerColor = UIColor.darkGray
    }
    
    func setupForTransitionLayoutDisabled() {
        self.setupForLayoutDisabled()
    }
}

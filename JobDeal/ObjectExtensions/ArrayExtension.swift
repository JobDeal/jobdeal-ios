//
//  ArrayExtension.swift
//  JobDeal
//
//  Created by Bojan Markovic  on 29.11.21..
//  Copyright © 2021 Priba. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: UIButton {
    func deselectAll() {
        for element in self {
            element.isSelected = false
        }
    }
    
    func selectAtTag(tag: Int) {
        for element in self {
            if element.tag == tag {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
            element.changeSelectedBackground()
        }
    }
    
    func setHalfCornerRadiusToAll() {
        for element in self{
            element.setHalfCornerRadius()
        }
    }
}

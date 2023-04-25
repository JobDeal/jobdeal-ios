//
//  CALayerExtension.swift
//  JobDeal
//
//  Created by Bojan Markovic  on 15.12.21..
//  Copyright © 2021 Qwertify. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func applySketchShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOpacity = 0.2
        shadowOffset = CGSize(width: 0, height: 0)
    }
}

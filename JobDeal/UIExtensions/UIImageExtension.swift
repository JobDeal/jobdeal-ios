//
//  UIImageExtension.swift
//  JobDeal
//
//  Created by Bojan Markovic  on 3.7.22..
//  Copyright © 2022 Qwertify. All rights reserved.
//

import Foundation
import UIKit

// https://stackoverflow.com/a/55723371/8195944
extension UIImage {
    func tintWithColor(_ color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()

        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -self.size.height)

        // multiply blend mode
        context?.setBlendMode(.multiply)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)

        // create UIImage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

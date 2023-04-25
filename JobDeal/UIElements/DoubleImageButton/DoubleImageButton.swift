//
//  DoubleImageButton.swift
//  JobDeal
//
//  Created by Bojan Markovic  on 7.7.22..
//  Copyright © 2022 Qwertify. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
final class DoubleImageButton: UIButton {
    /* Inspectable properties, once modified resets attributed title of the button */
    @IBInspectable var leftImg: UIImage? = nil {
        didSet {
            /* reset title */
            setAttributedTitle()
        }
    }

    @IBInspectable var rightImg: UIImage? = nil {
        didSet {
            /* reset title */
            setAttributedTitle()
        }
    }
    
    @IBInspectable var isUppercasedTitle: Bool = false {
        didSet {
            /* reset title */
            setAttributedTitle()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setAttributedTitle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setAttributedTitle()
    }

    private func setAttributedTitle() {
        var attributedTitle = NSMutableAttributedString()

        /* Attaching first image */
        if let leftImg = leftImg {
            let leftAttachment = NSTextAttachment(data: nil, ofType: nil)
            leftAttachment.image = leftImg
            
            let imageSize = leftAttachment.image!.size
            leftAttachment.bounds = CGRect(
                x: 0,
                y: (titleLabel!.font.capHeight - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
    
            let attributedString = NSAttributedString(attachment: leftAttachment)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let chooseDoerString = LanguageManager.sharedInstance.getStringForKey(key: "choose_doer")
            mutableAttributedString.append(NSAttributedString(string: "  \(isUppercasedTitle ? chooseDoerString.uppercased() : chooseDoerString)  "))
            
            attributedTitle = mutableAttributedString
        }

        /* Attaching second image */
        if let rightImg = rightImg {
            let rightAttachment = NSTextAttachment(data: nil, ofType: nil)
            rightAttachment.image = rightImg
            let imageSize = rightAttachment.image!.size
            rightAttachment.bounds = CGRect(
                x: 0,
                y: (titleLabel!.font.capHeight - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
            let attributedString = NSAttributedString(attachment: rightAttachment)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            attributedTitle.append(mutableAttributedString)
        }
        
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5

        /* Finally, lets have that two-imaged button! */
        setAttributedTitle(attributedTitle, for: .normal)
    }
}

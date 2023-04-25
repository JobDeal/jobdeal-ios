//
//  PriceMarker.swift
//  JobDeal
//
//  Created by Priba on 12/10/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit

class PriceMarker: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var downPointingArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addDropArrowColor()
        self.setHalfCornerRadius()
    }
    func addDropArrowColor() {
        let offer = OfferModel()
        if offer.isBoost {
            self.downPointingArrow.tintColor = UIColor.boostColor
        } else {
            self.downPointingArrow.tintColor = UIColor.defaultPriceColor
        }
    }
   
   
    func setPrice(price:String, addBoostColor:Bool){
        label.text = price
        label.textColor = UIColor.white
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        if(addBoostColor == true){
            label.backgroundColor = UIColor.boostColor
            self.downPointingArrow.tintColor = UIColor.boostColor
        }else {
           label.backgroundColor = UIColor.defaultPriceColor
            self.downPointingArrow.tintColor = UIColor.defaultPriceColor
        }
    }
}

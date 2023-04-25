//
//  JobOfferCollectionViewCell.swift
//  JobDeal
//
//  Created by Priba on 1/10/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class JobOfferCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backHolderView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var offerTitleLbl: UILabel!
    @IBOutlet weak var timeLeftLbl: UILabel!
    @IBOutlet weak var smallClockImageView: UIImageView!
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var bigClockImageView: UIImageView!
    
    override func awakeFromNib() {
        
        self.smallClockImageView.tintColor = UIColor.darkGray
        self.bigClockImageView.tintColor = UIColor.darkGray
        
        self.priceLbl.setLabelHalfCornerRadius()
        self.priceLbl.backgroundColor = UIColor.mainColor2
        self.priceLbl.addGradientToBackground()
        
        self.backHolderView.layer.cornerRadius = 8
        
        backHolderView.layer.applySketchShadow()
    }
    
    func populateWith(offer:OfferModel) {
        if offer.isBoost {
            let image = UIImageView()
            
            gradientView.addSubview(image)
            image.image = UIImage.init(named: "priceBoost")
            offerTitleLbl.text = offer.name
            if offer.isExpired {
                timeLeftLbl.setupTitleForKey(key: "job_expired")
            } else {
                timeLeftLbl.text = offer.expireAt
            }
            priceLbl.text = String(offer.getFullPrice())
            priceLbl.textColor = UIColor.white
        } else {
            let image = UIImageView()
            
            gradientView.addSubview(image)
            image.image = UIImage.init(named: "priceGreen")
            offerTitleLbl.text = offer.name
            if offer.isExpired {
                timeLeftLbl.setupTitleForKey(key: "job_expired")
            } else {
                timeLeftLbl.text = offer.expireAt
            }
            priceLbl.text = String(offer.getFullPrice())
            priceLbl.textColor = UIColor.white
        }
        if offer.isSpeedy {
            smallClockImageView.tintColor = UIColor.red
            timeLeftLbl.textColor = UIColor.red
        }
        
        bigClockImageView.isHidden = true
        priceLbl.layer.cornerRadius = priceLbl.frame.size.height/2
    }
}

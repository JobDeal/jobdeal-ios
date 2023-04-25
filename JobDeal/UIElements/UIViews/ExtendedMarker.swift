//
//  ExtendedMarker.swift
//  JobDeal
//
//  Created by Priba on 12/12/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit

class ExtendedMarker: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var offerTitle: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceGradientView: UIView!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = 8
        
        priceLbl.setLabelHalfCornerRadius()
        priceGradientView.setHalfCornerRadius()
    }
    
    func setOffer(offer:OfferModel){
        let url = offer.imagesURLs.first ?? ""

        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "imagePlaceholder"), options: .fromCacheOnly) { (image, error, cacheType, url) in
            
        }
        offerTitle.text = offer.name
        priceLbl.text = String(offer.getFullPrice())
        if offer.isExpired {
            timeLbl.setupTitleForKey(key: "job_expired")
        } else {
            timeLbl.text = offer.expireAt
        }
        distanceLbl.text = offer.getDistanceStr()
        
        priceLbl.text = String(offer.getFullPrice())
        priceLbl.textColor = UIColor.white
        priceLbl.backgroundColor = UIColor.defaultPriceColor
       
        if offer.isBoost{
            priceLbl.backgroundColor = UIColor.boostColor
            priceLbl.text = String(offer.getFullPrice())
            priceLbl.textColor = UIColor.white
        }
        if offer.isSpeedy {
            clockIcon.tintColor = UIColor.red
            timeLbl.textColor = UIColor.red
        }
    }
}

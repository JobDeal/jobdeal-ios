//
//  OfferCollectionViewCell.swift
//  JobDeal
//
//  Created by Priba on 12/9/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import SDWebImage

class OfferCollectionViewCell: UICollectionViewCell {
    var user = DataManager.sharedInstance.loggedUser

    @IBOutlet weak var helpOnTheWayImageView: UIImageView!
    @IBOutlet weak var backHolderView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var offerTitleLbl: UILabel!
    @IBOutlet weak var timeLeftLbl: UILabel!
    @IBOutlet weak var smallClockImageView: UIImageView!
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var bigClockImageView: UIImageView!
    
    override func awakeFromNib() {
        
        self.smallClockImageView.tintColor = UIColor.darkGray
        self.bigClockImageView.tintColor = UIColor.darkGray
        self.locationIcon.tintColor = UIColor.darkGray

        self.priceLbl.setLabelHalfCornerRadius()
        self.priceLbl.backgroundColor = UIColor.clear
        gradientView.setHalfCornerRadius()
        
        self.backHolderView.layer.cornerRadius = 8

        backHolderView.layer.applySketchShadow()
    }
    
    func populateWith(offer: OfferModel) {
        topImageView.sd_setImage(with: URL(string: offer.mainImage), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached, completed: nil)

        priceLbl.text = String(offer.getFullPrice())
        priceLbl.textColor = UIColor.white
        priceLbl.backgroundColor = UIColor.defaultPriceColor
        bigClockImageView.isHidden = true
        
        if offer.isSpeedy {
            smallClockImageView.tintColor = UIColor.red
            timeLeftLbl.textColor = UIColor.red
            priceLbl.backgroundColor = UIColor.boostColor
            priceLbl.text = String(offer.getFullPrice())
            priceLbl.textColor = UIColor.white
            
        } else {
            smallClockImageView.tintColor = UIColor.darkGray
            timeLeftLbl.textColor = UIColor.darkGray
            priceLbl.backgroundColor = UIColor.mainButtonColor
            priceLbl.text = String(offer.getFullPrice())
            priceLbl.textColor = UIColor.white
        }

        bigClockImageView.image = UIImage(named: "boostStar")
        bigClockImageView.tintColor = UIColor.boostStarColor
        bigClockImageView.isHidden = !offer.isBoost
        
        offerTitleLbl.text = offer.name
        if offer.isExpired {
            timeLeftLbl.setupTitleForKey(key: "job_expired")
        } else {
            timeLeftLbl.text = offer.expireAt
        }
        priceLbl.layer.cornerRadius = priceLbl.frame.size.height/2
        distanceLbl.text = offer.getDistanceStr()
        
        var helpOnTheWayImageName = "icRibbonEn"
        var isChosenForJob = "chosen"
        if LanguageManager.sharedInstance.getStringForKey(key: "locale", uppercased: true) == "SV" {
          helpOnTheWayImageName = "icRibbonSe"
            isChosenForJob = "chosenSe"
        }
            
        helpOnTheWayImageView.image = UIImage(named: helpOnTheWayImageName)
        helpOnTheWayImageView.alpha = 0.8
        helpOnTheWayImageView.isHidden = !offer.helpOnTheWay
        
        
        let applicants = offer.applicants
              if applicants.count > 0 {
                  let chosenDoerEmail = applicants[0].bidUser.email
                  if chosenDoerEmail == self.user.email {
                      helpOnTheWayImageView.image = UIImage(named: isChosenForJob)


                  }
              }
    
    }
    
}

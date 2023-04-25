//
//  JobBidsTableViewCell.swift
//  JobDeal
//
//  Created by Macbook Pro on 2/6/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

class JobBidsTableViewCell: UITableViewCell {

    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var durationJobLbl: UILabel!
    @IBOutlet weak var myOfferLbl: UILabel!
    @IBOutlet weak var bidersNumberLbl: UILabel!
    @IBOutlet weak var biddersLbl: UILabel!
    
    @IBOutlet weak var lockIcon: UIImageView!
    @IBOutlet weak var jobDealIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.holderView.layer.cornerRadius = 8
        self.holderView.layer.applySketchShadow()
        self.selectionStyle = .none
        
        jobImage.layer.cornerRadius = 8
        jobImage.clipsToBounds = true
    }
    
    func populateWith(offer:OfferModel) {
        let url = offer.imagesURLs.first ?? ""
        self.jobImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "imagePlaceholder"), options: .fromCacheOnly) { (image, error, cacheType, url) in
        }
        jobNameLbl.text = offer.name
        if offer.isExpired {
            holderView.backgroundColor = .lightGray
            durationJobLbl.setupTitleForKey(key: "job_expired")
        } else {
            durationJobLbl.text = offer.expireAt
            holderView.backgroundColor = .white
        }
        myOfferLbl.setupTitleForKey(key: "my_offer" + String(offer.getFullPrice()))
        myOfferLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "my_offer") + ": " + String(offer.getFullPrice())
        biddersLbl.setupTitleForKey(key: "bidders")
        bidersNumberLbl.text = String(offer.bidCount)
        
        lockIcon.isHidden = offer.isListPayed
        
        if offer.applicantCount > 0 && offer.applicantCount == offer.choosedCount {
            bidersNumberLbl.isHidden = true
            jobDealIcon.isHidden = false
            biddersLbl.text = offer.applicants.first!.getFullPrice()
            jobDealIcon.tintColor = .mainColor1
        } else {
            jobDealIcon.isHidden = true
            bidersNumberLbl.isHidden = false
        }
        
    }
}

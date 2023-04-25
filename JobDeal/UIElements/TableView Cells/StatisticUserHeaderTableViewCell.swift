//
//  StatisticUserHeaderTableViewCell.swift
//  JobDeal
//
//  Created by Priba on 2/1/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Foundation
import Cosmos
import SDWebImage

class StatisticUserHeaderTableViewCell: UITableViewCell {
    
    // MARK: -buyer IBOutlet
    
    @IBOutlet weak var buyerAvatarImageView: UIImageView!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var buyerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var buyerRateView: CosmosView!
    @IBOutlet weak var buyerRateCountLbl: UILabel!
    @IBOutlet weak var buyerHolderView: UIView!
    
    
    @IBOutlet weak var activeDoer: UILabel!
    
   
    
    
    @IBOutlet weak var rateHeaderLblHolderView: UIView!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var jobContractsLbl: UILabel!
    @IBOutlet weak var activeJobs: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var activeBtn: UIButton!
    
    @IBOutlet weak var arrowFowardBtn: UIButton!
    @IBOutlet weak var myJobsLbl: UILabel!
    @IBOutlet weak var activeJobView: UIView!
    @IBOutlet weak var spentLbl: UILabel!
    @IBOutlet weak var spentValue: UILabel!
    @IBOutlet weak var createJobBtn: UIButton!
    @IBOutlet weak var hightUserHolderConstrains: NSLayoutConstraint!
    @IBOutlet weak var higtCellUserConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        buyerHolderView.layer.cornerRadius = 10
        rateHeaderLblHolderView.layer.cornerRadius = 10
        buyerHolderView.layer.applySketchShadow()
        
        buyerAvatarImageView.setHalfCornerRadius()
        pinIV.tintColor = UIColor.darkGray
        buyerRateView.rating = 4.5
        buyerRateView.isUserInteractionEnabled = false
        createJobBtn.setupForLayoutTypeBlack()
        activeJobView.layer.cornerRadius = 10
        
    }

    func populateCell(user: UserModel) {

        self.buyerNameLbl.text = user.name + " " + user.surname
        self.buyerAvatarImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        
        if user.role == .buyer{
            self.createJobBtn.setupTitleForKey(key: "create_job")
            self.jobContractsLbl.setupTitleForKey(key: "job_contracts")
            self.activeJobs.text = "8"
            self.myJobsLbl.setupTitleForKey(key: "my_active_jobs", uppercased: true)
            self.rateLbl.setupTitleForKey(key: "rated_as_buyer")
            self.spentLbl.setupTitleForKey(key: "spent")
            self.spentValue.text = "285kr"
            
            self.bottomView.isHidden = true
            self.activeDoer.isHidden = true
            self.activeBtn.isHidden = true
            UIView.animate(withDuration: 0, animations: {
                self.higtCellUserConstraint.constant = 300
                self.cellView.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0, animations: {
                self.hightUserHolderConstrains.constant = 140
                self.buyerHolderView.layoutIfNeeded()
            })
        }else{
            self.activeDoer.setupTitleForKey(key: "active_doer")
            self.createJobBtn.setupTitleForKey(key: "check_job")
            self.jobContractsLbl.setupTitleForKey(key: "job_done")
            self.activeJobs.text = "8"
            self.myJobsLbl.setupTitleForKey(key: "my_active_jobs_doer", uppercased: true)
            self.rateLbl.setupTitleForKey(key: "rated_as_doer")
            self.spentLbl.setupTitleForKey(key: "earnd")
            self.spentValue.text = "285kr"
            
            self.bottomView.isHidden = false
            self.activeDoer.isHidden = false
            self.activeBtn.isHidden = false
            
            UIView.animate(withDuration: 0, animations: {
                self.higtCellUserConstraint.constant = 350
                self.cellView.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0, animations: {
                self.hightUserHolderConstrains.constant = 198
                self.buyerHolderView.layoutIfNeeded()
            })
            
        }
    }
    
}

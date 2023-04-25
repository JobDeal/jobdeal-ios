//
//  RateUserTableViewCell.swift
//  JobDeal
//
//  Created by Priba on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos

class RateUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var rateDateLbl: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var messageBackView: UIView!
    @IBOutlet weak var pointerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        messageBackView.layer.borderColor = UIColor.separatorColor.cgColor
        messageBackView.layer.borderWidth = 1
        messageBackView.layer.cornerRadius = 8
        pointerImageView.tintColor = UIColor.separatorColor
        
        rateView.isUserInteractionEnabled = false
        rateDateLbl.text = ""
    }

    func populateCell(rate: RateModel){
        jobNameLbl.text = rate.ratingJob.name
        userNameLbl.text = rate.ratingUser.getUserFullName()
        messageLbl.text = rate.message
        rateView.rating = rate.rate
        rateDateLbl.text = rate.dateStr
    }

}

//
//  InboxMessageTableViewCell.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class InboxMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var leftImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var indicator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
      
       
        holderView.backgroundColor = UIColor.white
        holderView.layer.applySketchShadow()
        
        rightImageView.setHalfCornerRadius()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.layer.cornerRadius = indicator.frame.height / 2
        indicator.layer.masksToBounds = true
        holderView.layer.cornerRadius = 8
        leftImageView.layer.cornerRadius = 8
        leftImageView.layer.masksToBounds = true
    }
    
    func populateWith(inboxMessage: MessageModel) {
        dateLbl.text = Utils.timePassString(timePass: inboxMessage.timePass)
        nameLbl.text = inboxMessage.title
        messageLbl.text = inboxMessage.body
        if let mainImageURL = URL(string: inboxMessage.job.mainImage) {
            leftImageWidthConstraint.constant = 52
            leftImageLeadingConstraint.constant = 8
            leftImageView.sd_setImage(with: mainImageURL)
        } else {
            leftImageWidthConstraint.constant = 0
            leftImageLeadingConstraint.constant = 0
        }
        rightImageView.image = Utils.getColorImageForNotificationType(type: inboxMessage.type)
        
        if(inboxMessage.isSeen){
            indicator.isHidden = true
        } else {
            indicator.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        leftImageView.image = nil
        rightImageView.image = nil
    }
}

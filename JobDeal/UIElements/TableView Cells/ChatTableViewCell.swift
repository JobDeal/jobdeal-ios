//
//  ChatTableViewCell.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/23/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var userHolderView: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userMessageLbl: UILabel!
    @IBOutlet weak var userPinImg: UIImageView!
    @IBOutlet weak var userCityLbl: UILabel!
    @IBOutlet weak var userDataLbl: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPinImg.tintColor = UIColor.darkGray
        userHolderView.backgroundColor = UIColor.white
        userHolderView.layer.cornerRadius = 8
        userHolderView.layer.applySketchShadow()
        userImage.setHalfCornerRadius()
        
        self.selectionStyle = .none

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func populateUserWith(inboxMessage: MessageModel) {
        
        //userImage.sd_setImage(with: URL(string: DataManager.sharedInstance.loggedUser.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
    }

}

//
//  CategoryTableViewCell.swift
//  JobDeal
//
//  Created by Priba on 2/20/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBoxIV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var forwardBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        checkBoxIV.layer.cornerRadius = 4
        checkBoxIV.tintColor = UIColor.darkGray
    }

    func populate(category: CategoryModel){
        titleLbl.text = category.title
        
        if category.isSelected {
            checkBoxIV.image = UIImage(named: "checkboxOn")
            checkBoxIV.tintColor = UIColor.mainColor1
        }else if category.isHalfSelected{
            checkBoxIV.image = UIImage(named: "checkboxOn")
            checkBoxIV.tintColor = UIColor.lightGray
        }else{
            checkBoxIV.image = UIImage(named: "checkboxOff")
            checkBoxIV.tintColor = UIColor.lightGray
        }
        
        if category.subCategories.count > 0 {
            forwardBtn.isHidden = false
        }else{
            forwardBtn.isHidden = true
        }
    }
}

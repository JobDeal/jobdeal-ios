//
//  SpinerTableViewCell.swift
//  JobDeal
//
//  Created by Priba on 3/13/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class SpinerTableViewCell: UITableViewCell {

    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        spiner.tintColor = UIColor.mainColor1
        spiner.startAnimating()
    }

}

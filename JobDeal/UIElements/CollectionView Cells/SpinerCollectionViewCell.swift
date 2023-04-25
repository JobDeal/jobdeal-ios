//
//  SpinerCollectionViewCell.swift
//  JobDeal
//
//  Created by Priba on 3/21/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class SpinerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spinerView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        spinerView.tintColor = UIColor.mainButtonColor
    }
    
}

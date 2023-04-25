//
//  AllJobBidTableViewCell.swift
//  JobDeal
//
//  Created by Priba on 2/11/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos
import ImageViewer

class AllJobBidTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var bidCurrencyLbl: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var userRate: CosmosView!
    @IBOutlet weak var lowerBidView: UIView!
    @IBOutlet weak var lowerBidLabel: UILabel!
    @IBOutlet weak var lowerBidViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lowerBidLabelHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    private var galleryController: GalleryViewController?
    private var imageGalleryItem: GalleryItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Pin Image
        pinImage.tintColor = UIColor.darkGray
        
        // Holder View
        holderView.backgroundColor = UIColor.white
        holderView.layer.cornerRadius = 8
        holderView.layer.applySketchShadow()
        
        // User Image
        userImage.setHalfCornerRadius()
        userImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userImageTapped(gestureRecognizer:)))
        userImage.addGestureRecognizer(tapGesture)
        
        // User Rate
        userRate.isUserInteractionEnabled = false
        
        // Lower Bid
        lowerBidView.layer.cornerRadius = 8
        lowerBidView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        lowerBidLabel.setupTitleForKey(key: "lower_bid_offer", uppercased: true)
        
        selectionStyle = .none
    }

    func populateWith(bid: BidModel) {
        userImage.sd_setImage(with: URL(string: bid.bidUser.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)

        if bid.choosed {
            indicatorImageView.tintColor = UIColor.mainButtonColor
        } else {
            indicatorImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.9)
        }
        userRate.rating = bid.bidUser.doerRating
        userNameLbl.text = bid.bidUser.name
        cityLbl.text = bid.bidUser.city
        bidCurrencyLbl.text = bid.getFullPrice()
        
        if bid.bidPrice < bid.bidJob.price {
            lowerBidView.isHidden = false
            lowerBidLabel.isHidden = false
            lowerBidViewHeightConstraint.constant = 30
            lowerBidLabelHeightConstraint.constant = 20
        } else {
            lowerBidView.isHidden = true
            lowerBidLabel.isHidden = true
            lowerBidViewHeightConstraint.constant = 0
            lowerBidLabelHeightConstraint.constant = 0
        }
    }
    
    @objc func userImageTapped(gestureRecognizer: UIGestureRecognizer) {
        imageGalleryItem = GalleryItem.image(fetchImageBlock: { [weak self] (imageCompletion) in
            guard let self = self else { return }
            
            imageCompletion(self.userImage.image)
            self.imageGalleryItem = nil
        })
        
        galleryController = GalleryViewController(startIndex: 0,
                                                       itemsDataSource: self,
                                                       itemsDelegate: nil,
                                                       displacedViewsDataSource: nil,
                                                       configuration: Utils.getCommonGalleryConfiguration())
        
        parentViewController?.presentImageGallery(self.galleryController!)
    }
}

// MARK: - GalleryItemsDataSource
extension AllJobBidTableViewCell: GalleryItemsDataSource {
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imageGalleryItem!
    }
}

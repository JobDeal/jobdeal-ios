//
//  BuyerProfileViewController.swift
//  JobDeal
//
//  Created by Bojan Markovic  on 14.12.21..
//  Copyright © 2021 Qwertify. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import SDWebImage
import MessageUI

final class BuyerProfileViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var buyerHolderView: UIView!
    @IBOutlet private weak var buyerAvatarImageView: UIImageView!
    @IBOutlet private weak var buyerNameLabel: UILabel!
    @IBOutlet private weak var buyerLocationLabel: UILabel!
    @IBOutlet private weak var buyerLocationPinImageView: UIImageView!
    @IBOutlet private weak var aboutBuyerTextView: UITextView!
    @IBOutlet private weak var buyerRateView: CosmosView!
    @IBOutlet private weak var buyerRateCountLabel: UILabel!
    @IBOutlet private weak var callBuyerButton: UIButton!
    @IBOutlet private weak var messageBuyerButton: UIButton!
    @IBOutlet private weak var buttonsHolderViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties
    var offer: OfferModel?
    
    // MARK: - Overriden Methods
    override func setupUI() {
        // Navigation Bar
        setupNavigationBar(title: "", withGradient: true)
        
        // View
        view.backgroundColor = .separatorColor
        
        // Buyer Holder View
        buyerHolderView.layer.cornerRadius = 10
        buyerHolderView.layer.applySketchShadow()
        
        // Buyer Name Label
        buyerNameLabel.text = offer?.user.getUserFullName()
        
        // Buyer Location Label
        buyerLocationLabel.text = offer?.user.city
        
        // Buyer Location Image
        buyerLocationPinImageView.tintColor = .darkGray
        
        // Buttons Holder View
        buttonsHolderViewHeightConstraint.constant = Utils.hasNotch() ? 80 : 60
        
        // Buyer Rate View
        buyerRateView.isUserInteractionEnabled = false
        buyerRateView.rating = offer?.user.buyerRating ?? 0.0
        
        // Buyer Count Label
        buyerRateCountLabel.text = offer?.user.getUserBuyerRatingString()
        
        // About Buyer Text View
        aboutBuyerTextView.text = offer?.user.aboutMe
        aboutBuyerTextView.isEditable = false
        
        // Buyer Avatar Image View
        buyerAvatarImageView.setHalfCornerRadius()
        if let buyerAvatarUrl = offer?.user.avatar {
            buyerAvatarImageView.sd_setImage(with: URL(string: buyerAvatarUrl),
                                             placeholderImage: UIImage(named: "avatar1"),
                                             options: .refreshCached,
                                             completed: nil)
        }
    }
    
    override func setupStrings() {
        callBuyerButton.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "call_buyer"), for: .normal)
        messageBuyerButton.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "message_buyer"), for: .normal)
    }
}

// MARK: - Actions
private extension BuyerProfileViewController {
    @IBAction func callBuyerButtonAction(_ sender: UIButton) {
        guard let mobile = offer?.user.mobile,
              let number = URL(string: "tel://" + mobile) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func messageBuyerButtonAction(_ sender: UIButton) {
        guard let mobile = offer?.user.mobile, let offer = offer else { return }
        
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Job Deal - \(offer.name) #\(offer.id)"
            controller.recipients = [mobile]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension BuyerProfileViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

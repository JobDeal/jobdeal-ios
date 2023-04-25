//
//  ChooseDoerConfirmationViewController.swift
//  JobDeal
//
//  Created by Bojan Markovic on 04/03/2021.
//  Copyright © 2021 Priba. All rights reserved.
//

import UIKit
import TransitionButton

protocol ChooseDoerConfirmationDelegate: class {
    func didConfirmDoer(helpOnTheWay: Bool)
}

class ChooseDoerConfirmationViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var confirmButton: TransitionButton!
    
    // MARK: - Public Properties
    weak var delegate: ChooseDoerConfirmationDelegate?
    var bid: BidModel!
    
    // MARK: - Overridden Methods
    override func setupUI() {
        holderView.layer.cornerRadius = 10
        closeButton.tintColor = UIColor.black
        confirmButton.setupForTransitionLayoutTypeBlack()
        
        let visualEffectView  = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        self.view.insertSubview(visualEffectView, at: 0)
    }
    
    override func setupStrings() {
        titleLabel.text = LanguageManager.sharedInstance.getStringForKey(key: "choose_doer_confirmation_title")
        descriptionLabel.text = LanguageManager.sharedInstance.getStringForKey(key: "choose_doer_confirmation_description")
        confirmButton.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "choose_doer_confirmation_confirm_button"),
                                                                        for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.didConfirmDoer(helpOnTheWay: true)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissViewControllerAction() {
        dismiss(animated: true, completion: nil)
    }
}

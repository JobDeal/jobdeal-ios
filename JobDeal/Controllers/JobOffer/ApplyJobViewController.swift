//
//  ApplyJobViewController.swift
//  JobDeal
//
//  Created by Priba on 4/15/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton
import Device

class ApplyJobViewController: BaseViewController,UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bidTitleLbl: UILabel!
    @IBOutlet weak var bidDescLbl: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var centralHorisontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendOfferBtn: TransitionButton!
    
    // MARK: - Public Properties
    var offer = OfferModel()
    
    // MARK: - Overridden Methods
    override func setupUI() {
        sendOfferBtn.setupForTransitionLayoutTypeBlack()
        sendOfferBtn.backgroundColor = UIColor.mainColor1
        backView.layer.cornerRadius = 10
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        self.view.insertSubview(visualEffectView, at: 0)
        
        if Device.size() < .screen4_7Inch {
            sendOfferBtn.titleLabel?.font = sendOfferBtn.titleLabel?.font.withSize(12)
        }
    }
    
    override func setupStrings() {
        sendOfferBtn.setupTitleForKey(key: "send_my_offer", uppercased: true)
        bidTitleLbl.setupTitleForKey(key: "my_bid", uppercased: true)
        bidDescLbl.setupTitleForKey(key: "my_bid_tip")
    }
    
    override func loadData() {
        priceTextField.placeholder = String(offer.getFullPrice())
    }
    
    // MARK: - Actions
    @IBAction func sendBidBtnAction(_ sender: Any) {
        sendOfferBtn.startAnimation()
        self.view.endEditing(true)
        
        ServerManager.sharedInstance.applyForJob(jobOffer: self.offer, price: priceTextField.text!) { (response, success, errMsg) in
            self.sendOfferBtn.stopAnimation()
            
            if success! {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applyedForJobNotification"), object: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: errMsg, completion: { (index, str) in
                    
                })
            }
        }
    }
    
    @objc func dismissViewControllerAction() {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Notifications
    override func keyboardWillChangeFrame(notification: NSNotification) {
        let frame = self.view.frame.size
        let constant: CGFloat = 50
        let newYPosition: CGFloat = -1 * abs(frame.height - constant - 667)
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = newYPosition
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.priceTextField.text = self.priceTextField.text
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


//
//  RateViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/29/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos
import TransitionButton
import KMPlaceholderTextView

final class RateViewController: BaseViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageSlider: CPImageSlider!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var rateView: CosmosView!
    @IBOutlet private weak var rateButton: TransitionButton!
    @IBOutlet private weak var commentTextView: KMPlaceholderTextView!
    @IBOutlet private weak var bottomRateButtonConstraint: NSLayoutConstraint!
    
    // MARK: - Public Properties
    var offer = OfferModel()
    var ratingDoer = false
    var ratingUser = UserModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackTapDissmisKeyboardGesture()
        if Utils.isIphoneSeriesX() {
            scrollViewTopConstraint.constant = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        }
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        imageSlider.enablePageIndicator = false
        imageSlider.backgroundColor = .lightGray
        
        let array: [String] = [offer.mainImage]
        imageSlider.allowCircular = false
        imageSlider.enableSwipe = true
        imageSlider.sliderType = .urlType
        imageSlider.urlArray = array
        
        let borderGray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        commentTextView.layer.borderColor = borderGray.cgColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.cornerRadius = 5
        
        rateButton.setupForTransitionLayoutTypeBlack()
        userImageView.setHalfCornerRadius()
    }
    
    override func setupStrings() {
        rateButton.setupTitleForKey(key: "rate", uppercased: true)
        if !ratingDoer {
            infoLabel.text = ratingUser.getUserFullName() + " " + LanguageManager.sharedInstance.getStringForKey(key: "as_buyer" )
            self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "rate_buyer", uppercased: true), withGradient: true)
        }
        else {
            infoLabel.text = ratingUser.getUserFullName() + " " + LanguageManager.sharedInstance.getStringForKey(key:"as_doer" )
            self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "rate_doer", uppercased: true), withGradient: true)
        }
        commentTextView.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "rate_comment")
    }
    
    override func loadData() {
        userImageView.sd_setImage(with: URL(string: ratingUser.avatar), placeholderImage: UIImage(named: "imagePlaceholder"), options: .fromCacheOnly) { _, _, _ in }
    }
    
    // MARK: - Helper Methods
    private func validateInputs() -> Bool {
        if self.rateView.rating == 0 {
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "rating_missing"), completion: { (index, str) in
            })
            return false
        }
        
        if self.commentTextView.isInputInvalid() {
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "rating_message_missing"), completion: { (index, str) in
            })
            return false
        }
        
        return true
    }
    
    // MARK: - Actions
    @IBAction func rateBuyer(_ sender: Any) {
        if validateInputs() {
            rateButton.startAnimation()
            
            ServerManager.sharedInstance.rateUser(
                rating: rateView.rating,
                user: ratingUser,
                job: offer,
                comment: commentTextView.trimmedString()!,
                rateBuyer: !ratingDoer
            ) { (response, success, errMsg) in
                self.rateButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.1, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            commentTextView.endEditing(true)
            return false
        }
        return true
    }
    
    // MARK: - Keyboard Notifications
    override func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let keyboardConstant: CGFloat = 8
            self.bottomRateButtonConstraint.constant = keyboardHeight + keyboardConstant
            var constant: CGFloat = 190
            
            let frame = self.view.frame.size
            
            if Utils.isIphoneSeriesX() {
                constant = -16
            }
            
            if UIApplication.shared.keyWindow!.frame.height <= CGFloat(568.0) {
                constant = 154
            }
            
            let newYPosition: CGFloat = -1 * abs(frame.height - constant - 667)
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = newYPosition
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.bottomRateButtonConstraint.constant = 24
        }
    }
}



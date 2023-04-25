//
//  ReportJobViewController.swift
//  JobDeal
//
//  Created by Priba on 6/3/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton
import IHProgressHUD

class ReportJobViewController: BaseViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bidTitleLbl: UILabel!
    @IBOutlet weak var bidDescLbl: UILabel!
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var centralHorisontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: TransitionButton!
    
    // MARK: - Public Properties
    var offer = OfferModel()
    
    // MARK: - Overridden Methods
    override func setupUI() {
        sendBtn.setupForTransitionLayoutTypeBlack()
        sendBtn.backgroundColor = UIColor.mainColor1
        backView.layer.cornerRadius = 10
        
        reportTextView.layer.borderColor = UIColor.separatorColor.cgColor
        reportTextView.layer.borderWidth = 1.5
        reportTextView.layer.cornerRadius = 12
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        self.view.insertSubview(visualEffectView, at: 0)
        
    }
    
    override func setupStrings() {
        sendBtn.setupTitleForKey(key: "send_report", uppercased: true)
        bidTitleLbl.setupTitleForKey(key: "report", uppercased: true)
        bidDescLbl.setupTitleForKey(key: "report_description")
        reportTextView.text = LanguageManager.sharedInstance.getStringForKey(key: "report_default_text")
    }
    
    override func loadData() {
    }
    
    // MARK: - Actions
    @IBAction func sendAction(_ sender: Any) {
        
        sendBtn.startAnimation()
        self.view.endEditing(true)
        
        var reportText = ""
        if reportTextView.text != LanguageManager.sharedInstance.getStringForKey(key: "report_description") {
            reportText = reportTextView.text
        }
        
        IHProgressHUD.set(defaultMaskType: .gradient)
        IHProgressHUD.set(defaultStyle: .dark)
        IHProgressHUD.set(ringThickness: 3)
        IHProgressHUD.set(foregroundColor: UIColor.mainColor1)
        
        IHProgressHUD.show()
        
        ServerManager.sharedInstance.reportJob(reportText: reportText, reportUser: DataManager.sharedInstance.loggedUser, reportedJob: self.offer) { (response, success, errMsg) in
            IHProgressHUD.dismiss()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "jobReported"), object: nil)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func dismissViewControllerAction() {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Notifications
    override func keyboardWillChangeFrame(notification: NSNotification) {
        let frame = self.view.frame.size
        let constant: CGFloat = 90
        let newYPosition: CGFloat = -1 * abs(frame.height - constant - 667)
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = newYPosition
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.reportTextView.text = self.reportTextView.text
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == LanguageManager.sharedInstance.getStringForKey(key: "report_description") || textView.text.isEmpty {
            textView.text = ""
            textView.textColor = .black
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = LanguageManager.sharedInstance.getStringForKey(key: "report_description")
            textView.textColor = .lightGray
        }
    }
}

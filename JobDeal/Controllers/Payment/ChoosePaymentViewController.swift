//
//  ChoosePaymentViewController.swift
//  JobDeal
//
//  Created by Priba on 3/18/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

protocol ChoosePaymentDelegate: class {
    func chosenKlarna()
    func chosenSwish()
}

enum PriceCalculationType: Int {
    case payList = 1
    case payBoost
    case paySpeedy
    case payBoostSpeedy
    case payChoose
    case payUnderBidderList = 7
}

enum PaymentOptions: String {
    case klarna = "Klarna"
    case swish = "Swish"
}

class ChoosePaymentViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var largePriceLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var klarnaBtn: UIButton!
    @IBOutlet weak var swishBtn: UIButton!
    
    // MARK: - Public Properties
    weak var delegate: ChoosePaymentDelegate?
    
    var job: OfferModel!
    var type: PriceCalculationType!
    var applicant: UserModel!
    var dismissOnTap = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        klarnaBtn.isHidden = true
        swishBtn.isHidden = true
        
        titleLbl.setupTitleForKey(key: "payment_required")
        
        largePriceLbl.text = ""
        messageLbl.text = ""
        descriptionLabel.text = ""
        
        guard let type = type else { return }
        switch type {
        case .payList:
            messageLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "pay_for_list")
        case .payBoost:
            messageLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "pay_boost")
        case .paySpeedy:
            messageLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "pay_speedy")
        case .payBoostSpeedy:
            messageLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "pay_boost_and_speedy")
        case .payChoose:
            messageLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "pay_choosing_doer")
        case .payUnderBidderList:
            messageLbl.text = ""
        }
        
        holderView.layer.cornerRadius = 10
        
        klarnaBtn.setHalfCornerRadius()
        klarnaBtn.layer.borderColor = UIColor.lightGray.cgColor
        klarnaBtn.layer.borderWidth = 2
        
        swishBtn.setHalfCornerRadius()
        swishBtn.layer.borderColor = UIColor.lightGray.cgColor
        swishBtn.layer.borderWidth = 2
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if dismissOnTap {
            visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        }
        self.view.insertSubview(visualEffectView, at: 0)
        
        handlePriceCalculation()
    }
    
    // MARK: - Helper Methods
    private func handlePriceCalculation() {
        var params: [String : Any] = ["job" : job.toDictionary(), "type" : type.rawValue]
        if applicant != nil {
            params["applicant"] = applicant.toDictionary()
        }
        ServerManager.sharedInstance.priceCalculation(params: params) { (response, success, error) in
            if let success = success, success {
                if let price = response["price"] as? Float {
                    self.largePriceLbl.text = "\(price)"
                }
                if let descriptionText = response["descriptionText"] as? String {
                    self.descriptionLabel.text = descriptionText
                }
                if let currency = response["currency"] as? String {
                    self.largePriceLbl.text! = self.largePriceLbl.text! + " " + currency
                }
                
                var isSwishPaymentAllowed = false
                var isKlarnaPaymentAllowed = false
                if let paymentOptions = response["paymentOptions"] as? [[String : Any]] {
                    for paymentOption in paymentOptions {
                        if let name = paymentOption["name"] as? String {
                            if name == PaymentOptions.swish.rawValue {
                                isSwishPaymentAllowed = true
                                self.swishBtn.isHidden = false
                                continue
                            }
                            if name == PaymentOptions.klarna.rawValue {
                                isKlarnaPaymentAllowed = true
                                self.klarnaBtn.isHidden = false
                                continue
                            }
                        }
                    }
                    
                    if !isSwishPaymentAllowed {
                        self.swishBtn.removeFromSuperview()
                    }
                    if !isKlarnaPaymentAllowed {
                        self.klarnaBtn.removeFromSuperview()
                    }
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func klarnaBntAction(_ sender: Any) {
        delegate?.chosenKlarna()
    }
    
    @IBAction func swishBtnAction(_ sender: Any) {
        delegate?.chosenSwish()
    }
    
    @objc func dismissViewControllerAction() {
        dismiss(animated: true, completion: nil)
    }
}

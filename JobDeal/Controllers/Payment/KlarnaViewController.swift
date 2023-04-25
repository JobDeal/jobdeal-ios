//
//  KlarnaViewController.swift
//  JobDeal
//
//  Created by Priba on 3/18/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import KlarnaCheckoutSDK
import TransitionButton

protocol KlarnaPaymentDelegate: class {
    func didFinishWithSuccess(payment:PaymentModel)
    func didFinishWithFailure(errorMessage: String)
}

enum PaymentType {
    case unlockList
    case chooseDoer
    case boost
    case speedy
    case speedyAndBoost
    case subscription
    case underBidderList
}

class KlarnaViewController: BaseViewController, KCOCheckoutSizingDelegate {
    weak var delegate: KlarnaPaymentDelegate?
    
    var paymentType: PaymentType = .unlockList
    var payment = PaymentModel()
    
    var targetJob = OfferModel()
    var targetBid = BidModel()
    
    var checkout = KCOKlarnaCheckout()
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var completeBtn: TransitionButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "klarna", uppercased: true), withGradient: true)
        
        completeBtn.setupTitleForKey(key: "complete", uppercased: true)
        completeBtn.setupForTransitionLayoutTypeBlack()
        completeBtn.backgroundColor = .mainColor1
        completeBtn.setTitleColor(.white, for: .normal)
        completeBtn.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: NSNotification.Name.KCOSignal, object: nil)
        startLoading()
    }
    
    override func backBtnAction() {
        super.backBtnAction()
        if payment.id > 0 {
            delegate?.didFinishWithSuccess(payment: self.payment)
        }
    }

    func startLoading() {
        self.presentLoader()
        
        var type = 0
        
        switch paymentType {
            case .unlockList: type = 1
            case .boost: type = 2
            case .speedy: type = 3
            case .speedyAndBoost: type = 4
            case .underBidderList: type = 7
            
        default:
            break
        }
        
        if paymentType == .chooseDoer {
            ServerManager.sharedInstance.klarnaChooseBidPayment(bid: self.targetBid, completition: { (response, success, errMsg) in
                if success! {
                    self.checkout = KCOKlarnaCheckout.init(viewController: self, return: URL(string: "com.jobDeal://main/klarna"))
                    
                    if let checkout = response["html"] as? String, let refId = response["refId"] as? String{
                        self.checkout.setSnippet(checkout)
                        
                        UserDefaults.standard.set(refId, forKey: "lastRefId")
                        
                        let viewController = self.checkout.checkoutViewController
                        viewController?.internalScrollDisabled = false
                        viewController?.sizingDelegate = self
                        viewController?.parentScrollView = self.scrollView
                        self.container.addSubview((viewController?.view)!)
                        
                    } else {
                        self.dismissLoader()
                    }
                    
                } else {
                    self.dismissLoader()
                    AJAlertController.initialization().showAlertWithOkButton(
                        aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                        completion: { _, _ in
                            self.delegate?.didFinishWithFailure(errorMessage: errMsg)
                        }
                    )
                }
            })
        } else if paymentType == .subscription {
            ServerManager.sharedInstance.klarnaSubscriptionPayment(completition: { (response, success, errMsg) in
                
                if success! {
                    
                    self.checkout = KCOKlarnaCheckout.init(viewController: self, return: URL(string: "com.jobDeal://main/klarna"))
                    
                    if let checkout = response["html"] as? String, let refId = response["refId"] as? String{
                        self.checkout.setSnippet(checkout )
                        
                        UserDefaults.standard.set(refId, forKey: "lastRefId")
                        
                        let viewController = self.checkout.checkoutViewController
                        viewController?.internalScrollDisabled = false
                        viewController?.sizingDelegate = self
                        viewController?.parentScrollView = self.scrollView
                        self.container.addSubview((viewController?.view)!)
                        
                    } else {
                        self.dismissLoader()
                    }
                    
                } else {
                    self.dismissLoader()
                    AJAlertController.initialization().showAlertWithOkButton(
                        aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                        completion: { _, _ in
                            self.delegate?.didFinishWithFailure(errorMessage: errMsg)
                    })
                }
            })
            
        } else {
            ServerManager.sharedInstance.klarnaJobPayment(type: type, job: targetJob, completition: { (response, success, errMsg) in
                
                if success! {
                    
                    if let checkout = response["html"] as? String, let refId = response["refId"] as? String {
                        self.checkout = KCOKlarnaCheckout.init(viewController: self, return: URL(string: "com.jobDeal://main/klarna"))

                        self.checkout.setSnippet(checkout)
                        
                        UserDefaults.standard.set(refId, forKey: "lastRefId")
                        
                        let viewController = self.checkout.checkoutViewController

                        viewController?.internalScrollDisabled = false
                        viewController?.sizingDelegate = self
                        viewController?.parentScrollView = self.scrollView

                        self.container.addSubview((viewController?.view)!)

                    } else {
                        self.dismissLoader()
                    }
                } else {
                    self.dismissLoader()
                    AJAlertController.initialization().showAlertWithOkButton(
                        aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                        completion: { _, _ in
                            self.delegate?.didFinishWithFailure(errorMessage: errMsg)
                    })
                }
            })
        }
    }

    func checkoutViewController(_ checkoutViewController: (UIViewController & KCOCheckoutViewControllerProtocol)!, didResize size: CGSize) {
        
        checkoutViewController.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        self.containerHeight.constant = size.height

        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func completeBtnAction(_ sender: Any) {
        super.backBtnAction()
        if payment.id > 0 {
            delegate?.didFinishWithSuccess(payment: self.payment)
        }
    }
    
    @objc func handleNotification(notification: NSNotification){
        let name: String = notification.userInfo?[KCOSignalNameKey] as! String
        if name == "complete" {
            self.presentLoader()
            ServerManager.sharedInstance.klarnaCompletePayment { (response, success, errMsg) in
                self.dismissLoader()
                self.completeBtn.isHidden = false
                if success! {                    
                    if let snippet = response["htmlSnippet"] as? String {
                        self.checkout.setSnippet(snippet)
                        self.payment = PaymentModel(dict: response)
                    }
                }
            }
        } else if name == "checkout" {
            self.dismissLoader()
        }
    }
}

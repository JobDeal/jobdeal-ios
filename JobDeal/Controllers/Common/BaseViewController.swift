//
//  BaseViewController.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import IHProgressHUD
import Toast_Swift
import IQKeyboardManager

class BaseViewController: UIViewController, UIGestureRecognizerDelegate, StoryboardLoadable, ChoosePaymentDelegate {
    
    var isEndOfList = false
    var page = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        setupUI()
        setupStrings()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentSplashLoader), name: Notification.Name(rawValue: "presentSplashLoader"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSplashLoader), name: Notification.Name(rawValue: "dismissSplashLoader"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentSplashAnimationLoader), name: Notification.Name(rawValue: "presentSplashAnimationLoader"), object: nil)
        
        // By default it's disabled, enable in controller where this feature is needed
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(swishComplete), name: Notification.Name(rawValue: "swishComplete"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "swishComplete"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismissSplashLoader"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "presentSplashAnimationLoader"), object: nil)
        
        IQKeyboardManager.shared().isEnabled = false
    }
    
    //MARK: - Private Methods
    func setupUI() {
        // Subclass responsibility
    }
    
    func setupStrings() {
        // Subclass responsibility
    }
    
    func loadData() {
        // Subclass responsibility
    }
    
    func setupBackTapDissmisKeyboardGesture() {
        let backTap = UITapGestureRecognizer(target: self,
                                             action: #selector(dissmissKeyboardGestureAction))
        backTap.cancelsTouchesInView = false
        view.addGestureRecognizer(backTap)
    }
    
    func setupNavigationBar(title:String, withGradient: Bool = false) {
        var padding = 0
        if Utils.isIphoneSeriesX() {
            padding = 24
        }
        
        let barHeight: Int = 70 + padding
        let barWidth: Int = Int(self.view.frame.width)
        
        let barFrame = CGRect.init(x: 0, y: 0, width: barWidth, height: barHeight)
        
        let bar = UIView.init(frame: barFrame)
        bar.backgroundColor = UIColor.clear
        
        if(withGradient) {
            bar.addGradientToBackground()
        }
        
        let label = UILabel.init(frame: CGRect.init(x: Int((barFrame.size.width-200)/2), y: 20 + padding, width: 200, height: 50))
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = title
        label.textAlignment = .center
        label.textColor = UIColor.white
        bar.addSubview(label)
        
        let leftBtn = UIButton.init(frame: CGRect.init(x: 0, y: 20 + padding, width: 50, height: 50))
        leftBtn.tintColor = UIColor.white
        leftBtn.setImage(UIImage.init(named: "backIcon"), for: .normal)
        leftBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        bar.addSubview(leftBtn)
        
        self.view.addSubview(bar)
        
        SideMenuManager.default.menuEnableSwipeGestures = false
    }
    
    func presentLoader() {
        IHProgressHUD.set(defaultMaskType: .gradient)
        IHProgressHUD.set(defaultStyle: .dark)
        IHProgressHUD.set(ringThickness: 3)
        IHProgressHUD.set(foregroundColor: UIColor.mainColor1)
        IHProgressHUD.show()
    }
    
    func presentMidLoader() {
        IHProgressHUD.set(defaultMaskType: .clear)
        IHProgressHUD.set(defaultStyle: .dark)
        IHProgressHUD.set(ringThickness: 3)
        IHProgressHUD.set(foregroundColor: UIColor.mainColor1)
        IHProgressHUD.show()
    }
    
    func dismissLoader() {
        IHProgressHUD.dismiss()
    }
    
    //MARK: - Payment methods
    
    func presentChoosePaymentScreen(job: OfferModel, type: PriceCalculationType, applicant: UserModel? = nil, dismissOnTap: Bool = true) {
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ChoosePaymentViewController") as! ChoosePaymentViewController
        vc.delegate = self
        vc.job = job
        vc.type = type
        vc.applicant = applicant
        vc.dismissOnTap = dismissOnTap
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func presentSubscriptionScreen(price: Float, currency: String, message: String){
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "SubscriptionPopUpViewController") as! SubscriptionPopUpViewController
        vc.delegate = self
        vc.price = price
        vc.currency = currency
        vc.message = message
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func chosenSwish() { }
    
    func chosenKlarna() { }
    
    @objc func dissmissKeyboardGestureAction() {
        self.view.endEditing(true)
    }
    
    @objc func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func presentSplashLoader() {
        if(!(self.navigationController?.viewControllers.last?.isKind(of: SplashViewController.self) ?? false)) {
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc func dismissSplashLoader() {
        if ((self.navigationController?.viewControllers.last?.isKind(of: SplashViewController.self) ?? true)){
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func presentSplashAnimationLoader() {
        if (!(self.navigationController?.viewControllers.last?.isKind(of: SplashAnimationViewController.self) ?? false)) {
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashAnimationViewController") as! SplashAnimationViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    var retryCount = 0
    @objc func swishComplete() {
        if !IHProgressHUD.isVisible() {
            self.presentLoader()
        }
        
        ServerManager.sharedInstance.swishCompletePayment { [self] (response, success, errMsg) in
            let paymentModel = PaymentModel(dict: response)
            if success! {
                if paymentModel.status == "PAID" {
                    self.dismissLoader()
                    AJAlertController.initialization().showAlertWithOkButton(
                        aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "swish_payment_complete"),
                        completion: { _, _ in
                        self.retryCount = 0
                        self.setupUI()
                        self.loadData()
                        self.setupStrings()
                    })
                } else if paymentModel.status == "PENDING" && self.retryCount <= 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.retryCount += 1
                        self.swishComplete()
                    }
                } else {
                    self.dismissLoader()
                    self.retryCount = 0
                    AJAlertController.initialization().showAlertWithOkButton(
                        aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                        completion: { _, _ in })
                }
            } else {
                self.dismissLoader()
                self.retryCount = 0
                AJAlertController.initialization().showAlertWithOkButton(
                    aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                    completion: { _, _ in })
            }
        }
    }
    
    func showTopToast(key: String) {
        var style = ToastStyle()
        style.cornerRadius = 10
        style.messageAlignment = .center
        style.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: key), duration: 2.4, position: .top, title: nil, image: nil, style: style, completion: nil)
    }
    
    // MARK: - KeyBoard Notifications
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

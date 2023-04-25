//
//  MyBidViewController.swift
//  JobDeal
//
//  Created by Priba on 1/9/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import ParallaxHeader
import MXParallaxHeader
import GoogleMaps
import TransitionButton
import Cosmos

class MyBidViewController: BaseViewController, UITextFieldDelegate {
    
    var offer = OfferModel()
    
    @IBOutlet weak var scrollView: MXScrollView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var stoptimeImageView: UIImageView!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var bidTitleLbl: UILabel!
    @IBOutlet weak var bidDescLbl: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var sendOfferBtn: TransitionButton!
    
    @IBOutlet weak var sendBtnBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "my_bid", uppercased: true), withGradient: true)
        
        let imageSlider = CPImageSlider()
        imageSlider.enablePageIndicator = true
        scrollView.parallaxHeader.view = imageSlider
        
        let array: [String] = offer.imagesURLs
        
        imageSlider.allowCircular = false
        imageSlider.enableSwipe = true
        imageSlider.sliderType = .urlType
        imageSlider.urlArray = array
        
        scrollView.parallaxHeader.mode = MXParallaxHeaderMode.center
        let parallaxHeader: MXParallaxHeader = scrollView.parallaxHeader
        parallaxHeader.height = (UIApplication.shared.keyWindow?.frame.size.height)! * 0.4
        parallaxHeader.minimumHeight = 0
        
        self.setupBackTapDissmisKeyboardGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: - Private Methods
    override func setupUI(){
        stoptimeImageView.tintColor = UIColor.darkGray
        locationImageView.tintColor = UIColor.darkGray
        clockImageView.tintColor = UIColor.darkGray
        
        sendOfferBtn.setupForTransitionLayoutTypeBlack()
        sendOfferBtn.backgroundColor = UIColor.mainColor1
        
        if offer.isSpeedy {
            clockImageView.tintColor = UIColor.speedyRedColor
            durationLbl.textColor = UIColor.speedyRedColor
        }

    }
    override func setupStrings(){
        
        sendOfferBtn.setupTitleForKey(key: "send_my_offer", uppercased: true)
        bidTitleLbl.setupTitleForKey(key: "my_bid", uppercased: true)
        bidDescLbl.setupTitleForKey(key: "my_bid_tip")
    }
    
    override func loadData() {
        
        priceLbl.text = String(offer.getFullPrice())
        titleLbl.text = offer.name
        priceTextField.placeholder = String(offer.getFullPrice())
        distanceLbl.text = offer.getDistanceStr()

    }
    
    //MARK: - Button Actions
    
    @IBAction func sendBidBtnAction(_ sender: Any) {
        
        sendOfferBtn.startAnimation()

        ServerManager.sharedInstance.applyForJob(jobOffer: self.offer, price: priceTextField.text!) { (response, success, errMsg) in
            self.sendOfferBtn.stopAnimation()

            if(success!){

                for controller:UIViewController in (self.navigationController?.viewControllers)! {
                    if(controller.isKind(of: DashboardViewController.self)){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applyedForJobNotification"), object: nil)
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
                
            }else{
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: errMsg, completion: { (index, str) in
                    
                })
            }
        }
    }
    
    //MARK: - Keyboard Notifications
    
    override func keyboardWillChangeFrame(notification: NSNotification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let frame = self.view.frame.size
            let constant: CGFloat = 50
            let newYPosition: CGFloat = -1 * abs(frame.height - constant - 667)

            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: false)
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = newYPosition
            }
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        
        self.priceTextField.text = self.priceTextField.text
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}

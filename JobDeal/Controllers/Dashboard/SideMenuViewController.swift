//
//  SideMenuViewController.swift
//  JobDeal
//
//  Created by Priba on 12/26/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import SDWebImage
import PWSwitch
import SafariServices

class SideMenuViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var premiumUserIndicator: UIImageView!

    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var contactUsBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var webSiteBtn: UIButton!
    @IBOutlet weak var tutorialBtn: UIButton!
    
    @IBOutlet weak var myAdsBtn: UIButton!
    @IBOutlet weak var myAdsLabel: UILabel!
    
    @IBOutlet weak var buyerPanelView: UIView!
    
    @IBOutlet weak var homeLbl: UILabel!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var buyerMsgLbl: UILabel!
    
    @IBOutlet weak var appliedJobsLbl: UILabel!
    @IBOutlet weak var appliedJobsCount: UILabel!
    @IBOutlet weak var becomePremiumLbl: UILabel!
    @IBOutlet weak var premiumImageView: UIImageView!
    
    @IBOutlet weak var visitorView: UIView!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var explanationLbl: UILabel!
    @IBOutlet weak var notificationIndicatorView: UIView!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var versionText: UILabel!
    
    // MARK: - Private Properties
    private var buyerGLayer = CAGradientLayer()
    private var doerGLayer = CAGradientLayer()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupStrings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationCountIfNeeded), name: Notification.Name(rawValue: "updateNotificationCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdated), name: NSNotification.Name(rawValue: "userUpdated"), object: nil)
        
        if DataManager.sharedInstance.loggedUser.role == .visitor {
            visitorView.isHidden = false
            buyerPanelView.isHidden = true
            logoutBtn.isHidden = true
            loginBtn.isHidden = false
        } else {
            visitorView.isHidden = true
            buyerPanelView.isHidden = false
            logoutBtn.isHidden = false
            loginBtn.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //loadNotificationCount()
        if DataManager.sharedInstance.loggedUser.notificationCount > 0 {
            notificationIndicatorView.isHidden = false
            notificationCountLbl.text = "\(DataManager.sharedInstance.loggedUser.notificationCount)"
        } else {
            updateNotificationCountIfNeeded()
        }
    }
    


    
  
    
    // MARK: - Private Methods
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addGradientToBackground()
        
        avatarImageView.setHalfCornerRadius()
        avatarImageView.sd_setImage(with: URL(string: DataManager.sharedInstance.loggedUser.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        premiumImageView.tintColor = UIColor.white
        setCounters()
        premiumUserIndicator.isHidden = !DataManager.sharedInstance.loggedUser.isPaid
        
        termsBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        termsBtn.titleLabel?.minimumScaleFactor = 0.5
        
        notificationIndicatorView.setHalfCornerRadius()
        
        versionText.alpha = 0.7
        versionText.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private func addGradientToBackground(view: UIView, gradientLayer: CAGradientLayer?) {
        gradientLayer!.frame = view.bounds
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    private func setupStrings() {
        nameLbl.text = DataManager.sharedInstance.loggedUser.getUserFullName()
    
        contactUsBtn.setupTitleForKey(key: "contuct_us")
        logoutBtn.setupTitleForKey(key: "log_out")
        loginBtn.setupTitleForKey(key: "login_registrer")
        termsBtn.setupTitleForKey(key: "terms_of purchase")
        webSiteBtn.setupTitleForKey(key: "web_site_job_deal")
        tutorialBtn.setupTitleForKey(key: "tutorial")
        
        contactUsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        logoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        termsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        webSiteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        tutorialBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        
       
        homeLbl.setupTitleForKey(key: "home")
        myProfileLabel.setupTitleForKey(key: "my_profile")
        buyerMsgLbl.setupTitleForKey(key: "notifications")
        appliedJobsLbl.setupTitleForKey(key: "applied_jobs")
        becomePremiumLbl.setupTitleForKey(key: "wish_list")
        aboutLbl.setupTitleForKey(key: "about_jobdeal")
        explanationLbl.setupTitleForKey(key: "jobdeal_explanation")
        myAdsLabel.setupTitleForKey(key: "my_ads")
    }
    
    func setCounters() {
        appliedJobsCount.text = ""
    }
    
    // MARK: - Notifications
    @objc func userUpdated() {
        avatarImageView.sd_setImage(with: URL(string: DataManager.sharedInstance.loggedUser.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        setupUI()
        setupStrings()
    }
    
    @objc func updateNotificationCountIfNeeded() {
        if let count = Int(Utils.getNotificationCountString()) {
            if count > 0 {
                notificationIndicatorView.isHidden = false
                notificationCountLbl.text = "\(count)"
                
                return
            }
        }
        notificationIndicatorView.isHidden = true
        notificationCountLbl.text = ""
    }
    
    // MARK: - Actions
    @IBAction func termsBtnAction(_ sender: Any) {
        if let url = NSURL(string: "https://prod.jobdeal.com/terms") {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.safariVC = SFSafariViewController(url: url as URL)
            present(delegate.safariVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        let vc = LoginViewController.instantiate(fromStoryboardNamed: "Main")
        vc.showSplashScreen = false
        self.show(vc, sender: nil)
    }
    
    @IBAction func logOutBtnAction(_ sender: Any) {
        AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "log_out_check"), aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "log_out")) { (index, title) in
            if index == 1 {
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")
                
                let vc = LoginViewController.instantiate(fromStoryboardNamed: "Main")
                vc.showSplashScreen = false
                self.show(vc, sender: nil)
            }
        }
    }
    
    @IBAction func homeBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(Notification(name: Notification.Name("sideMenuNotification"), object: nil, userInfo: ["key" : "home"]))
    }
    
    @IBAction func contactUsBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "ContactUs", bundle: nil).instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // When user click on avatar image in side menu
    @IBAction func profileBtnAction(_ sender: Any) {
        if DataManager.sharedInstance.isUserLoggedIn {
            let vc =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func tutorialBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // When user click on "My profile" item in side menu
    @IBAction func myProfileButtonAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func becomePremiumAction(_ sender: Any) {
        let vc = WishListViewController.instantiate(fromStoryboardNamed: "WishList")
        show(vc, sender: nil)
    }
    
    @IBAction func messageBtn(_ sender: Any) {
        let vc =  UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func appliedJobsBtnAction(_ sender: Any) {
        let vc = UIStoryboard(name: "AppliedJobs", bundle: nil).instantiateViewController(withIdentifier: "AppliedJobsViewController") as! AppliedJobsViewController
        vc.buyerProfile = DataManager.sharedInstance.loggedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myJobsJobsBtnAction(_ sender: Any) {
        let vc = UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "JobBidsViewController") as! JobBidsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapWebSiteButton(_ sender: UIButton) {
        guard let url = URL(string: "https://jobdeal.com") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

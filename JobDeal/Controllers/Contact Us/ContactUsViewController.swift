//
//  ContactUsViewController.swift
//  JobDeal
//
//  Created by Priba on 12/27/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit

class ContactUsViewController: BaseViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var linkedinBtn: UIButton!
    @IBOutlet weak var twiterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "", uppercased: true))
    }
    
    //MARK: - Private Methods
    override func setupUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addGradientToBackground()
    }

    override func setupStrings(){
        
        titleLbl.setupTitleForKey(key: "stay_in_touch", uppercased: true)
        emailLbl.setupTitleForKey(key: "jobdeal_email")
    }
    
    //MARK: - Button Actions
    
    @IBAction func gotofbAction(_ sender: Any) {
        if let url = URL(string: "http://www.facebook.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func gotoLinkedinAction(_ sender: Any) {
        if let url = URL(string: "http://www.linkedin.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func goToTwiterAction(_ sender: Any) {
        if let url = URL(string: "http://www.twitter.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}

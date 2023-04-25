//
//  FinishRegistrationViewController.swift
//  JobDeal
//
//  Created by Priba on 12/13/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import TransitionButton

class FinishRegistrationViewController: BaseViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var termsBtn: UIButton!
    
    @IBOutlet weak var finishBtn: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    
    //MARK: - Private Methods
    override func setupUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addGradientToBackground()
        self.finishBtn.setupForTransitionLayoutTypeBlack()
        
    }
    override func setupStrings(){
        
        titleLbl.setupTitleForKey(key: "congratulations", uppercased: true)
        subtitleLbl.setupTitleForKey(key: "congratulations_subtitle")
        self.finishBtn.setupTitleForKey(key: "finish_registration_button", uppercased: true)
        
    }
    
    //MARK: - Button Actions

    @IBAction func registerBtnAction(_ sender: Any) {
        ServerManager.sharedInstance.addDevice()

        let vc =  UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func termsBtnAction(_ sender: Any)  {
        if let url = URL(string: "https://dev.jobdeal.com/terms"){
            UIApplication.shared.open(url)
           }
    }

}

//
//  ChooseRoleViewController.swift
//  JobDeal
//
//  Created by Priba on 12/12/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import TransitionButton

enum UserRole {
    case buyer
    case doer
    case visitor
}

class ChooseRoleViewController: BaseViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var buttonsTitleLbl: UILabel!
    @IBOutlet weak var buyerBtn: UIButton!
    @IBOutlet weak var doerBtn: UIButton!

    @IBOutlet weak var registerBtn: TransitionButton!
    
    var choosenUserRole: UserRole = .visitor

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "registration", uppercased: true))
    }
    

    //MARK: - Private Methods
    override func setupUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addGradientToBackground()
        self.buyerBtn.setHalfCornerRadius()
        self.doerBtn.setHalfCornerRadius()
        self.buyerBtn.layer.borderWidth = 1
        self.doerBtn.layer.borderWidth = 1
        self.buyerBtn.layer.borderColor = UIColor.clear.cgColor
        self.doerBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.registerBtn.setupForTransitionLayoutTypeBlack()
        
    }
    override func setupStrings(){
        
        titleLbl.setupTitleForKey(key: "role_title")
        self.registerBtn.setupTitleForKey(key: "register", uppercased: true)
        self.buyerBtn.setupTitleForKey(key: "buyer_button", uppercased: true)
        self.doerBtn.setupTitleForKey(key: "doer_button", uppercased: true)
        buttonsTitleLbl.setupTitleForKey(key: "role_buttons_title")
        
    }
    
    //MARK: - Button Actions
    
    @IBAction func buyerBtnAction(_ sender: Any) {
        self.buyerBtn.layer.borderColor = UIColor.white.cgColor
        self.doerBtn.layer.borderColor = UIColor.clear.cgColor
        
        self.choosenUserRole = .buyer
    }
    
    @IBAction func doerBtnAction(_ sender: Any) {
        self.buyerBtn.layer.borderColor = UIColor.clear.cgColor
        self.doerBtn.layer.borderColor = UIColor.white.cgColor
        
        self.choosenUserRole = .doer
    }
    
    @IBAction func registerBtnAction(_ sender: Any) {
        
        if(choosenUserRole == .visitor){
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "empty_role"), completion: { (index, str) in
            })
        }else{
            DataManager.sharedInstance.creatingUser.role = choosenUserRole
            registerBtn.startAnimation()

            ServerManager.sharedInstance.register(creatingUser: DataManager.sharedInstance.creatingUser, completition: { (response, success, error) in
                
                if(success!){
                    
                    if let jwt = response["jwt"] as? String, let userDict = response["user"] as? NSDictionary {
                        UserDefaults.standard.set(jwt, forKey: "authToken")
                        
                        UserDefaults.standard.set(DataManager.sharedInstance.creatingUser.email, forKey: "email")
                        UserDefaults.standard.set(DataManager.sharedInstance.creatingUser.password, forKey: "password")
                        DataManager.sharedInstance.loggedUser = UserModel.init(dict: userDict)
                        
                        if let infoDict = response["info"] as? NSDictionary {
                            DataManager.sharedInstance.info = InfoModel(dict: infoDict)
                        }
                        
                        if let infoDict = response["prices"] as? NSDictionary {
                            DataManager.sharedInstance.prices = PricesModel(dict: infoDict)
                        }
                        
                        self.performSegue(withIdentifier: "toFinishRegistration", sender: nil)

                    }else{
                        
                        if let errMsg = response["message"] as? String {
                            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: errMsg, completion: { (index, str) in
                            })
                        }
                        self.registerBtn.stopAnimation(animationStyle: .normal, completion: {
                        })
                    }
                    
                }else{
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: error, completion: { (index, str) in
                        
                    })
                    self.registerBtn.stopAnimation(animationStyle: .shake, completion: {
                    })
                }
            })
        }
    }

}

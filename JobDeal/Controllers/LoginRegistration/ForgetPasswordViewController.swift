//
//  ForgetPasswordViewController.swift
//  JobDeal
//
//  Created by Priba on 4/16/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton

class ForgetPasswordViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: TweeAttributedTextField!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var sendBtn: TransitionButton!
    @IBOutlet weak var buttonBotConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackTapDissmisKeyboardGesture()
        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "forgot_password").uppercased())
    }
    
    override func setupUI() {
        self.view.addGradientToBackground()
        self.emailTF.setupLayoutV2()
        self.sendBtn.setupForTransitionLayoutTypeBlack()
        coverView.layer.cornerRadius = 10
    }
    
    override func setupStrings() {
        self.emailTF.setPlaceholderForKey(key: "email", textColor: UIColor.textFieldTextColor)
        self.descLbl.setupTitleForKey(key: "forget_pass_description")
        self.sendBtn.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "forget_pass_button_title", uppercased: true), for: .normal)
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        sendBtn.startAnimation()
        
        if(self.validateLoginInputs()){
            
            ServerManager.sharedInstance.forgotPassword(email: emailTF.trimmedString()!) { (response, success, error) in
                
                if(success!){
                    
                    self.sendBtn.stopAnimation(animationStyle: .normal) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }else{
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: error, completion: { (index, str) in
                        
                    })
                    self.sendBtn.stopAnimation(animationStyle: .normal, completion: {
                    })
                }
            }
            
        }else{
            sendBtn.stopAnimation(animationStyle: .shake)
        }
    }
    
    func validateLoginInputs()-> Bool{
        
        if self.emailTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_email")
            
            return false
        }
        else if !Utils.isValidEmail(testStr: self.emailTF.text ?? ""){
            self.showTopToast(key: "email_not_valid")
            
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        sendBtnAction(sendBtn)
        return true
    }
}

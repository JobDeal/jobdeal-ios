//
//  RegistrationViewController.swift
//  JobDeal
//
//  Created by Priba on 12/8/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton
import IQKeyboardManager

class RegistrationViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var emailTF: TweeAttributedTextField!
    @IBOutlet weak var passwordTF: TweeAttributedTextField!
    @IBOutlet weak var repeatPasswordTF: TweeAttributedTextField!
    @IBOutlet weak var addressTF: TweeAttributedTextField!
    @IBOutlet weak var zipCodeTF: TweeAttributedTextField!
    @IBOutlet weak var cityTF: TweeAttributedTextField!
    
    @IBOutlet weak var nextBtn: TransitionButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var isKeyboardUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackTapDissmisKeyboardGesture()
        // To avoid overlapping keyboard over text fields
        IQKeyboardManager.shared().isEnabled = true
    }
    
    //MARK: - Private Methods
    override func setupUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "registration", uppercased: true))
        
        self.view.addGradientToBackground()
        self.emailTF.setupLayoutV2()
        self.passwordTF.setupLayoutV2()
        self.repeatPasswordTF.setupLayoutV2()
        self.addressTF.setupLayoutV2()
        self.zipCodeTF.setupLayoutV2()
        self.cityTF.setupLayoutV2()
        self.coverView.layer.cornerRadius = 10
        self.nextBtn.setupForTransitionLayoutTypeBlack()

    }
    override func setupStrings() {
        self.emailTF.setPlaceholderForKey(key: "email", textColor: UIColor.textFieldTextColor)
        self.passwordTF.setPlaceholderForKey(key: "password", textColor: UIColor.textFieldTextColor)
        self.repeatPasswordTF.setPlaceholderForKey(key: "confirm_password", textColor: UIColor.textFieldTextColor)
        self.addressTF.setPlaceholderForKey(key: "address", textColor: UIColor.textFieldTextColor)
        self.zipCodeTF.setPlaceholderForKey(key: "zip_code", textColor: UIColor.textFieldTextColor)
        self.cityTF.setPlaceholderForKey(key: "city", textColor: UIColor.textFieldTextColor)
        
        //self.nextBtn.setupTitleForKey(key: "verify_bank_id", uppercased: true)
        self.nextBtn.setupTitleForKey(key: "next", uppercased: true)
    }

    func validateRegistrationInputs() -> Bool {
        
//        if self.bankIDTF.isInputInvalid(){
//            self.showTopToast(key: "must_enter_bank_id")
//            return false
//        }else if self.bankIDTF.text!.count < 10{
//            self.showTopToast(key: "bank_id_to_short")
//            return false
//        }else if self.bankIDTF.text!.count > 12{
//            self.showTopToast(key: "bank_id_to_long")
//            return false
//        }else
            
        if self.emailTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_email")
            return false
        }
        else if !Utils.isValidEmail(testStr: self.emailTF.text ?? ""){
            self.showTopToast(key: "email_not_valid")
                return false
        }
        
        if self.passwordTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_password")
            return false
        }
        
        if self.passwordTF.text?.count ?? 7 < 6{
            self.showTopToast(key: "password_lenght_error")
            return false
        }
        
        if self.repeatPasswordTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_confirm_password")
            return false
        }
        
        if self.repeatPasswordTF.text != self.passwordTF.text{
            self.showTopToast(key: "passwords_not_match")
            return false
        }
        
        if self.addressTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_address")
            return false
        }
        
        if self.zipCodeTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_zip")
            return false
        }
        
        if self.cityTF.isInputInvalid(){
            self.showTopToast(key: "must_enter_city")
            return false
            //validated = false
        }
        
        return true
    }

    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

//        if(textField.isEqual(self.bankIDTF)){
//            bankIDTF.hideInfo()
//        }

        if(textField.isEqual(self.emailTF)){
            emailTF.hideInfo()
        }
        
        if(textField.isEqual(self.passwordTF)){
            passwordTF.hideInfo()
        }
        
        if(textField.isEqual(self.repeatPasswordTF)){
            repeatPasswordTF.hideInfo()
        }
        
        if(textField.isEqual(self.zipCodeTF)){
            zipCodeTF.hideInfo()
        }
        
        if(textField.isEqual(self.addressTF)){
            addressTF.hideInfo()
        }
        
        if(textField.isEqual(self.cityTF)){
            cityTF.hideInfo()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.isEqual(self.emailTF)){
            passwordTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.passwordTF)){
            repeatPasswordTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.repeatPasswordTF)){
            addressTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.addressTF)){
            zipCodeTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.zipCodeTF)){
            cityTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.cityTF)){
            self.view.endEditing(true)
        }
        
        return true
    }

    @IBAction func nextBtnAction(_ sender: Any) {
        self.view.endEditing(true)

        if self.validateRegistrationInputs() {
            
            ServerManager.sharedInstance.checkUserMail(email: self.emailTF.trimmedString()!) { (response, success, errMsg) in
                
                if ((response["result"] as? String) != nil) && success! {
                    
                    let result = Bool(response["result"] as! String)
                    
                    if !result! {
                        
                        UserDefaults.standard.set(self.emailTF.trimmedString(), forKey: "kEmail")
                        UserDefaults.standard.set(self.passwordTF.trimmedString(), forKey: "kPassword")
                        
                        DataManager.sharedInstance.creatingUser.email = self.emailTF.trimmedString()!
                        DataManager.sharedInstance.creatingUser.password = self.passwordTF.trimmedString()!
                        DataManager.sharedInstance.creatingUser.address = self.addressTF.trimmedString()!
                        DataManager.sharedInstance.creatingUser.zip = self.zipCodeTF.trimmedString()!
                        DataManager.sharedInstance.creatingUser.city = self.cityTF.trimmedString()!
                        
                        self.performSegue(withIdentifier: "toAboutMe", sender: nil)
                        
                    } else {
                        self.emailTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "email_already_exist"), animated: true)
                    }

                } else {
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                    })
                }
            }
        }
    }
}

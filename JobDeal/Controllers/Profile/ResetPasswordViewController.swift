//
//  ResetPasswordViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/24/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton

class ResetPasswordViewController: BaseViewController,UITextFieldDelegate {

    @IBOutlet weak var restPassword: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var saveBtn: TransitionButton!
    @IBOutlet weak var oldPasswordTF: TweeAttributedTextField!
    @IBOutlet weak var newPasswordTF: TweeAttributedTextField!
    @IBOutlet weak var confirmNewPasswordTF: TweeAttributedTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        self.view.insertSubview(visualEffectView, at: 0)

    }

    override func setupUI() {
        newPasswordTF.setupProfileTFEnabledStyle(placeholderKey: "new_password")
        confirmNewPasswordTF.setupProfileTFEnabledStyle(placeholderKey: "confirm_password")
         oldPasswordTF.setupProfileTFEnabledStyle(placeholderKey: "old_password")
        
        let viewCornerRadius: CGFloat = 8.0
        holderView.layer.cornerRadius = viewCornerRadius
        saveBtn.setupForLayoutTypeBlack()
    }
    
    override func setupStrings() {
        restPassword.setupTitleForKey(key: "reset_password", uppercased: true)
        saveBtn.setupTitleForKey(key: "save_changes", uppercased: true)
    }
    
    @objc func dismissViewControllerAction() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    //MARK: - ValidateNewPasswordInputs
    
    func validateNewPasswordInputs()-> Bool{
        
        var validated = true
        
        let oldPass = UserDefaults.standard.object(forKey: "password") as! String

        if self.oldPasswordTF.isInputInvalid() {
            self.oldPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_password"), animated: true)
            return false
        }
        
        if self.oldPasswordTF.text != oldPass {
            self.oldPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "wrong_old_pass"), animated: true)
            return false
        }
        
        if self.newPasswordTF.text == oldPass {
            self.newPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "password_must_be_different"), animated: true)
            return false
        }
        
        if self.newPasswordTF.text == oldPass {
            self.newPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "password_must_be_different"), animated: true)
            return false
        }
        
        if self.newPasswordTF.text?.count ?? 7 < 6{
            self.newPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "password_lenght_error"), animated: true)
            validated = false
        }
        if self.newPasswordTF.text != self.confirmNewPasswordTF.text{
            self.confirmNewPasswordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "passwords_not_match"), animated: true)
            validated = false
        }
        
        return validated
    }
    
    //MARK: - TexField Delegate Notifications
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if(textField.isEqual(self.newPasswordTF)){
            newPasswordTF.hideInfo()
        }
        
        if(textField.isEqual(self.confirmNewPasswordTF)){
            confirmNewPasswordTF.hideInfo()
        }
   
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.isEqual(self.newPasswordTF)){
            confirmNewPasswordTF.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.confirmNewPasswordTF)){
            self.view.endEditing(true)
        }
        return true
    }
    
    
    //MARK: - Keyboard Notifications
    
    
    override func keyboardWillChangeFrame(notification: NSNotification) {
        
        let frame = self.view.frame.size
        let constant: CGFloat = 80
        let newYPosition: CGFloat = -1 * abs(frame.height - constant - 667)

        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = newYPosition
        }
        
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    //MARK: - Save New password
    
    @IBAction func saveNewPassword(_ sender: Any) {
        
        saveBtn.startAnimation()
        
        if(self.validateNewPasswordInputs()){
            
            self.view.isUserInteractionEnabled = false
            let oldPass = UserDefaults.standard.object(forKey: "password") as! String

            ServerManager.sharedInstance.changePassword(old: oldPass, new: newPasswordTF.trimmedString()!) { (respnse, success, errMsg) in
                self.view.isUserInteractionEnabled = true
                if success! {
                    
                    UserDefaults.standard.set(self.newPasswordTF.trimmedString()!, forKey: "password")
                    self.dismissViewControllerAction()
                    
                } else {
                    self.saveBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5) {
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                        })
                    }
                }
                
            }
        
        } else {
            saveBtn.stopAnimation(animationStyle: .shake)
        }
    }
    
}
        


    


//
//  ProfileViewController.swift
//  JobDeal
//
//  Created by Priba on 12/27/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import TransitionButton
import TweeTextField
import SDWebImage
import KMPlaceholderTextView
import IQKeyboardManager

class ProfileViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var headerBackView: UIView!
    @IBOutlet weak var editAvatarBtn: UIButton!
    
    @IBOutlet weak var statisticBackView: UIView!
    @IBOutlet weak var statisticTitleLbl: UILabel!
    @IBOutlet weak var creationAccountLbl: UILabel!
    
    @IBOutlet weak var postedJobsBackView: UIView!
    @IBOutlet weak var postedJobsTitleLabel: UILabel!
    
    @IBOutlet weak var detailsTitleLbl: UILabel!
    @IBOutlet weak var nameTF: TweeAttributedTextField!
    @IBOutlet weak var surnameTF: TweeAttributedTextField!
    @IBOutlet weak var mobileTF: TweeAttributedTextField!
    @IBOutlet weak var emailTF: TweeAttributedTextField!
    @IBOutlet weak var passwordTF: TweeAttributedTextField!
    @IBOutlet weak var addressTF: TweeAttributedTextField!
    @IBOutlet weak var zipCodeTF: TweeAttributedTextField!
    @IBOutlet weak var cityTF: TweeAttributedTextField!
    @IBOutlet weak var detailsEditBtn: UIButton!
    @IBOutlet weak var detailsBackView: UIView!
    
    @IBOutlet weak var aboutMeBackView: UIView!
    @IBOutlet weak var aboutMeTitleLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: KMPlaceholderTextView!
    @IBOutlet weak var editAboutMeButton: UIButton!
    
    @IBOutlet weak var resetPassBtn: UIButton!
    @IBOutlet weak var saveBtn: TransitionButton!
    
    @IBOutlet weak var deleteAccountBtn: TransitionButton!
    @IBOutlet weak var deleteAccountLabel: UILabel!
    
    
    // MARK: - Private Properties
    private var isUploadingImage = false
    private var doesNextBtnRequested = false
    private var imagePicker = UIImagePickerController()
    
    // MARK: - Public Properties
    var user = DataManager.sharedInstance.loggedUser
    var avatarUrl = DataManager.sharedInstance.loggedUser.avatar
    
    // MARK: - Lifecycle    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        setupBackTapDissmisKeyboardGesture()
        
        // Navigation Bar
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "my_profile", uppercased: true), withGradient: true)
        
        // Scroll View
        scrollBackView.backgroundColor = UIColor.baseBackgroundColor
        
        // Back Views
        let viewsCornerRadius: CGFloat = 8.0
        headerBackView.layer.cornerRadius = viewsCornerRadius
        statisticBackView.layer.cornerRadius = viewsCornerRadius
        postedJobsBackView.layer.cornerRadius = viewsCornerRadius
        detailsBackView.layer.cornerRadius = viewsCornerRadius
        aboutMeBackView.layer.cornerRadius = viewsCornerRadius
        headerBackView.layer.applySketchShadow()
        statisticBackView.layer.applySketchShadow()
        postedJobsBackView.layer.applySketchShadow()
        detailsBackView.layer.applySketchShadow()
        aboutMeBackView.layer.applySketchShadow()

        
        // Avatar Image View
        avatarImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)

        // Header View
        avatarImageView.setHalfCornerRadius()
        
        // Details View
        setTextFieldsDisabled()
        
        // About Me
        aboutMeTextView.setupProfileTVDisabledStyle(text: user.aboutMe)
        
        // Save
        saveBtn.setupForTransitionLayoutTypeBlack()
        
        //deleteAccountBtn.setupForTransitionLayoutDisabled()
        deleteAccountBtn.layer.cornerRadius = 8
        deleteAccountBtn.backgroundColor = UIColor.systemGray
        deleteAccountBtn.setTitleColor(UIColor.white, for: .normal)
        deleteAccountBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    
        
        // Password
        passwordTF.setupProfileTFDisabledStyle(text: "0000000000")
        passwordTF.setRightPaddingPoints(110)
    }
    
    override func setupStrings() {
        nameLbl.text = user.getUserFullName()
        statisticTitleLbl.setupTitleForKey(key: "account_statistic")
        postedJobsTitleLabel.setupTitleForKey(key: "posted_jobs")
        
        creationAccountLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "user_since") + " " + user.createdAt
        detailsTitleLbl.setupTitleForKey(key: "account_details")
        aboutMeTitleLabel.setupTitleForKey(key: "about_me")
        aboutMeTextView.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "about_me_placeholder")
        saveBtn.setupTitleForKey(key: "save_changes", uppercased: true)
        deleteAccountBtn.setupTitleForKey(key: "delete_account", uppercased: true)
        resetPassBtn.setupTitleForKey(key: "reset_password", uppercased: true)
        deleteAccountLabel.setupTitleForKey(key: "delete_account_description");
        deleteAccountLabel.textAlignment = .center
    }
    
    // MARK: - Helper Methods
    private func setTextFieldsDisabled() {
        nameTF.setupProfileTFDisabledStyle(text: user.name)
        surnameTF.setupProfileTFDisabledStyle(text:user.surname )
        mobileTF.setupProfileTFDisabledStyle(text: user.mobile)
        emailTF.setupProfileTFDisabledStyle(text: user.email)
        resetPassBtn.isHidden = true
        addressTF.setupProfileTFDisabledStyle(text: user.address)
        zipCodeTF.setupProfileTFDisabledStyle(text: user.zip)
        cityTF.setupProfileTFDisabledStyle(text: user.city)
    }
    
    private func setTextFieldsEnabled() {
        nameTF.setupProfileTFEnabledStyle(text: user.name, placeholderKey: "name")
        surnameTF.setupProfileTFEnabledStyle(text:user.surname, placeholderKey: "surname")
        mobileTF.setupProfileTFEnabledStyle(text: user.mobile, placeholderKey: "mobile_number")
        emailTF.setupProfileTFEnabledStyle(text: user.email, placeholderKey: "email")
        resetPassBtn.isHidden = false
        addressTF.setupProfileTFEnabledStyle(text: user.address, placeholderKey: "address")
        zipCodeTF.setupProfileTFEnabledStyle(text: user.zip, placeholderKey: "zip_code")
        cityTF.setupProfileTFEnabledStyle(text: user.city, placeholderKey: "city")
    }
    
    private func validateInputs()-> Bool {
        if self.emailTF.isInputInvalid() {
            self.emailTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_email"), animated: true)
            return false
        }
        
        if !Utils.isValidEmail(testStr: self.emailTF.text ?? "") {
            self.emailTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "email_not_valid"), animated: true)
            return false
        }
        
        if self.passwordTF.isInputInvalid() {
            self.passwordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_password"), animated: true)
            return false
        }
        if self.passwordTF.text?.count ?? 7 < 6 {
            self.passwordTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "password_lenght_error"), animated: true)
            return false
        }
        
        if self.addressTF.isInputInvalid() {
            self.addressTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_address"), animated: true)
            return false
        }
        
        if self.zipCodeTF.isInputInvalid() {
            self.zipCodeTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_zip"), animated: true)
            return false
        }
        
        if self.nameTF.isInputInvalid() {
            self.nameTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_name"), animated: true)
            return false
        }
        
        if self.surnameTF.isInputInvalid() {
            self.surnameTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_surname"), animated: true)
            return false
        }
        
        if self.mobileTF.isInputInvalid() {
            self.mobileTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_number"), animated: true)
            return false
        }
        
        if self.cityTF.isInputInvalid() {
            self.cityTF.showInfo(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_city"), animated: true)
            return false
        }
        
        return true
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = .front
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func updateUser() {
        ServerManager.sharedInstance.updateUser(user: user) { (response, success, errMsg) in
            
            if success! {
                
                DataManager.sharedInstance.loggedUser = UserModel(dict: response)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userUpdated"), object: nil)

                self.setTextFieldsDisabled()
                self.detailsEditBtn.setImage(UIImage(named: "icModeEdit"), for: .normal)
                self.navigationController?.popViewController(animated: true)
                self.saveBtn.stopAnimation()
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
                self.saveBtn.stopAnimation()
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.isEqual(self.nameTF) {
            nameTF.hideInfo()
        }
        
        if textField.isEqual(self.surnameTF) {
            surnameTF.hideInfo()
        }
        
        if textField.isEqual(self.mobileTF) {
            mobileTF.hideInfo()
        }
        
        if textField.isEqual(self.emailTF) {
            emailTF.hideInfo()
        }
        
        if textField.isEqual(self.passwordTF) {
            passwordTF.hideInfo()
        }
        
        if textField.isEqual(self.zipCodeTF) {
            zipCodeTF.hideInfo()
        }
        
        if textField.isEqual(self.addressTF) {
            addressTF.hideInfo()
        }
        
        if textField.isEqual(self.cityTF) {
            cityTF.hideInfo()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.nameTF) {
            surnameTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.surnameTF) {
            emailTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.surnameTF) {
            mobileTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.emailTF) {
            passwordTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.passwordTF) {
            addressTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.addressTF) {
            zipCodeTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.zipCodeTF) {
            cityTF.becomeFirstResponder()
        }
        
        if textField.isEqual(self.cityTF) {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    
    // MARK: - Actions
    @IBAction func editAvatarBtnAction(_ sender: Any) {
        
        let alert = UIAlertController(title: LanguageManager.sharedInstance.getStringForKey(key: "avatar_title"), message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "take_new"), style: .default) {
            UIAlertAction in
            self.openCamera()
        }
        
        let gallaryAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "gallery"), style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), style: .cancel) {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editDetailsBtnAction(_ sender: Any) {
        if resetPassBtn.isHidden {
            setTextFieldsEnabled()
            detailsEditBtn.setImage(UIImage(named: "closeIcon"), for: .normal)
        } else {
            setTextFieldsDisabled()
            detailsEditBtn.setImage(UIImage(named: "icModeEdit"), for: .normal)
        }
    }
    
    @IBAction func editAboutMeButtonAction(_ sender: Any) {
        if !aboutMeTextView.isUserInteractionEnabled {
            aboutMeTextView.setupProfileTVEnabledStyle(text: aboutMeTextView.text)
            editAboutMeButton.setImage(UIImage(named: "closeIcon"), for: .normal)
        } else {
            aboutMeTextView.text = user.aboutMe
            editAboutMeButton.setImage(UIImage(named: "icModeEdit"), for: .normal)
            aboutMeTextView.setupProfileTVDisabledStyle(text: aboutMeTextView.text)
        }
    }
    
    @IBAction func statisticBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "MyRole", bundle: nil).instantiateViewController(withIdentifier: "MyRoleViewController") as! MyRoleViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func postedJobsButtonAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "JobBidsViewController") as! JobBidsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func resetPassBtn(_ sender: Any) {
        let vc =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        
        addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        self.view.endEditing(true)

        if validateInputs() {
            
            saveBtn.startAnimation()
            
            if isUploadingImage{
                doesNextBtnRequested = true
            } else {
                doesNextBtnRequested = false
                
                user.name = nameTF.trimmedString()!
                user.surname = surnameTF.trimmedString()!
                user.email = emailTF.trimmedString()!
                user.address = addressTF.trimmedString()!
                user.zip = zipCodeTF.trimmedString()!
                user.city = cityTF.trimmedString()!
                user.avatar = self.avatarUrl
                user.aboutMe = aboutMeTextView.text
                
                if user.mobile != mobileTF.trimmedString() {
                    AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "verification_phone_alert_message"),
                                                                 aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "verification_phone_cancel"),
                                                                 aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "verification_phone_verify")) { (index, title) in
                        if index == 1 {
                            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationViewController") as! CodeVerificationViewController
                            vc.delegate = self
                            vc.phone = self.mobileTF.trimmedString()!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } else {
                    user.mobile = mobileTF.trimmedString()!
                    updateUser()
                }
                
                saveBtn.stopAnimation()
            }
        }
    }
    
    @IBAction func deleteAccountBtnAction(_ sender: Any) {
        AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "delete_account_confirmation"),
                                                     aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"),
                                                     aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "delete_account")) { (index, title) in
            if index == 1 {
                ServerManager.sharedInstance.logOut()
                ServerManager.sharedInstance.deleteAccount()
                
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "password")
                
                
                
                let vc = LoginViewController.instantiate(fromStoryboardNamed: "Main")
                vc.showSplashScreen = false
                self.show(vc, sender: nil)
            }
        }
    }
    
    
    // MARK: - Keyboard Notifications
    override func keyboardWillChangeFrame(notification: NSNotification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    // MARK: - UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = chosenImage
        isUploadingImage = true
        let imgData = chosenImage.jpegData(compressionQuality: 0.7)
        self.saveBtn.startAnimation()
        
        ServerManager.sharedInstance.uploadAvatarImage(imageData: imgData!) { (response, success) in
            
            if success! {
                
                self.saveBtn.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0, completion: {
                })
                
                if let avatarUrl = response["path"] as? String{
                    self.avatarUrl = avatarUrl
                }
                
                
            } else {
                self.saveBtn.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0, completion: {
                })
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
            
            self.isUploadingImage = false
           
            if self.doesNextBtnRequested {
                self.saveBtnAction(self.saveBtn)
            }
            
        }
        
        dismiss(animated:true, completion: nil)
    }
}

// MARK: - CodeVerificationViewControllerDelegate
extension ProfileViewController: CodeVerificationViewControllerDelegate {
    func didVerifyCodeSuccessfully(withUID uid: String) {
        user.mobile = mobileTF.trimmedString()!
        user.uid = uid
        updateUser()
    }
}

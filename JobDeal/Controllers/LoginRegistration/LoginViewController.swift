//
//  LoginViewController.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import TweeTextField
import TransitionButton

class LoginViewController: BaseViewController, UITextFieldDelegate {
        
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginBtnSwitch: UIButton!
    @IBOutlet weak var registrationBtnSwitch: UIButton!
    @IBOutlet weak var welcomeText: UILabel!
    
    @IBOutlet weak var loginBackView: UIView!
    @IBOutlet weak var coverView1: UIView!
    @IBOutlet weak var emailTextField: TweeAttributedTextField!
    @IBOutlet weak var passwordTextField: TweeAttributedTextField!
    
    @IBOutlet weak var loginBtn: TransitionButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var guestBtn: UIButton!
    
    // Registration elements
    @IBOutlet weak var registrationBackView: UIView!
    @IBOutlet weak var coverView2: UIView!
    @IBOutlet weak var nameTextField: TweeAttributedTextField!
    @IBOutlet weak var surnameTextField: TweeAttributedTextField!
    @IBOutlet weak var mobileNumberTextField: TweeAttributedTextField!
    
    @IBOutlet weak var nextBtn: TransitionButton!
        
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var showSplashScreen = true
    
    private var tryCount = 0
    private var counter = 0
    private var isKeyboardUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackTapDissmisKeyboardGesture()
        
        tryCount = 0
        
        if showSplashScreen {
            presentSplashScreenIfNeeded()
        }
        loginSavedUser()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        super.dismissSplashLoader()
    }
    
    //MARK: - Private Methods
    override func setupUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.view.addGradientToBackground()
        
        self.emailTextField.setupLayoutV2()
        self.passwordTextField.setupLayoutV2()
        self.nameTextField.setupLayoutV2()
        self.surnameTextField.setupLayoutV2()
        self.mobileNumberTextField.setupLayoutV2()
        self.loginBtnSwitch.isSelected = true
        
        coverView1.layer.cornerRadius = 10
        coverView2.layer.cornerRadius = 10

        self.nextBtn.setupForTransitionLayoutTypeBlack()
        self.loginBtn.setupForTransitionLayoutTypeBlack()
    }
    
    override func setupStrings() {
        self.emailTextField.setPlaceholderForKey(key: "email", textColor: UIColor.textFieldTextColor)
        self.passwordTextField.setPlaceholderForKey(key: "password", textColor: UIColor.textFieldTextColor)
        self.nameTextField.setPlaceholderForKey(key: "name", textColor: UIColor.textFieldTextColor)
        self.surnameTextField.setPlaceholderForKey(key: "surname", textColor: UIColor.textFieldTextColor)
        self.mobileNumberTextField.setPlaceholderForKey(key: "mobile_number", textColor: UIColor.textFieldTextColor)
        self.welcomeText.setupTitleForKey(key: "hi_there")
        
        self.loginBtnSwitch.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "login", uppercased: true), for: .normal)
        self.registrationBtnSwitch.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "registration", uppercased: true), for:.normal)
        
        self.loginBtn.setupTitleForKey(key: "login", uppercased: true)
        self.forgetPasswordBtn.setupTitleForKey(key: "forget_password")
        self.guestBtn.setupTitleForKey(key: "enter_as_guest")
        self.nextBtn.setupTitleForKey(key: "next", uppercased: true)
        
        self.mobileNumberTextField.text = Utils.getPhoneExtension()
    }
    
    func validateLoginInputs() -> Bool {

        if self.emailTextField.isInputInvalid(){
            self.showTopToast(key: "must_enter_email")
            return false
        } else if !Utils.isValidEmail(testStr: self.emailTextField.text ?? "") {
            self.showTopToast(key: "email_not_valid")
            return false
        }
        
        if self.passwordTextField.isInputInvalid() {
            self.showTopToast(key: "must_enter_password")
            return  false
        }
        
        return true
    }
    
    func validateRegistrationInputs() -> Bool {

        if self.nameTextField.isInputInvalid() {
            self.showTopToast(key: "must_enter_name")

            return false
        }
        
        if self.surnameTextField.isInputInvalid() {
            self.showTopToast(key: "must_enter_surname")
            
            return false
        }
        
        if self.mobileNumberTextField.isInputInvalid() {
            self.showTopToast(key: "must_enter_number")
            
            return false
        }
        
        if !Utils.isValidPhoneNumber(phoneNumber: self.mobileNumberTextField.text ?? "") {
            self.showTopToast(key: "must_enter_valid_number")
            
            return false
        }
        
        return true
    }
    
    func presentSplashScreenIfNeeded() {
        if UserDefaults.standard.integer(forKey: "loaderCounter") < 5 {
            presentSplashAnimationLoader()
        } else {
            presentSplashLoader()
        }
    }
    
    func loginSavedUser() {
        if UserDefaults.standard.object(forKey: "authToken") != nil {
            let username = UserDefaults.standard.object(forKey: "email") as! String
            let password = UserDefaults.standard.object(forKey: "password") as! String
            let timezone = TimeZone.current.identifier
            let country = Utils.getCountryCodeBySim()
            let locale = LanguageManager.sharedInstance.getStringForKey(key: "locale")
            
            ServerManager.sharedInstance.login(username: username,
                                               password: password,
                                               timezone: timezone,
                                               country: country ?? "",
                                               locale: locale) { (response, success, error) in
                
                if (success!) {
                    
                    if let jwt = response["jwt"] as? String, let userDict = response["user"] as? NSDictionary {
                        
                        let formater = DateFormatter()
                        formater.dateFormat = "dd.MM.yyyy HH:mm"
                        UserDefaults.standard.set(formater.string(from: Date()), forKey: "lastLoginDate")
                        
                        UserDefaults.standard.set(jwt, forKey: "authToken")
                        DataManager.sharedInstance.loggedUser = UserModel.init(dict: userDict)
                        
                        ServerManager.sharedInstance.getWishList()
                        
                        if let infoDict = response["info"] as? NSDictionary {
                            DataManager.sharedInstance.info = InfoModel(dict: infoDict)
                        }
                        
                        if let infoDict = response["prices"] as? NSDictionary {
                            DataManager.sharedInstance.prices = PricesModel(dict: infoDict)
                        }
                        ServerManager.sharedInstance.addDevice()
                        if self.showSplashScreen {
                            if UserDefaults.standard.integer(forKey: "loaderCounter") < 5 {
                                let loaderCounter = UserDefaults.standard.integer(forKey: "loaderCounter")
                                UserDefaults.standard.set(loaderCounter + 1, forKey: "loaderCounter")
                                self.pushDashboardVC(constant: 4500)
                            } else {
                                self.pushDashboardVC(constant: 0)
                            }
                        }
                    } else {
                        if self.tryCount < 3 {
                            self.tryCount += 1
                            self.loginSavedUser()
                        } else {
                            self.pushDashboardVC(constant: 0)
                        }
                    }
                } else {
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: error, completion: { [weak self] _, _ in
                        guard let self = self else { return }
                        
                        Utils.cleanupLocalStorage()
                        self.dismissSplashLoader()
                        self.pushDashboardVC(constant: 0)
                    })
                }
            }
        } else {
            // If isn't login enter as a guest
            self.view.endEditing(true)
            let user = UserModel.init()
            user.role = .visitor
            user.name = LanguageManager.sharedInstance.getStringForKey(key: "visitor")
            
            DataManager.sharedInstance.loggedUser = user
            if showSplashScreen {
                if !UserDefaults.standard.bool(forKey: "tutorialShown") {
                    self.pushDashboardVC(constant: 4500, anim: false)
                    self.pushTutorialVC(constant: 4500)
                    UserDefaults.standard.set(true, forKey: "tutorialShown")
                } else {
                    if UserDefaults.standard.integer(forKey: "loaderCounter") < 5 {
                        let loaderCounter = UserDefaults.standard.integer(forKey: "loaderCounter")
                        let final = loaderCounter + 1
                        UserDefaults.standard.set(final, forKey: "loaderCounter")
                        self.pushDashboardVC(constant: 4500)
                    } else {
                        self.pushDashboardVC(constant: 1000)
                    }
                }
            }
        }
    }
    
    // MARK: - Push DashboardAfter
    
    func pushDashboardVC(constant: Int, anim: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(constant)) {
            let vc =  UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            self.navigationController?.pushViewController(vc, animated: anim)
        }
    }
    
    func pushTutorialVC(constant: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(constant)) {
            let vc =  UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }

    //MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.isEqual(self.emailTextField)){
            emailTextField.hideInfo()
        }
        
        if(textField.isEqual(self.passwordTextField)){
            passwordTextField.hideInfo()
        }
        
        if(textField.isEqual(self.nameTextField)){
            nameTextField.hideInfo()
        }
        
        if(textField.isEqual(self.surnameTextField)){
            surnameTextField.hideInfo()
        }
        
        if(textField.isEqual(self.mobileNumberTextField)){
            mobileNumberTextField.hideInfo()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.isEqual(self.emailTextField)){
            passwordTextField.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.passwordTextField)){
            self.view.endEditing(true)
            self.loginBtnAction(self.loginBtn)
        }
        
        if(textField.isEqual(self.nameTextField)){
            surnameTextField.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.surnameTextField)){
            mobileNumberTextField.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.mobileNumberTextField)){
            self.view.endEditing(true)
        }
        
        return true
    }

    //MARK: - Button actions
    
    @IBAction func loginSwitchAction(_ sender: Any) {
        registrationBtnSwitch.isSelected = false
        loginBtnSwitch.isSelected = true
        self.bottomScrollView.scrollRectToVisible(self.loginBackView.frame, animated: true)
        self.view.endEditing(true)

    }
    
    @IBAction func registrationSwithcAction(_ sender: Any) {
        registrationBtnSwitch.isSelected = true
        loginBtnSwitch.isSelected = false
        self.bottomScrollView.scrollRectToVisible(self.registrationBackView.frame, animated: true)
        self.view.endEditing(true)

    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        self.loginBtn.startAnimation()

        if self.validateLoginInputs() {
            
            ServerManager.sharedInstance.login(username: emailTextField.trimmedString()!,
                                               password: passwordTextField.trimmedString()!,
                                               timezone: TimeZone.current.identifier,
                                               country: Utils.getCountryCodeBySim() ?? "",
                                               locale: LanguageManager.sharedInstance.getStringForKey(key: "locale")) { (response, success, error) in
                
                if(success!){
                    
                    if let jwt = response["jwt"] as? String, let userDict = response["user"] as? NSDictionary {
                        
                        let formater = DateFormatter()
                        formater.dateFormat = "dd.MM.yyyy HH:mm"
                        UserDefaults.standard.set(formater.string(from: Date()), forKey: "lastLoginDate")
                        
                        UserDefaults.standard.set(jwt, forKey: "authToken")
                        UserDefaults.standard.set(self.emailTextField.text, forKey: "email")
                        UserDefaults.standard.set(self.passwordTextField.text, forKey: "password")
                        DataManager.sharedInstance.loggedUser = UserModel.init(dict: userDict)
                        
                        ServerManager.sharedInstance.getWishList()
                        
                        if let infoDict = response["info"] as? NSDictionary {
                            DataManager.sharedInstance.info = InfoModel(dict: infoDict)
                        }
                        
                        let vc =  UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                        
                        if let infoDict = response["info"] as? NSDictionary {
                            DataManager.sharedInstance.info = InfoModel(dict: infoDict)
                        }
                        
                        if let infoDict = response["prices"] as? NSDictionary {
                            DataManager.sharedInstance.prices = PricesModel(dict: infoDict)
                        }
                        
                        ServerManager.sharedInstance.addDevice()
                        
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        self.loginBtn.stopAnimation(animationStyle: .shake, completion: {
                        })
                    } else {
                        if let errMsg = response["message"] as? String {
                            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: errMsg, completion: { _, _ in })
                        }
                        self.loginBtn.stopAnimation(animationStyle: .normal, completion: {})
                    }
                    
                } else {
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: error, completion: { _, _ in })
                    self.loginBtn.stopAnimation(animationStyle: .normal, completion: {})
                }
            }
        } else {
            self.loginBtn.stopAnimation(animationStyle: .shake, completion: {})
        }
    }
    
    @IBAction func forgetPasswordBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgetPasswordViewController") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func guestBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        let user = UserModel.init()
        user.role = .visitor
        user.name = "Visitor"
        
        DataManager.sharedInstance.loggedUser = user

        let vc =  UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        nextBtn.startAnimation()
        
        if (self.validateRegistrationInputs()) {
            
            DataManager.sharedInstance.creatingUser.name = self.nameTextField.trimmedString()!
            DataManager.sharedInstance.creatingUser.surname = self.surnameTextField.trimmedString()!
            DataManager.sharedInstance.creatingUser.mobile = self.mobileNumberTextField.trimmedString()!

            nextBtn.stopAnimation(animationStyle: .normal) {
                let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeVerificationViewController") as! CodeVerificationViewController
                vc.delegate = self
                vc.phone = DataManager.sharedInstance.creatingUser.mobile
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            nextBtn.stopAnimation(animationStyle: .shake)
        }
    }
    
    //MARK: - Keyboard Notifications    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - CodeVerificationViewControllerDelegate
extension LoginViewController: CodeVerificationViewControllerDelegate {
    func didVerifyCodeSuccessfully(withUID uid: String) {
        DataManager.sharedInstance.creatingUser.uid = uid
        
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  CodeVerificationViewController.swift
//  JobDeal
//
//  Created by Bojan Markovic on 21/02/2021.
//  Copyright © 2021 Priba. All rights reserved.
//

import UIKit
import TransitionButton

protocol CodeVerificationViewControllerDelegate: class {
    func didVerifyCodeSuccessfully(withUID uid: String)
}

class CodeVerificationViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var codeHeaderLabel: UILabel!
    @IBOutlet private weak var timeRemainingLabel: UILabel!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var nextButton: TransitionButton!
    @IBOutlet private var codeTextFields: [UITextField]!
    
    // MARK: - Private Properties
    private let serverManager = ServerManager.sharedInstance
    
    private static let totalTime = 120 // 2 minutess
    private var codeTimer: Timer!
    private var receiveCodeTime = totalTime
    private var code: String {
        get {
            var code = ""
            codeTextFields.forEach({
                code += $0.text!
            })
            return code
        }
    }
    private var id = 0
    
    // MARK: - Public Properties
    weak var delegate: CodeVerificationViewControllerDelegate?
    var phone: String!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackTapDissmisKeyboardGesture()
        startCountdownTimer()
        
        getVerificationCode()
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        view.addGradientToBackground()
        setNextButtonDisplay(enabled: false)
        setResendButtonDisplay(hidden: true)
        updateTimerLabel()
        for (index, textField) in codeTextFields.enumerated() {
            textField.delegate = self
            textField.tag = index + 1
        }
    }
    
    override func setupStrings() {
        codeHeaderLabel.setupTitleForKey(key: "code_header_label")
        nextButton.setupTitleForKey(key: "next")
    }
    
    // MARK: - Helper Methods
    private func setNextButtonDisplay(enabled: Bool) {
        enabled ? nextButton.setupForTransitionLayoutTypeBlack() : nextButton.setupForLayoutDisabled()
        nextButton.isEnabled = enabled
    }
    
    private func setResendButtonDisplay(hidden: Bool) {
        resendButton.isHidden = hidden
    }
    
    private func startCountdownTimer() {
        codeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            
            if self.receiveCodeTime > 0 {
                self.updateTimerLabel()
            } else {
                self.setResendButtonDisplay(hidden: false)
                self.timeRemainingLabel.isHidden = true
                timer.invalidate()
            }
        })
    }
    
    private func updateTimerLabel () {
        receiveCodeTime -= 1
        
        let minutes = Int(receiveCodeTime) / 60 % 60
        let seconds = Int(receiveCodeTime) % 60
        
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        
        timeRemainingLabel.text = "\(minutesString) : \(secondsString)"
    }
    
    private func getVerificationCode() {
        guard let phone = phone else {
            print("Phone is missing!")
            return
        }
        
        let params: [String : Any] = ["mobile" : phone]
        serverManager.getVerificationCode(params: params) { (response, success, error) in
            if let _ = success, let id = response["id"] as? Int  {
                self.id = id
            } else {
                self.showTopToast(key: "code_request_error_message")
            }
        }
    }
    
    private func verifyCode() {
        guard let phone = phone else {
            print("Phone is missing!")
            return
        }
        
        nextButton.startAnimation()
        let params: [String : Any] = ["mobile" : phone,
                                      "id" : id,
                                      "code" : code]
        serverManager.verifyCode(params: params) { [weak self] (response, success, error) in
            guard let self = self else { return }
            
            self.nextButton.stopAnimation()
            if let success = success, success, let uid = response["uid"] as? String {
                self.delegate?.didVerifyCodeSuccessfully(withUID: uid)
            } else {
                self.showTopToast(key: "code_verify_error_message")
            }
        }
    }
    
    private func updateNextButtonDisplayIfNeeded() {
        var numberOfFilledFields = 0
        codeTextFields.forEach {
            if $0.text!.count > 0 {
                numberOfFilledFields += 1
            }
        }
        if numberOfFilledFields == codeTextFields.count {
            setNextButtonDisplay(enabled: true)
        } else {
            setNextButtonDisplay(enabled: false)
        }
    }
    
    // MARK: - Actions
    @IBAction func nextBtnAction(_ sender: Any) {
        view.endEditing(true)
        verifyCode()
    }
    
    @IBAction func resendBtnAction(_ sender: Any) {
        setResendButtonDisplay(hidden: true)
        timeRemainingLabel.isHidden = false
        // Get verification code again and start timer
        getVerificationCode()
        receiveCodeTime = Self.totalTime
        updateTimerLabel()
        startCountdownTimer()
    }
}

// MARK: - UITextFieldDelegate
extension CodeVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // adding value in text field
        if textField.text!.count < 1  && string.count == 1 && string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            // get next responder
            let nextTag = textField.tag + 1
            let nextResponder = self.view.viewWithTag(nextTag)
            textField.text = string
            nextResponder?.becomeFirstResponder()
            
            updateNextButtonDisplayIfNeeded()
            
            return false
        } else if textField.text!.count >= 1 {
            // deleting value from text field
            if string.count == 0 {
                // get previous responder
                let previousTag = textField.tag - 1
                let previousResponder = self.view.viewWithTag(previousTag)
                textField.text = ""
                previousResponder?.becomeFirstResponder()
            }
            
            updateNextButtonDisplayIfNeeded()
            
            return false
        } else if string.count > 1 || string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            // prevent copy some text which is not number in text field
            return false
        }
        
        DispatchQueue.main.async {
            self.updateNextButtonDisplayIfNeeded()
        }

        return true
    }
}

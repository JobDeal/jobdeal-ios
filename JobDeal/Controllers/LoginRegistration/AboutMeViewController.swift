//
//  AboutMeViewController.swift
//  JobDeal
//
//  Created by Bojan Markovic on 23/02/2021.
//  Copyright © 2021 Priba. All rights reserved.
//

import UIKit
import TransitionButton
import KMPlaceholderTextView

class AboutMeViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet private weak var aboutMeTextView: KMPlaceholderTextView!
    @IBOutlet private weak var nextButton: TransitionButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackTapDissmisKeyboardGesture()
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        view.addGradientToBackground()
        
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "registration", uppercased: true))
        
        aboutMeLabel.text = LanguageManager.sharedInstance.getStringForKey(key: "about_me")
        
        aboutMeTextView.text = ""
        aboutMeTextView.autocorrectionType = .no
        aboutMeTextView.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "about_me_placeholder")
        aboutMeTextView.textColor = .black
        aboutMeTextView.backgroundColor = .white
        aboutMeTextView.layer.cornerRadius = 10
        aboutMeTextView.layer.masksToBounds = true
        
        nextButton.setupForTransitionLayoutTypeBlack()
    }
    
    override func setupStrings() {
        nextButton.setupTitleForKey(key: "next")
    }
    
    // MARK: - Actions
    @IBAction func nextBtnAction(_ sender: Any) {
        DataManager.sharedInstance.creatingUser.aboutMe = aboutMeTextView.text
        performSegue(withIdentifier: "toChooseAvatar", sender: nil)
    }
}

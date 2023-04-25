//
//  ChooseAvatarViewController.swift
//  JobDeal
//
//  Created by Priba on 12/12/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import Foundation
import TransitionButton

class ChooseAvatarViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarTitleLbl: UILabel!
    @IBOutlet weak var takeNewBtn: UIButton!
    @IBOutlet weak var buttonsTitleLbl: UILabel!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var deletePhotoBtn: UIButton!
    
    var isUploadingImage = false
    var doesNextBtnRequested = false

    @IBOutlet weak var nextBtn: TransitionButton!
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "registration", uppercased: true))
    }
    
    //MARK: - Private Methods
    
    override func setupUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addGradientToBackground()
        
        avatarImageView.setHalfCornerRadius()
        chooseBtn.setupForLayoutTypeUnfiled()
        takeNewBtn.setupForLayoutTypeUnfiled()
        
        self.nextBtn.setupForTransitionLayoutTypeBlack()
    }
    
    override func setupStrings(){
        self.nextBtn.setupTitleForKey(key: "next", uppercased: true)
        self.deletePhotoBtn.setupTitleForKey(key: "delete_photo", uppercased: true)
        self.takeNewBtn.setupTitleForKey(key: "take_new", uppercased: true)
        self.chooseBtn.setupTitleForKey(key: "gallery", uppercased: true)
        avatarTitleLbl.setupTitleForKey(key: "avatar_title")
        buttonsTitleLbl.setupTitleForKey(key: "avatat_buttons_title")
    }
    
    func validateInputs() -> Bool {
        
        if  DataManager.sharedInstance.creatingUser.avatar == "" {
            return false
        }
        
        return true
    }
    
    //MARK: - Button Actions
    
    
    @IBAction func registerBtnAction(_ sender: Any) {
        nextBtn.startAnimation()
        
        if isUploadingImage {
            doesNextBtnRequested = true
        } else {
            
            if validateInputs() {
                doesNextBtnRequested = false
                
                DataManager.sharedInstance.creatingUser.role = .buyer

                
                ServerManager.sharedInstance.register(creatingUser: DataManager.sharedInstance.creatingUser, completition: { (response, success, error) in
                    
                    if success! {
                        
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
                            
                        } else {
                            
                            if let errMsg = response["message"] as? String {
                                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: errMsg, completion: { (index, str) in
                                    self.nextBtn.stopAnimation(animationStyle: .shake) {
                                    }
                                })
                            }
                        }
                        
                    } else {
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: error, completion: { (index, str) in
                            self.nextBtn.stopAnimation(animationStyle: .shake) {
                            }
                        })
                    }
                })

            } else {
                self.nextBtn.stopAnimation(animationStyle: .shake) {}
                let message = LanguageManager.sharedInstance.getStringForKey(key: "avatar_mandatory_text")
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: message, completion: { (_, _) in })
            }
        }
    }

    @IBAction func takeNewBtnAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            imagePicker.cameraDevice = .front

            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseImageBtnAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        deletePhotoBtn.isHidden = true
        DataManager.sharedInstance.creatingUser.avatar = ""
        avatarImageView.image = UIImage(named: "avatar1")
    }
    
    //MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = chosenImage
        deletePhotoBtn.isHidden = false
        isUploadingImage = true
        let imgData = chosenImage.jpegData(compressionQuality: 0.7)
        self.nextBtn.startAnimation()
        
        ServerManager.sharedInstance.uploadAvatarImage(imageData: imgData!) { (response, success) in
            
            if(success!){
                if let avatarUrl = response["path"] as? String{
                    DataManager.sharedInstance.creatingUser.avatar = avatarUrl
                }
                self.nextBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2, completion: {
                })
                
            }else{
                
                self.nextBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.2, completion: {
                })
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
            
            self.isUploadingImage = false
            if self.doesNextBtnRequested {
                self.registerBtnAction(self.nextBtn)
            }

        }
        
        dismiss(animated:true, completion: nil)
    }
}


//
//  CreateOfferViewController.swift
//  JobDeal
//
//  Created by Priba on 1/9/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Photos
import GoogleMaps
import TransitionButton
import Cosmos
import PWSwitch
import Toast_Swift
import AssetsPickerViewController
import TweeTextField

protocol CreateOfferDelegate: class {
    func offerCreated(offer: OfferModel)
}
protocol EditofferDelegate {
    func didEditOffer(offer: OfferModel)
}

class CreateOfferViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AssetsPickerViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, AddressSelectionDelegate, CPSliderDelegate, CategorySelectorDelegate, KlarnaPaymentDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageSlider: CPImageSlider!
    @IBOutlet weak var imageSliderHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadedLbl: UILabel!
    @IBOutlet weak var uploadImageBtn: TransitionButton!
    
    @IBOutlet weak var titleTF: TweeAttributedTextField!
    @IBOutlet weak var priceTF: TweeAttributedTextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    @IBOutlet weak var categoryBackView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var mapBackView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet weak var daysBackView: UIView!
    @IBOutlet weak var daysLbl: UILabel!
    
    @IBOutlet weak var stwIcon1: UIImageView!
    @IBOutlet weak var speedyJobLbl: UILabel!
    @IBOutlet weak var speedyJobTipLbl: UILabel!
    @IBOutlet weak var speedySwitch: PWSwitch!
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var separator3: UIView!
    
    @IBOutlet weak var stwIcon2: UIImageView!
    @IBOutlet weak var boostLbl: UILabel!
    @IBOutlet weak var boostTipLbl: UILabel!
    @IBOutlet weak var boostSwitch: PWSwitch!
    
    @IBOutlet weak var deliveryIcon: UIImageView!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveryTipLabel: UILabel!
    @IBOutlet weak var deliverySwitch: PWSwitch!
    
    @IBOutlet weak var addOfferBtn: TransitionButton!
    @IBOutlet weak var editOfferBtn: TransitionButton!
    
    @IBOutlet weak var dayPickerBackView: UIView!
    @IBOutlet weak var dayPicker: UIDatePicker!
    @IBOutlet weak var dayPickerTitleLbl: UILabel!
    @IBOutlet weak var applyDayPickerBtn: TransitionButton!
    @IBOutlet weak var dayPickerBotConstraint: NSLayoutConstraint!
    
    var imagePicker = UIImagePickerController()
    var uploadingImagesArray = [UploadingImage]()
    var imageUrl = ""
    var addressStr = ""
    var marker = GMSMarker()
    var selectedCoord: CLLocationCoordinate2D?
    
    var doesAddBtnRequested = false
    var delegateEdit: EditofferDelegate?
    var createdOffer = OfferModel()
    var isEditingJobOffer = false
    var selectedIndexPath: IndexPath?
    var duration = ""
    
    var expDateStr = ""
    
    var selectedCategory = DataManager.sharedInstance.selectedCategory


    weak var delegate: CreateOfferDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageSlider.delegate = self
        
        uploadImageBtn.spinnerColor = UIColor.darkGray
        uploadImageBtn.setupForTransitionLayoutTypeUpload()
        
        if Utils.isIphoneSeriesX() {
            scrollViewTopConstraint.constant = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        }
    }
    
    override func setupUI() {
        checkIfJobIsEditing()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icPlaceCopy")
        imageView.tintColor = UIColor.darkGray
        marker.iconView = imageView
        
        uploadImageBtn.setHalfCornerRadius()
        
        titleTF.setupForDarkLayout()
        descriptionTV.setupForDarkLayout()
        priceTF.setupForDarkLayout()
        
        categoryBackView.setupDarkLayout()
        mapBackView.setupDarkLayout()
        daysBackView.setupDarkLayout()
        locationIcon.tintColor = UIColor.darkGray
        stwIcon1.tintColor = UIColor.darkGray
        separator1.backgroundColor = UIColor.separatorColor

        stwIcon2.tintColor = UIColor.darkGray
        separator2.backgroundColor = UIColor.separatorColor
        
        deliveryIcon.tintColor = .darkGray
        separator3.backgroundColor = .separatorColor

        addOfferBtn.setupForTransitionLayoutTypeBlack()
        editOfferBtn.setupForTransitionLayoutTypeBlack()
        
        dayPickerBackView.layer.applySketchShadow()
        applyDayPickerBtn.setupForTransitionLayoutTypeBlack()

        if DataManager.sharedInstance.loggedUser.locale == "se"{
            dayPicker.locale = Locale.init(identifier: "sv_SE")
        }
        
        if #available(iOS 13.4, *) {
            dayPicker.preferredDatePickerStyle = .wheels
        }
        dayPicker.minimumDate = Date()
    }
    
    override func loadData() {
        // This means that payment with Swish was successful so dismiss the payment dialog, return to the dashboard and notify that job created successfully
        if navigationController?.visibleViewController is ChoosePaymentViewController {
            navigationController?.dismiss(animated: true, completion: { })
        }
    }
    
    override func setupStrings(){
        checkImageLbl()
        
        titleTF.attributedPlaceholder = NSAttributedString(string: LanguageManager.sharedInstance.getStringForKey(key: "job_name"),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        priceTF.attributedPlaceholder = NSAttributedString(string: LanguageManager.sharedInstance.getStringForKey(key: "price"),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        titleTF.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "job_name")
        priceTF.placeholder = LanguageManager.sharedInstance.getStringForKey(key: "price")
        
        speedyJobLbl.setupTitleForKey(key: "speedy_job")
        speedyJobTipLbl.setupTitleForKey(key: "speedy_job_hint")
        boostLbl.setupTitleForKey(key: "boost_job")
        boostTipLbl.setupTitleForKey(key: "boost_job_hint")
        deliveryLabel.setupTitleForKey(key: "delivery_job")
        deliveryTipLabel.setupTitleForKey(key: "delivery_job_hint")
        
        addOfferBtn.setupTitleForKey(key: "publish_job", uppercased: true)
        editOfferBtn.setupTitleForKey(key: "save_changes", uppercased: true)
        applyDayPickerBtn.setupTitleForKey(key: "apply_duration", uppercased: true)
        
        // Remove this function to display boost feaure
        hideBoost()
    }
    
    func hideBoost(){
        boostSwitch.isHidden = true
        boostLbl.text = ""
        boostTipLbl.text = ""
        stwIcon2.isHidden = true
    }
    
    func checkIfJobIsEditing() {
        if isEditingJobOffer == true {
            self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "edit_job", uppercased: true), withGradient: true)
            ServerManager.sharedInstance.getJobById(id: createdOffer.id) { (response, success, error) in
                if success! {
                    let jobOffer = OfferModel.init(dict: response)
                    self.createdOffer = jobOffer
                    print(jobOffer)
                    self.populateJobOfferDetails(with: jobOffer)
                }
            }
            addOfferBtn.isHidden = true
            editOfferBtn.isHidden = false
            isEditingJobOffer = false
            
        } else {
            self.setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "create_job", uppercased: true), withGradient: true)
            descriptionTV.text = LanguageManager.sharedInstance.getStringForKey(key: "offer_description")
            locationLbl.setupTitleForKey(key: "add_job_location")
            daysLbl.setupTitleForKey(key: "ad_duration")
            categoryLbl.setupTitleForKey(key: "choose_job_category")
            
            addOfferBtn.isHidden = false
            editOfferBtn.isHidden = true
            
            imageSlider.enablePageIndicator = true
            imageSlider.enableSwipe = true
            imageSlider.addDeleteBtn = true
            imageSlider.allowCircular = false
            imageSlider.backgroundColor = UIColor.lightGray
            imageSlider.enablePageIndicator = true
            imageSlider.allowCircular = false
            imageSlider.enableSwipe = true
            imageSlider.sliderType = .uiImagesType
            imageSlider.placeholderImage = UIImage(named: "imagePlaceholder")!
        }
    }
    
    func populateJobOfferDetails(with offer: OfferModel) {
        titleTF.text = offer.name
        descriptionTV.text = offer.description
        priceTF.text = "\(offer.price)"
        locationLbl.text = offer.getDistanceStr()
        categoryLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "category") + ": " + offer.category.name
        expDateStr = offer.expireAt
        daysLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "ad_duration") + ": " + offer.expireAt
        selectedCategory = createdOffer.category
        selectedCoord =  CLLocationCoordinate2D(latitude: createdOffer.latitude, longitude: createdOffer.longitude)
        addressStr = createdOffer.address
        duration = offer.expireAtDate
        imageSlider.enablePageIndicator = true
        imageSlider.enableSwipe = true
        imageSlider.addDeleteBtn = true
        imageSlider.allowCircular = false
        imageSlider.backgroundColor = UIColor.lightGray
        imageSlider.enablePageIndicator = true
        imageSlider.allowCircular = false
        imageSlider.enableSwipe = true
        imageSlider.sliderType = .uiImagesType
        imageSlider.placeholderImage = UIImage(named: "imagePlaceholder")!

        let array: [String] = offer.imagesURLs
        for imageUrlString in array {
            let imageUrl = URL(string: imageUrlString)!
            let imageData = try! Data(contentsOf: imageUrl)
            let image = UIImage(data: imageData)
            let uploadingImage = UploadingImage(image: image!)
            uploadingImage.isUploading = false
            
            uploadingImagesArray.append(uploadingImage)
        }
        var imageArray = [UIImage]()
        for image in uploadingImagesArray{
            imageArray.append(image.image)
        }
        
        imageSlider.uiImages = imageArray
        imageSlider.isHidden = false
        
        mapView.animate(toLocation: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        mapView.animate(toZoom: 12)
        mapView.setMinZoom(10, maxZoom: 14)
        mapView.padding = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        mapView.layer.cornerRadius = 8
        
        let marker = GMSMarker.init(position: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icPlaceCopy")
        imageView.tintColor = UIColor.darkGray
        marker.iconView = imageView
        marker.map = mapView
    }
    
    func checkImageLbl(){
        uploadedLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "upload_images") + " " + String(uploadingImagesArray.count) + "/5"
    }
    
    func startPayment() {
        if speedySwitch.on && boostSwitch.on {
            presentChoosePaymentScreen(job: createdOffer, type: .payBoostSpeedy, dismissOnTap: false)

        } else if speedySwitch.on {
            presentChoosePaymentScreen(job: createdOffer, type: .paySpeedy, dismissOnTap: false)

        } else if boostSwitch.on {
            presentChoosePaymentScreen(job: createdOffer, type: .payBoost, dismissOnTap: false)
        }
    }
    
    override func chosenSwish() {
        if !UIApplication.shared.canOpenURL(URL(string: "swish://")!) {
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "swish_app_missing"), completion: { (index, str) in
            })
            return
        }
        
        var type = 0
        if speedySwitch.on && boostSwitch.on {
            type = 4
        } else if speedySwitch.on {
            type = 3
        } else {
            type = 2
        }
        
        self.createOffer { [weak self] createdOffer in
            guard let self = self else { return }
            
            self.handleCreateJobOfferResponse(withNavigationBack: false, createdOffer: createdOffer)
            ServerManager.sharedInstance.swishJobPayment(type: type, job: self.createdOffer) { (response, success, errMsg) in
                print(response)
                if success!, let refId = response["refId"] as? String{
                    UserDefaults.standard.set(refId, forKey: "lastRefId")
                    UIApplication.shared.open(URL(string: "swish://paymentrequest?token=\(refId)&callbackurl=com.jobDeal://swish/complete")!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func chosenKlarna() {
        addOfferBtn.startAnimation()
        createOffer { [weak self] createdOffer in
            guard let self = self else { return }
            
            self.addOfferBtn.stopAnimation()
            self.handleCreateJobOfferResponse(withNavigationBack: false, createdOffer: createdOffer)
            
            let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
            
            if self.speedySwitch.on && self.boostSwitch.on {
                vc.paymentType = .speedyAndBoost
            } else if self.speedySwitch.on {
                vc.paymentType = .speedy
            } else {
                vc.paymentType = .boost
            }
            self.presentLoader()
            vc.delegate = self
            vc.targetJob = self.createdOffer
            
            // Dismiss ChoosePaymentViewController
            self.dismiss(animated: true) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Klarna Delegate
    func didFinishWithSuccess(payment: PaymentModel) {
        dismissLoader()
        handleCreateJobOfferResponse(withNavigationBack: true, createdOffer: createdOffer)
    }
    
    func didFinishWithFailure(errorMessage: String) {
        navigationController?.popToViewController(self, animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func editOfferBtnAction(_ sender: Any) {
        editOfferBtn.startAnimation()
        
        if validateInputs() {
            self.editOffer()
        } else {
            self.editOfferBtn.stopAnimation()
        }
    }
    
    @IBAction func addOfferBtnAction(_ sender: Any) {
        addOfferBtn.startAnimation()
        
        var isUploadingImage = false
        for image in uploadingImagesArray{
            if image.isUploading {
                isUploadingImage = true
            }
        }
        
        if isUploadingImage {
            doesAddBtnRequested = true
            return
        } else {
            doesAddBtnRequested = false
        }
        
        if validateInputs() {
            createOffer { [weak self] createdOffer in
                guard let self = self else { return }
                if let createdOffer = createdOffer {
                    self.delegate?.offerCreated(offer: createdOffer)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.addOfferBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5) {
                        let serverFailureMsg = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: serverFailureMsg, completion: { (index, str) in
                        })
                    }
                }
            }
        } else {
            addOfferBtn.stopAnimation()
        }
    }
    
    func editOffer() {
        
        if duration == "" {
            let date = dayPicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            duration = dateFormatter.string(from: date)
        }
        var imagePathsArray = [Dictionary<String, Any>]()
        for i in 0 ..< uploadingImagesArray.count {
            imagePathsArray.append(["position" : i , "path" : uploadingImagesArray[i].path])
        }
        
        ServerManager.sharedInstance.editJob(id: createdOffer.id,
                                             name: titleTF.trimmedString()!,
                                             desc: descriptionTV.trimmedString()!,
                                             expireAt: duration,
                                             price: priceTF!.trimmedString()!,
                                             address: addressStr,
                                             buyerProfile: "1",
                                             categoryId: selectedCategory.id,
                                             property: "Property",
                                             isBoost: boostSwitch.on,
                                             isSpeedy: speedySwitch.on,
                                             code: "code",
                                             image: imagePathsArray,
                                             longitude: selectedCoord!.longitude,
                                             latitude: selectedCoord!.latitude,
                                             isDelivery: deliverySwitch.on) { (response, success, errMsg) in
            
            
            if success! {
                print(response)
                if (response["name"] as? String) != nil {
                    
                    let offer = OfferModel(dict: response)
                    self.createdOffer = offer
                    
                    if (self.speedySwitch.on || self.boostSwitch.on) {
                         
                        self.startPayment()
                        
                    } else {
                        
                        for vc in self.navigationController?.viewControllers ?? [] {
                            if vc is DashboardViewController {
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadData"), object: nil)
                        self.delegateEdit?.didEditOffer(offer:offer)
                        
                    }
                    self.editOfferBtn.stopAnimation()
                    
                } else {
                    self.editOfferBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5) {
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                        })
                    }
                }
                
            } else {
                self.editOfferBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5) {
                    AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                    })
                }
            }
        }
    }
    
    func createOffer(completion: @escaping (OfferModel?) -> Void) {
        let date = dayPicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let duration = dateFormatter.string(from: date)
        
        var imagePathsArray = [Dictionary<String, Any>]()
        for i in 0 ..< uploadingImagesArray.count {
            imagePathsArray.append(["position" : i , "path" : uploadingImagesArray[i].path])
        }
        
        ServerManager.sharedInstance.addJob(name: titleTF.trimmedString()!,
                                            desc: descriptionTV.trimmedString()!,
                                            expireAt: duration,
                                            price: priceTF!.trimmedString()!,
                                            address: addressStr,
                                            buyerProfile: "1",
                                            categoryId: selectedCategory.id,
                                            property: "Property",
                                            isBoost: boostSwitch.on,
                                            isSpeedy: speedySwitch.on,
                                            code: "code",
                                            image: imagePathsArray,
                                            longitude: selectedCoord!.longitude,
                                            latitude: selectedCoord!.latitude,
                                            isDelivery: deliverySwitch.on) { (response, success, errMsg) in
            
            if success! {
                if (response["name"] as? String) != nil {
                    let offer = OfferModel(dict: response)
                    completion(offer)
                } else {
                    completion(nil)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    func validateInputs() -> Bool {
        self.view.endEditing(true)
        
        if self.titleTF.isInputInvalid(){
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_title"))
            return false
        }

        if self.descriptionTV.isInputInvalid() || self.descriptionTV.text == LanguageManager.sharedInstance.getStringForKey(key: "offer_description"){
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_description"))
            return false
        }
        
        if self.priceTF.isInputInvalid(){
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_enter_price"))
            return false
        }
        
        if selectedCategory.id == 0 {
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_select_category"))
            return false
        }
        
        if selectedCoord == nil || selectedCoord?.longitude == 0.0 {
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_select_location"))
            return false
        }
        
        if uploadingImagesArray.count == 0 {
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "image_required"))
            return false
        }
        
        if  expDateStr == "" {
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "must_select_duration"))
            return false

        }
        
        if self.speedySwitch.on || self.boostSwitch.on {
            self.startPayment()
            return false
        }
        
        return true
    }
    
    private func handleCreateJobOfferResponse(withNavigationBack navigationBack: Bool, createdOffer: OfferModel?) {
        if let createdOffer = createdOffer {
            self.createdOffer = createdOffer
            DataManager.sharedInstance.selectedCategory = self.selectedCategory
            self.delegate?.offerCreated(offer: createdOffer)
            
            if navigationBack {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.addOfferBtn.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5) {
                let serverFailureMsg = LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message")
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: serverFailureMsg, completion: { (index, str) in
                })
            }
        }
    }
    
    @IBAction func uploadBtnAction(_ sender: Any) {
        
        if(uploadingImagesArray.count > 4){
            self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "max_images_reached"))
            return
        }
        
        let alert = UIAlertController(title: LanguageManager.sharedInstance.getStringForKey(key: "job_image_title"), message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "take_new"), style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "gallery"), style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), style: .cancel){
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let picker = AssetsPickerViewController()
            picker.pickerDelegate = self
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func categoryBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CategoryPreviewViewController") as! CategoryPreviewViewController
        vc.delegate = self
        vc.isSelectingCategory = true

        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func locationBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        vc.offer = self.createdOffer
        vc.isEditingLocation = self.isEditingJobOffer
        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func durationBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addTransitionAnimationToView()
    
        if(dayPickerBackView.isHidden){
            dayPickerBotConstraint.constant = dayPickerBackView.frame.size.height
            dayPickerBackView.isHidden = false
            super.view.bringSubviewToFront(dayPickerBackView)
            UIView.animate(withDuration: 0.3) {
                self.dayPickerBotConstraint.constant = 0
                self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: self.dayPickerBackView.frame.size.height, right: 0)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func speedySwitchAction(_ sender: PWSwitch) {
        if sender.on {
            deliverySwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func deliverySwitchAction(_ sender: PWSwitch) {
        if sender.on {
            speedySwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func boostSwitchAction(_ sender: PWSwitch) {
        stwIcon2.tintColor = boostSwitch.on ? UIColor.boostStarColor : UIColor.darkGray
    }
    
    @IBAction func daysDurationBtnAction(_ sender: Any) {
        daysLbl.textColor = UIColor.darkGray
        self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        daysLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "ad_duration") + ": " + expDateStr
        
        dayPickerBackView.isHidden = true
    }
    
    //MARK: - Keyboard Notifications
    
    override func keyboardWillChangeFrame(notification: NSNotification) {
        self.dayPickerBackView.isHidden = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    //MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == LanguageManager.sharedInstance.getStringForKey(key: "offer_description")){
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            descriptionTV.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionTV.textColor = UIColor.darkGray
    }
    
    //MARK: - AddressSelectionDelegate Delegate
    
    func selectedCoordinate(coordinate: CLLocationCoordinate2D, address: String) {
        mapView.animate(toLocation: coordinate)
        marker.position = coordinate
        marker.map = mapView
        mapView.animate(toZoom: 14)
        selectedCoord = coordinate
        self.addressStr = address
    }
    
    //MARK: - TextField Delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.isEqual(self.titleTF)){
            descriptionTV.becomeFirstResponder()
        }
        
        if(textField.isEqual(self.priceTF)){
            self.view.endEditing(true)
        }
        
        return true
    }
    
    //MARK: - CategorySelector Delegate
    
    func categorySelectorDidSelectCategory(category: CategoryModel) {
        self.categoryLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "category") + ": " + category.title
        self.selectedCategory = category
        dismiss(animated: true) {
        }
    }
    
    func categoriesUpdated(categorieIds: [Int]) {
    }
    
    func updateCategory(category: CategoryModel) {
    }
    
    //MARK: - UIDatePickerView Delegate

    @IBAction func dayPickerChanged(_ sender: UIDatePicker) {
        
        let date = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        expDateStr = dateFormatter.string(from: date)
        daysLbl.text = expDateStr
        duration = dateFormatter.string(from: date)
    }
    
    
    //MARK: - Image Picker Delegate
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        
        for asset in assets{
            if let image = getUIImage(asset: asset) {
                uploadingImagesArray.append(UploadingImage(image: image))
            }
        }
        uploadImages()
        
        checkImageSliderState()
    }
    
    func checkImageSliderState(){
        checkImageLbl()
        if uploadingImagesArray.count == 0 {
            imageSlider.isHidden = true
        } else {
            var imageArray = [UIImage]()
            for image in uploadingImagesArray{
                imageArray.append(image.image)
            }
            
            imageSlider.uiImages = imageArray
            imageSlider.isHidden = false
        }
    }
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true;
        manager.requestImageData(for: asset, options: options) { (data, dataUTI, orientation, info) in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        if controller.selectedAssets.count + uploadingImagesArray.count > 4  {
            // do your job here
            return false
        }
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        uploadingImagesArray.append(UploadingImage(image: chosenImage))
        checkImageSliderState()
        
        uploadImages()
        
        imagePicker.dismiss(animated: true)
    }

    func uploadImages() {
        uploadImageBtn.startAnimation()
        
        DispatchQueue.global().async {
            var finished = true
            var array = [Data]()
            for image in self.uploadingImagesArray {
                if image.fullUrl.isEmpty && !image.isUploading {
                    finished = false
                    image.isUploading = true
                    
                    let imgData = image.image.jpegData(compressionQuality: 0.4)
                    array.append(imgData!)
                } else if image.isUploading {
                    finished = false
                    
                } else {
                    continue
                }
            }
            
            if array.count > 0 {
                ServerManager.sharedInstance.uploadJobImages(imageDataArray: array) { (response, success) in
                    
                    DispatchQueue.main.async {
                        self.uploadImageBtn.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.5) {
                            self.uploadImageBtn.setImage(UIImage(named: "icFileUpload"), for: .normal)
                        }
                        self.uploadImageBtn.isUserInteractionEnabled = true
                        
                        if success! {
                            print("Uploading images response: \(response)")
                            
                            var dictArray = response
                            for image in self.uploadingImagesArray {
                                if(image.isUploading && dictArray.count > 0) {
                                    image.loadFromDict(dict: dictArray.first!)
                                    image.isUploading = false
                                    dictArray.removeFirst()
                                }
                            }

                            self.uploadImages()
                            
                        } else {
                            for image in self.uploadingImagesArray {
                                if image.isUploading && image.fullUrl.isEmpty {
                                    image.isUploading = false
                                }
                            }
                            
                            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "image_upload_error"), completion: { (index, str) in
                            })
                            return;
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                if finished {
                    self.uploadImageBtn.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.5) {
                        self.uploadImageBtn.setImage(UIImage(named: "icFileUpload"), for: .normal)
                    }
                    self.uploadImageBtn.isUserInteractionEnabled = true
                }
                
                if finished && self.doesAddBtnRequested {
                    self.addOfferBtnAction(self.addOfferBtn)
                }
            }
        }
    }
    
    //MARK: - CPSlider Delegate
    func sliderImageTapped(slider: CPImageSlider, index: Int) {}
    
    func deleteImageBtnAction(index: Int) {
        for image in uploadingImagesArray{
            if image.isUploading{
                self.view.makeToast(LanguageManager.sharedInstance.getStringForKey(key: "cant_delete_photo_while_uploading"), duration: 3.0, position: .bottom)
                return
            }
        }
        uploadingImagesArray.remove(at: index)
        
        checkImageSliderState()
    }
}

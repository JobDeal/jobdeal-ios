//
//  JobOfferViewController.swift
//  JobDeal
//
//  Created by Priba on 1/8/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import ParallaxHeader
import GoogleMaps
import TransitionButton
import Cosmos
import SDWebImage
import IHProgressHUD
import FirebaseDynamicLinks
import Device

protocol JobOfferEditDelegate: class {
    func didEditOffer(offer: OfferModel)
}

class JobOfferViewController: BaseViewController, UIScrollViewDelegate, KlarnaPaymentDelegate, EditofferDelegate {
   
    // MARK: - Outlets
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var rightNavBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var navOptionView: UIView!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var bookmarkBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var boostStarImageView: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var location2ImageView: UIImageView!
    @IBOutlet weak var ownerAvatar: UIImageView!
    @IBOutlet weak var ownerNameLbl: UILabel!
    @IBOutlet weak var ownerLocationLbl: UILabel!
    @IBOutlet weak var ownerRateView: CosmosView!
    @IBOutlet weak var ownerRateLbl: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var appliedLbl: UILabel!
    @IBOutlet weak var applyBtn: TransitionButton!
    @IBOutlet weak var imageSlider: CPImageSlider!
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfDoersView: UIView!
    @IBOutlet weak var numberOfDoersLabel: UILabel!
    
    // MARK: - Public Properties
    var offer = OfferModel()
    var user = DataManager.sharedInstance.loggedUser

    
    weak var delegate: JobOfferDelegate?
    weak var delegateEdit: JobOfferEditDelegate?

    var isEndController = false
    var isMyJob = false
    var isChosen = false
    
    // MARK: - Private Properties
    private var isApplyButtonHidden: Bool {
        get {
            return (offer.isExpired && !offer.isListPayed) || offer.isApplied
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        if offer.user.Id == DataManager.sharedInstance.loggedUser.Id {
            isMyJob = true
        }
        
        super.viewDidLoad()
        
        loadDataLocally(offer: offer)
        loadDataFromBackend()
        
        boostStarImageView.tintColor = UIColor.boostStarColor
        boostStarImageView.isHidden = !self.offer.isBoost
        
        let backTap = UITapGestureRecognizer.init(target: self, action: #selector(hideNavOptionView))
        self.view.addGestureRecognizer(backTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyedForJob), name: Notification.Name(rawValue: "applyedForJobNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jobReported), name: Notification.Name(rawValue: "jobReported"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.addGradientToBackground()
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        if Utils.hasNotch() {
            navigationBarHeightConstraint.constant = 94
        } else {
            navigationBarHeightConstraint.constant = 64
        }
        
        locationImageView.tintColor = UIColor.darkGray
        location2ImageView.tintColor = UIColor.darkGray
        clockImageView.tintColor = UIColor.darkGray
        
        ownerAvatar.setHalfCornerRadius()
        
        applyBtn.setupForTransitionLayoutTypeBlack()
        applyBtn.backgroundColor = UIColor.mainButtonColor
        if Device.size() == .screen4Inch {
            applyBtn.titleLabel?.font = applyBtn.titleLabel?.font.withSize(12)
        }
        
        ownerRateView.isUserInteractionEnabled = false
        mapView.animate(toLocation: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        mapView.animate(toZoom: 12)
        mapView.setMinZoom(10, maxZoom: 14)
        mapView.padding = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        mapView.layer.cornerRadius = 8
        mapView.isUserInteractionEnabled = false
        
        bookmarkBtn.isHidden = true
        
        let marker = GMSMarker.init(position: CLLocationCoordinate2DMake(offer.latitude, offer.longitude))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icPlaceCopy")
        imageView.tintColor = UIColor.darkGray
        marker.iconView = imageView
        marker.map = mapView
        
        navOptionView.layer.cornerRadius = 12
        navOptionView.layer.applySketchShadow()
        
        if offer.user.role == .visitor {
            bookmarkBtn.isHidden = true
            editBtn.isHidden = true
        } else if !isMyJob {
            bookmarkBtn.isHidden = false
            bookmarkBtn.isSelected = offer.bookmarked
            bookmarkBtnConstraint.constant = 0
            editBtn.isHidden = true
        } else {
            bookmarkBtn.isHidden = true
            bookmarkBtnConstraint.constant = 40
            // Prevent editing job if someone already made a bid
            editBtn.isHidden = offer.bidCount > 0
        }
        
        if offer.isSpeedy {
            durationLbl.textColor = UIColor.speedyRedColor
            clockImageView.tintColor = UIColor.speedyRedColor
        }
        
        applyBtn.isHidden = isApplyButtonHidden
        appliedLbl.isHidden = !offer.isApplied
        
        imageSlider.enablePageIndicator = true
        imageSlider.enableSwipe = true
        imageSlider.allowCircular = false
        imageSlider.backgroundColor = UIColor.lightGray
        imageSlider.enablePageIndicator = true
        imageSlider.allowCircular = false
        imageSlider.enableSwipe = true
        imageSlider.sliderType = .uiImagesType
        imageSlider.placeholderImage = UIImage(named: "imagePlaceholder")!
        
        let array: [String] = offer.imagesURLs
        var imageArray = [UIImage]()

        for imageUrlString in array {
            let imageUrl = URL(string: imageUrlString)!
            let imageData = try! Data(contentsOf: imageUrl)
            let image = UIImage(data: imageData)
            imageArray.append(image!)
        }
        imageSlider.uiImages = imageArray
        
        setupNumberOfDoersView()
    }
    
    override func loadData() {
        // This means that payment with Swish was successful so dismiss the payment dialog and show list of doers
        if navigationController?.visibleViewController is ChoosePaymentViewController {
            navigationController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.jobOfferUpdated(offer: self.offer)
                
                self.offer.isListPayed = true
                self.loadDataLocally(offer: self.offer)
                
                let vc =  UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "AllJobBidsViewController") as! AllJobBidsViewController
                vc.jobOffer = self.offer
                self.navigationController?.pushViewController(vc, animated: true)
            })
        } else {
            loadDataFromBackend()
        }
    }
    
    override func setupStrings() {
        navTitleLbl.setupTitleForKey(key: "job_offer", uppercased: true)
        shareBtn.setupTitleForKey(key: "share_job")
        appliedLbl.setupTitleForKey(key: "you_have_applied")
        
        if isMyJob {
            reportBtn.setupTitleForKey(key: "delete_job")
            applyBtn.setupTitleForKey(key: "check_doers", uppercased: true)
            
        } else {
            reportBtn.setupTitleForKey(key: "report_job")
            applyBtn.setupTitleForKey(key: "apply", uppercased: true)
        }
    }
    
    override func chosenSwish() {
        if !UIApplication.shared.canOpenURL(URL(string: "swish://")!){
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "swish_app_missing"), completion: { (index, str) in
            })
            return
        }
        
        ServerManager.sharedInstance.swishJobPayment(type: 1, job: self.offer) { (response, success, errMsg) in
            print(response)
            if success!, let refId = response["refId"] as? String{
                
                UserDefaults.standard.set(refId, forKey: "lastRefId")
                UIApplication.shared.open(URL(string: "swish://paymentrequest?token=\(refId)&callbackurl=com.jobDeal://swish/complete")!, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    override func chosenKlarna() {
        // Dismiss ChoosePaymentViewController
        dismiss(animated: true)
        
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
        vc.paymentType = .unlockList
        vc.targetJob = self.offer
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - EditofferDelegate
    func didEditOffer(offer: OfferModel) {
        self.delegateEdit?.didEditOffer(offer: offer)
    }
    
    // MARK: - Helper Methods
    private func loadDataLocally(offer: OfferModel) {
        priceLbl.text = String(offer.getFullPrice())
        titleLbl.text = offer.name
        distanceLbl.text = offer.getDistanceStr()
        descLbl.text = offer.description
        if offer.isExpired {
            durationLbl.setupTitleForKey(key: "job_expired")
        } else {
            durationLbl.text = offer.expireAt
        }
        
        ownerRateView.rating = 3.5
        
        ownerNameLbl.text = offer.user.name
        ownerRateView.rating = offer.user.buyerRating
        ownerRateLbl.text = offer.user.getUserBuyerRatingString()
        ownerLocationLbl.text = offer.user.city
        
        ownerAvatar.sd_setImage(with: URL(string: offer.user.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        
        setupNumberOfDoersView()
    }
    
    private func loadDataFromBackend() {
        applyBtn.isEnabled = false
        ServerManager.sharedInstance.getJobById(id: offer.id) { (response, success, message) in
            self.applyBtn.isEnabled = true
            if success! {
                let jobOffer = OfferModel.init(dict: response)
                self.offer = jobOffer
                self.loadDataLocally(offer: self.offer)
                let applicants = jobOffer.applicants
                if applicants.count > 0 {
                    let chosenDoerEmail = applicants[0].bidUser.email
                    if chosenDoerEmail == self.user.email {
                        self.isChosen = true
                        self.appliedLbl.setupTitleForKey(key: "buyer_accepted_title")
                        self.appliedLbl.textColor = .black
                        
                    }
                }
            }
        }
    }
    
    private func applyForJob() {
        applyBtn.startAnimation()
        applyBtn.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.5) {
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "ApplyJobViewController") as! ApplyJobViewController
            vc.offer = self.offer
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func setupNumberOfDoersView() {
        numberOfDoersView.isHidden = offer.bidCount == 0 || !isMyJob || isApplyButtonHidden
        numberOfDoersView.setHalfCornerRadius()
        numberOfDoersLabel.text = String(offer.bidCount)
    }
    
    // MARK: - KlarnaPaymentDelegate
    func didFinishWithSuccess(payment: PaymentModel) {
        
        if payment.status == "PAID" {
            
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_success"), completion: { (index, str) in
                
                self.offer = payment.job
                self.delegate?.jobOfferUpdated(offer: payment.job)
                
                let vc =  UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "AllJobBidsViewController") as! AllJobBidsViewController
                vc.jobOffer = self.offer
                self.navigationController?.pushViewController(vc, animated: true)
                
            })
        } else {
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_failed"),
                completion: { _, _ in
                    self.navigationController?.popToViewController(self, animated: true)
            })
        }
    }
    
    func didFinishWithFailure(errorMessage: String) {
        navigationController?.popToViewController(self, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideNavOptionView()
    }
    
    // MARK: - Actions
    @IBAction func applyBtnAction(_ sender: Any) {
        if DataManager.sharedInstance.loggedUser.role == .visitor {
            AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "login_required"),
                                                         aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"),
                                                         aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "confirm")) { (index, title) in
                if index == 1 {
                    UserDefaults.standard.set(self.offer.id, forKey: "visitedJobId")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        } else if isMyJob {
            if offer.isListPayed || offer.bidCount == 0 {
                let vc =  UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "AllJobBidsViewController") as! AllJobBidsViewController
                vc.jobOffer = self.offer
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.presentChoosePaymentScreen(job: self.offer, type: .payList)
            }
            
        } else {
            applyForJob()
        }
    }
    
    @objc func hideNavOptionView() {
        if !navOptionView.isHidden{
            navOptionView.isHidden = true
        }
    }
    
    @objc func applyedForJob() {
        self.offer.isApplied = true
        setupUI()
        setupStrings()
    }
    
    @IBAction func buyerProfileBtnAction(_ sender: Any) {
        if !isEndController {
            let vc =  UIStoryboard(name: "RateBuyer", bundle: nil).instantiateViewController(withIdentifier: "BuyerPreviewRatingViewController") as! BuyerPreviewRatingViewController
            vc.buyerProfile = self.offer.user
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // Checking if buyer chose me as a doer
            if offer.applicants.first(where: { $0.bidUser.Id == DataManager.sharedInstance.loggedUser.Id }) != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let buyerProfileVC = storyboard.instantiateViewController(withIdentifier: "BuyerProfileViewController") as! BuyerProfileViewController
                buyerProfileVC.offer = offer
                self.navigationController?.pushViewController(buyerProfileVC, animated: true)
            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bookmarkBtnAction(_ sender: Any) {
        if DataManager.sharedInstance.loggedUser.role != .visitor {
            bookmarkBtn.isSelected = !bookmarkBtn.isSelected
            
            if bookmarkBtn.isSelected {
                ServerManager.sharedInstance.addBookmarkForJob(jobOffer: self.offer) { (response, success, errMsg) in
                    
                    if success! {
                        self.offer = OfferModel(dict: response)
                        self.delegate?.jobOfferUpdated(offer: self.offer)
                    }
                }
            } else {
                ServerManager.sharedInstance.removeBookmarkForJob(jobOffer: self.offer) { (response, success, errMsg) in
                    
                    if success! {
                        self.offer = OfferModel(dict: response)
                        self.delegate?.jobOfferUpdated(offer: self.offer)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func rightNavBtnAction(_ sender: Any) {
        navOptionView.isHidden = !navOptionView.isHidden
    }
    
    @IBAction func reportBtnAction(_ sender: Any) {
        
        if isMyJob {
            // Delete
            AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "delete_job_alert"), aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "delete_job")) { (index, str) in
                if index == 1 {
                    
                    IHProgressHUD.set(defaultMaskType: .gradient)
                    IHProgressHUD.set(defaultStyle: .dark)
                    IHProgressHUD.set(ringThickness: 3)
                    IHProgressHUD.set(foregroundColor: UIColor.mainColor1)
                    IHProgressHUD.show()
                    
                    ServerManager.sharedInstance.deleteJob(jobOffer: self.offer) { (response, success, errMsg) in
                        IHProgressHUD.dismiss()
                        
                        self.delegate?.jobDeleted(offer: self.offer)
                        
                        for vc in self.navigationController?.viewControllers ?? [] {
                            if vc is DashboardViewController {
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
            
        } else {
            hideNavOptionView()
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "ReportJobViewController") as! ReportJobViewController
            vc.offer = self.offer
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func jobReported() {
        self.delegate?.jobDeleted(offer: self.offer)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editBtnAction(_ sender: Any) {
        let vc = CreateOfferViewController.instantiate(fromStoryboardNamed: "CreateOffer")
        vc.delegateEdit = self
        vc.isEditingJobOffer = true
        vc.createdOffer = self.offer
        show(vc, sender: nil)
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        hideNavOptionView()
        let id = self.offer.id
        
        guard let link = URL(string: "https://jobdeal.com/job/\(id)") else {
            return
        }

        let dynamicLinksDomainURIPrefix = "https://jobdeal.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)!
        
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "jobdeal")
        linkBuilder.iOSParameters?.appStoreID = "1437627797"
        linkBuilder.iOSParameters?.minimumAppVersion = "1.0"
        
        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.justraspberry.jobdeal")
        linkBuilder.androidParameters?.minimumVersion = 1
        
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = "Job Deal"
        linkBuilder.socialMetaTagParameters?.descriptionText = LanguageManager.sharedInstance.getStringForKey(key: "share_description")
        linkBuilder.socialMetaTagParameters?.imageURL = URL(string: "https://prod.jobdeal.com/logo.png")
        
        IHProgressHUD.set(defaultMaskType: .gradient)
        IHProgressHUD.set(defaultStyle: .dark)
        IHProgressHUD.set(ringThickness: 3)
        IHProgressHUD.set(foregroundColor: UIColor.mainColor1)
        IHProgressHUD.show()
        
        linkBuilder.shorten(completion: { url, warnings, error in
            IHProgressHUD.dismiss()
            
            guard let url = url else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "something_went_wrong"), completion: { (index, str) in
                })
                return
            }
            let sharingItems: [Any] = [url]
            let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            
            self.present(activityController, animated: true)
        })
    }
    
    @IBAction func mapViewButtonAction(_ sender: UIButton) {
        let location = CLLocation(latitude: offer.latitude, longitude: offer.longitude)
        Utils.openGoogleMapNavigation(forLocation: location)
    }
}


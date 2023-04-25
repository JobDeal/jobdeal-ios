//
//  ChooseDoerViewController.swift
//  JobDeal
//
//  Created by Priba on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Foundation
import Cosmos
import SDWebImage
import MessageUI
import Toast_Swift
import ImageViewer
import Device

class ChooseDoerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, KlarnaPaymentDelegate, ChooseDoerConfirmationDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var doerMainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doerAvatarImageView: UIImageView!
    @IBOutlet weak var doerNameLbl: UILabel!
    @IBOutlet weak var doerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var doerRateView: CosmosView!
    @IBOutlet weak var doerRateCountLbl: UILabel!
    @IBOutlet weak var doerHolderView: UIView!
    @IBOutlet weak var doerOfferLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var rateTableView: UITableView!
    @IBOutlet weak var activeUserIndicator: UIButton!
    @IBOutlet weak var buttonsHolderView: UIView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var chooseDoerButton: DoubleImageButton!
    @IBOutlet weak var firstButtonsSeparator: UIView!
    @IBOutlet weak var secondButtonsSeparator: UIView!
    @IBOutlet weak var buttonsHolderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageDoerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundingView: UIView!
    @IBOutlet weak var goToTopBackView: UIView!
    @IBOutlet weak var goToTopBtn: UIButton!
    @IBOutlet weak var ratedAsLbl: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView?
    @IBOutlet weak var accountDetailsView: UIView!
    @IBOutlet weak var doerFirstNameLabel: UILabel!
    @IBOutlet weak var doerFullNameLabel: UILabel!
    @IBOutlet weak var doerNumberLabel: UILabel!
    @IBOutlet weak var doerEmailLabel: UILabel!
    @IBOutlet weak var doerAddressLabel: UILabel!
    @IBOutlet weak var doerPostalCodeLabel: UILabel!
    @IBOutlet weak var doerCityLabel: UILabel!
    
    // MARK: - Public Properties
    var bid = BidModel()
    var rateArray = [RateModel]()
    
    // MARK: - Private Properties
    private var galleryController: GalleryViewController?
    private var imageGalleryItem: GalleryItem?
    private var bottomHStackViews = [UIView]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rateTableView.delegate = self
        self.rateTableView.dataSource = self
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "doer_profile", uppercased: true), withGradient: true)
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        rateTableView.isHidden = true // by default it's hidden, visibility will be determined by backend
        accountDetailsView.isHidden = true // by default it's hidden, visibility will be determined by backend
        buttonsHolderViewHeightConstraint.constant = Utils.hasNotch() ? 80 : 60
        phoneButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        phoneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        phoneButton.titleLabel?.minimumScaleFactor = 0.5
        messageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        messageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        messageButton.titleLabel?.minimumScaleFactor = 0.5
        rateTableView.estimatedRowHeight = 150
        rateTableView.rowHeight = UITableView.automaticDimension
        rateTableView.layer.cornerRadius = 10
        roundingView.layer.cornerRadius = 10
        rateTableView.layer.applySketchShadow()
        doerHolderView.layer.cornerRadius = 10
        doerHolderView.layer.applySketchShadow()
        doerRateView.isUserInteractionEnabled = false
        doerAvatarImageView.setHalfCornerRadius()
        doerNameLbl.text = bid.bidUser.name + " " + bid.bidUser.surname
        doerLocationLbl.text = bid.bidUser.city
        pinIV.tintColor = UIColor.darkGray
        doerRateView.rating = bid.bidUser.doerRating
        doerRateCountLbl.text = bid.bidUser.getUserDoerRatingString()
        
        doerAvatarImageView.sd_setImage(with: URL(string: bid.bidUser.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        doerAvatarImageView.isUserInteractionEnabled = true
        let avatarImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(doerAvatarImageViewTapped(gestureRecognizer:)))
        doerAvatarImageView.addGestureRecognizer(avatarImageTapGesture)
        
        rateTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        goToTopBackView.layer.cornerRadius = 10
        
        activeUserIndicator.isHidden = !bid.bidUser.isPaid
        activeUserIndicator.isUserInteractionEnabled = false
        
        view.backgroundColor = UIColor.separatorColor
        
        aboutMeTextView?.isEditable = false
        if bid.bidUser.aboutMe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aboutMeTextView?.removeFromSuperview()
            doerMainViewHeightConstraint.constant = 190
        } else {
            aboutMeTextView?.text = bid.bidUser.aboutMe
        }
        
        phoneLbl.isUserInteractionEnabled = true
        let phoneLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(phoneLabelTapped(gestureRecognizer:)))
        phoneLbl.addGestureRecognizer(phoneLabelTapGesture)
        
        accountDetailsView.layer.cornerRadius = 10
        accountDetailsView.layer.applySketchShadow()
        
        layoutBottomHStackViews()
        
        doerFirstNameLabel.text = bid.bidUser.name
        doerFullNameLabel.text = bid.bidUser.getUserFullName()
        doerNumberLabel.text = bid.bidUser.mobile
        doerEmailLabel.text = bid.bidUser.email
        doerAddressLabel.text = bid.bidUser.address
        doerPostalCodeLabel.text = bid.bidUser.zip
        doerCityLabel.text = bid.bidUser.city
        
        setupStrings()
        
        view.layoutIfNeeded()
    }
    
    override func setupStrings() {
        chooseDoerButton.setupTitleForKey(key: "choose_doer", uppercased: true)
        ratedAsLbl.setupTitleForKey(key: "rated_as_doer")
        goToTopBtn.setupTitleForKey(key: "go_to_top", uppercased: true)
        doerOfferLbl.setupTitleForKey(key: "doer_offer_for_job")
        
        priceLbl.text = bid.getFullPrice()
        phoneLbl.text = bid.bidUser.mobile
    }
    
    override func loadData() {
        // This means that payment with Swish was successful so dismiss the payment dialog and choose applicant for job
        if navigationController?.visibleViewController is ChoosePaymentViewController {
            navigationController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.chooseApplicantForJob()
            })
        } else {
            page = 0
            isEndOfList = false
            
            ServerManager.sharedInstance.getDoerRate(user: bid.bidUser, page: page) { (response, success, errMsg) in
                self.rateArray = [RateModel]()
                if success! {
                    for dict in response{
                        let rate = RateModel(dict: dict)
                        self.rateArray.append(rate)
                    }
                    if !self.rateArray.isEmpty {
                        self.rateTableView.reloadData()
                        self.rateTableView.isHidden = false
                        self.accountDetailsView.isHidden = true
                    } else {
                        self.rateTableView.isHidden = true
                    }
                }
            }
        }
    }
    
    override func chosenSwish() {
        if !UIApplication.shared.canOpenURL(URL(string: "swish://")!) {
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "swish_app_missing"),
                completion: { (index, str) in }
            )
            return
        }
        ServerManager.sharedInstance.swishChoosePayment(bid: self.bid) { (response, success, errMsg) in
            print(response)
            if success!, let refId = response["refId"] as? String {
                UserDefaults.standard.set(refId, forKey: "lastRefId")
                UIApplication.shared.open(URL(string: "swish://paymentrequest?token=\(refId)&callbackurl=com.jobDeal://swish/complete")!, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func chosenKlarna() {
        // Dismiss ChoosePaymentViewController
        dismiss(animated: false, completion: nil)
        
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
        vc.targetBid = bid
        vc.paymentType = .chooseDoer
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Helper Methods
    private func loadNextPage() {
        page += 1
        
        ServerManager.sharedInstance.getDoerRate(user: bid.bidUser, page: page) { (response, success, errMsg) in
            if success!{
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                for dict in response{
                    let rate = RateModel(dict: dict)
                    self.rateArray.append(rate)
                }
                self.rateTableView.reloadData()
            }
        }
    }
    
    private func chooseApplicantForJob() {
        presentLoader()
        ServerManager.sharedInstance.chooseApplicantForJob(jobOffer: self.bid.bidJob, bid: self.bid) { (response, success, errMsg) in
            self.dismissLoader()
            
            if let success = success, success {
                let feedbackMessage = String(format: LanguageManager.sharedInstance.getStringForKey(key: "choose_ok"), self.bid.bidUser.name)
                self.view.makeToast(feedbackMessage)
                self.bid.choosed = true
                self.layoutBottomHStackViews()
            }
        }
    }
    
    private func layoutBottomHStackViews() {
        buttonsStackView.removeAllArrangedSubviewsCompletely()
        if bid.choosed {
            bottomHStackViews = [
                phoneButton,
                messageButton
            ]
            phoneButtonWidthConstraint.isActive = false
            messageDoerButtonWidthConstraint.isActive = false
            buttonsStackView.alignment = .fill
            buttonsStackView.distribution = .fillEqually
        } else {
            bottomHStackViews = [
                phoneButton,
                firstButtonsSeparator,
                chooseDoerButton,
                secondButtonsSeparator,
                messageButton
            ]
            phoneButtonWidthConstraint.isActive = true
            messageDoerButtonWidthConstraint.isActive = true
            phoneButtonWidthConstraint.constant = 80
            messageDoerButtonWidthConstraint.constant = 80
        }
        
        for (i, bottomHStackView) in bottomHStackViews.enumerated() {
            buttonsStackView.insertArrangedSubview(bottomHStackView, at: i)
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == rateArray.count - 2 && !isEndOfList {
            loadNextPage()
        }
        
        let rate = rateArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RateUserTableViewCell", for: indexPath) as! RateUserTableViewCell
        cell.populateCell(rate: rate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Actions
    @objc func phoneLabelTapped(gestureRecognizer: UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + bid.bidUser.mobile) else { return }
        UIApplication.shared.open(number)
    }
    
    @objc func doerAvatarImageViewTapped(gestureRecognizer: UITapGestureRecognizer) {
        imageGalleryItem = GalleryItem.image(fetchImageBlock: { [weak self] (imageCompletion) in
            guard let self = self else { return }
            
            imageCompletion(self.doerAvatarImageView.image)
            self.imageGalleryItem = nil
        })
        
        galleryController = GalleryViewController(startIndex: 0,
                                                       itemsDataSource: self,
                                                       itemsDelegate: nil,
                                                       displacedViewsDataSource: nil,
                                                       configuration: Utils.getCommonGalleryConfiguration())
        presentImageGallery(self.galleryController!)
    }
    
    @IBAction func goTopBtnAction(_ sender: Any) {
        rateTableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func chooseDoer() {
        let chooseDoerConfirmationVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ChooseDoerConfirmationViewController") as! ChooseDoerConfirmationViewController
        chooseDoerConfirmationVC.delegate =  self
        chooseDoerConfirmationVC.bid = bid
        
        present(chooseDoerConfirmationVC, animated: true, completion: nil)
    }
    
    @IBAction func callDoerAction(_ sender: Any) {
        guard let number = URL(string: "tel://" + bid.bidUser.mobile) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func messageDoerAction(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Job Deal - \(bid.bidJob.name) #\(bid.bidJob.id)"
            controller.recipients = [bid.bidUser.mobile]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - KlarnaPaymentDelegate
    func didFinishWithSuccess(payment: PaymentModel) {
        if payment.status == "PAID" {
            chooseApplicantForJob()
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_success"),
                completion: { _, _ in })
        } else {
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_faild"),
                completion: { _, _ in
                    self.navigationController?.popToViewController(self, animated: true)
            })
        }
    }
    
    func didFinishWithFailure(errorMessage: String) {
        navigationController?.popToViewController(self, animated: true)
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ChooseDoerConfirmationDelegate
    func didConfirmDoer(helpOnTheWay: Bool) {
        bid.bidJob.helpOnTheWay = helpOnTheWay
        
//        let diff = bid.bidPrice - bid.bidJob.price
//        if diff < 0 {
//            presentChoosePaymentScreen(job: bid.bidJob, type: .payChoose, applicant: bid.bidUser)
//        } else {
            chooseApplicantForJob()
//        }
    }
}

// MARK: - GalleryItemsDataSource
extension ChooseDoerViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imageGalleryItem!
    }
}

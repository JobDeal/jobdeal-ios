//
//  BuyerPreviewRatingViewController.swift
//  JobDeal
//
//  Created by Priba on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import TransitionButton
import ImageViewer

class BuyerPreviewRatingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CreateOfferDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var buyerMainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyerHolderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyerAvatarImageView: UIImageView!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var buyerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var buyerRateView: CosmosView!
    @IBOutlet weak var buyerRateCountLbl: UILabel!
    @IBOutlet weak var buyerHolderView: UIView!
    
    @IBOutlet weak var jobContractsLbl: UILabel!
    @IBOutlet weak var activeJobs: UILabel!
    
    @IBOutlet weak var rateTableView: UITableView!
    @IBOutlet weak var activeUserIndicator: UIButton!
    
    @IBOutlet weak var roundingView: UIView!
    @IBOutlet weak var goToTopBackView: UIView!
    @IBOutlet weak var goToTopBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var myInfoView: UIView!
    @IBOutlet weak var jobContracts: UILabel!
    @IBOutlet weak var jobContractsValueLbl: UILabel!
    @IBOutlet weak var spentLbl: UILabel!
    @IBOutlet weak var spentValueLbl: UILabel!
    
    @IBOutlet weak var botBtn: TransitionButton!
    @IBOutlet weak var botConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ratedAsLbl: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    // MARK: - Public Properties
    var buyerProfile = UserModel()
    var rateArray = [RateModel]()
    var myInfo : NSDictionary? = nil
    var user = DataManager.sharedInstance.loggedUser
    

    // MARK: - Private Properties
    private var galleryController: GalleryViewController?
    private var imageGalleryItem: GalleryItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "buyer_statistic", uppercased: true), withGradient: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped(gestureRecognizer:)))
        buyerAvatarImageView.isUserInteractionEnabled = true
        buyerAvatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        rateTableView.estimatedRowHeight = 150
        rateTableView.rowHeight = UITableView.automaticDimension
        rateTableView.layer.cornerRadius = 10
        roundingView.layer.cornerRadius = 10
        rateTableView.layer.applySketchShadow()
        buyerHolderView.layer.cornerRadius = 10
        emptyView.layer.cornerRadius = 10
        buyerRateView.isUserInteractionEnabled = false
        buyerHolderView.layer.applySketchShadow()

        buyerAvatarImageView.setHalfCornerRadius()
        
        if buyerProfile.Id == DataManager.sharedInstance.loggedUser.Id {
            buyerNameLbl.text = buyerProfile.name + " " + buyerProfile.surname
        } else {
            buyerNameLbl.text = buyerProfile.name
        }
        buyerLocationLbl.text = buyerProfile.city
        
        pinIV.tintColor = UIColor.darkGray
        buyerRateCountLbl.text = buyerProfile.getUserBuyerRatingString()
        buyerRateView.rating = buyerProfile.buyerRating
        buyerAvatarImageView.sd_setImage(with: URL(string: buyerProfile.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)

        rateTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        goToTopBackView.layer.cornerRadius = 10
        
        activeUserIndicator.isHidden = !buyerProfile.isPaid

        self.view.backgroundColor = UIColor.separatorColor
        
        if myInfo != nil {
            myInfoView.isHidden = false
            spentLbl.setupTitleForKey(key: "spent")
            jobContracts.setupTitleForKey(key: "job_contracts")
            
            self.jobContractsValueLbl.text = "\(myInfo!["buyerContracts"] ?? "/")"
            self.spentValueLbl.text = "\(myInfo!["buyerSpent"] ?? "/") \(DataManager.sharedInstance.loggedUser.currency)"
            botConstraint.constant = 72
            botBtn.setupForTransitionLayoutTypeBlack()
            botBtn.isHidden = false
            botBtn.setupTitleForKey(key: "create_a_job", uppercased: true)
        } else {
            myInfoView.isHidden = true
            botConstraint.constant = 16
            botBtn.isHidden = true
        }
        
        aboutMeTextView.isEditable = false
        if buyerProfile.aboutMe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aboutMeTextView.removeFromSuperview()
            buyerMainViewHeightConstraint.constant = 130
            buyerHolderViewHeightConstraint.constant = 140
        } else {
            aboutMeTextView.text = buyerProfile.aboutMe
        }
    }
    
    override func setupStrings() {
        jobContractsLbl.setupTitleForKey(key: "job_contracts")
        activeJobs.text = String(buyerProfile.activeJobs) + " " + LanguageManager.sharedInstance.getStringForKey(key: "active")
        goToTopBtn.setupTitleForKey(key: "go_to_top", uppercased: true)
        
        ratedAsLbl.text = String(buyerProfile.name) + " " + NSLocalizedString("rated_as_buyer", comment: "")
        
    }
    
    override func loadData() {
        page = 0
        isEndOfList = false
        
        if buyerProfile.role == .buyer {
            ServerManager.sharedInstance.getBuyerRate(user: buyerProfile, page: page) { (response, success, errMsg) in
                self.rateArray = [RateModel]()
                
                if response.count > 0 {
                    self.emptyView.isHidden = true
                } else {
                    self.isEndOfList = true
                }
                
                if success! {
                    print(response)
                    for dict in response{
                        let rate = RateModel(dict: dict)
                        self.rateArray.append(rate)
                    }
                    self.rateTableView.reloadData()
                }
            }
        } else {
            ServerManager.sharedInstance.getDoerRate(user: buyerProfile, page: page) { (response, success, errMsg) in
                self.rateArray = [RateModel]()
                if success!{
                    print(response)
                    
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
    }
    
    // MARK: - Private Methods
    private func loadNextPage() {
        page += 1
        
        if buyerProfile.role == .buyer {
            ServerManager.sharedInstance.getBuyerRate(user: buyerProfile, page: page) { (response, success, errMsg) in
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                if success!{
                    print(response)
                    for dict in response{
                        let rate = RateModel(dict: dict)
                        self.rateArray.append(rate)
                    }
                    self.rateTableView.reloadData()
                }
            }
        } else {
            ServerManager.sharedInstance.getDoerRate(user: buyerProfile, page: page) { (response, success, errMsg) in
                if success!{
                    print(response)
                    
                    if response.count == 0 {
                        self.isEndOfList = true
                    }
                    
                    for dict in response {
                        let rate = RateModel(dict: dict)
                        self.rateArray.append(rate)
                    }
                    self.rateTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - CreateOfferDelegate Delegate
    func offerCreated(offer: OfferModel) {
        let vc = UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
        vc.offer = offer
        self.navigationController?.pushViewController(vc, animated: true)
        
        loadData()
    }
    
    func didEditOffer(offer: OfferModel) {
        let vc = UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
        vc.offer = offer
        self.navigationController?.pushViewController(vc, animated: true)
        
        loadData()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == rateArray.count - 2 && !isEndOfList{
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
    @IBAction func activeJobsBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyerActiveOffersViewController") as! BuyerActiveOffersViewController
        vc.buyerProfile = buyerProfile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goTopBtnAction(_ sender: Any) {
        rateTableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func botBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CreateOfferViewController") as! CreateOfferViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func avatarImageViewTapped(gestureRecognizer: UITapGestureRecognizer) {
        imageGalleryItem = GalleryItem.image(fetchImageBlock: { [weak self] (imageCompletion) in
            guard let self = self else { return }
            
            imageCompletion(self.buyerAvatarImageView.image)
            self.imageGalleryItem = nil
        })
        
        galleryController = GalleryViewController(startIndex: 0,
                                                       itemsDataSource: self,
                                                       itemsDelegate: nil,
                                                       displacedViewsDataSource: nil,
                                                       configuration: Utils.getCommonGalleryConfiguration())
        presentImageGallery(self.galleryController!)
    }
}

// MARK: - GalleryItemsDataSource
extension BuyerPreviewRatingViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imageGalleryItem!
    }
}

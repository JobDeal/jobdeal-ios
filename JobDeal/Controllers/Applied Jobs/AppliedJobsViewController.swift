//
//  BuyerActiveOffersViewController.swift
//  JobDeal
//
//  Created by Priba on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import ImageViewer

class AppliedJobsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum AppliedJobType: Int {
        case active = 1
        case expired
    }
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tabHeaderView: UIView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointingImageView: UIImageView!
    @IBOutlet weak var activeJobsButton: UIButton!
    @IBOutlet weak var expiredJobsButton: UIButton!
    @IBOutlet weak var buyerAvatarImageView: UIImageView!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var buyerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var buyerRateView: CosmosView!
    @IBOutlet weak var rateCountLbl: UILabel!
    @IBOutlet weak var buyerHolderView: UIView!
    @IBOutlet weak var activeUserIndicator: UIButton!
    @IBOutlet weak var activeJobsCollectionView: UICollectionView!
    @IBOutlet weak var expiredJobsCollectionView: UICollectionView!
    
    // MARK: - Public Properties
    var buyerProfile = UserModel()
    
    // MARK: - Private Properties
    private var activeJobsArray = [OfferModel]()
    private var expiredJobsArray = [OfferModel]()
    private var galleryController: GalleryViewController?
    private var imageGalleryItem: GalleryItem?
    
    private let activeJobsRefreshControl = UIRefreshControl()
    private let expiredJobsRefreshControl = UIRefreshControl()
    
    private var activeJobsPage = 0
    private var expiredJobsPage = 0
    
    private var isEndOfActiveJobsList = false
    private var isEndOfExpiredJobsList = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "applied_jobs", uppercased: true), withGradient: true)
        
        if #available(iOS 10.0, *) {
            activeJobsCollectionView.refreshControl = activeJobsRefreshControl
            expiredJobsCollectionView.refreshControl = expiredJobsRefreshControl
        } else {
            activeJobsCollectionView.addSubview(activeJobsRefreshControl)
            expiredJobsRefreshControl.addSubview(expiredJobsRefreshControl)
        }
        
        activeJobsRefreshControl.tintColor = UIColor.mainButtonColor
        activeJobsRefreshControl.addTarget(self, action: #selector(activeJobsRefreshControlValueChanged), for: .valueChanged)
        
        expiredJobsRefreshControl.tintColor = UIColor.mainButtonColor
        expiredJobsRefreshControl.addTarget(self, action: #selector(expiredJobsRefreshControlValueChanged), for: .valueChanged)
        
        if Utils.isIphoneSeriesX() {
            headerViewTopConstraint.constant = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let colorTop = UIColor.mainColor1.cgColor
        let colorBottom = UIColor.mainColor2.cgColor
        let gl: CAGradientLayer = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.startPoint = CGPoint(x: 0.0, y: 1.0)
        gl.endPoint = CGPoint(x: 1.0, y: 0.0)
        gl.frame = tabHeaderView.bounds
        
        tabHeaderView.layer.insertSublayer(gl, at: 0)
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        movePointingArrow(index: 0)
        pointingImageView.tintColor = UIColor.white
        buyerHolderView.layer.applySketchShadow()
        buyerHolderView.layer.cornerRadius = 10
        buyerRateView.isUserInteractionEnabled = false
        buyerAvatarImageView.setHalfCornerRadius()
        buyerNameLbl.text = buyerProfile.name + " " + buyerProfile.surname
        buyerLocationLbl.text = buyerProfile.city
        pinIV.tintColor = UIColor.darkGray
        buyerRateView.rating = buyerProfile.buyerRating
        rateCountLbl.text = buyerProfile.getUserBuyerRatingString()
        
        buyerAvatarImageView.sd_setImage(with: URL(string: buyerProfile.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        activeUserIndicator.isHidden = !buyerProfile.isPaid
        activeUserIndicator.isUserInteractionEnabled = false
        
        self.view.backgroundColor = UIColor.separatorColor
        
        activeJobsCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped(gestureRecognizer:)))
        buyerAvatarImageView.isUserInteractionEnabled = true
        buyerAvatarImageView.addGestureRecognizer(tapGesture)
    }
    
    override func setupStrings() {
        activeJobsButton.setupTitleForKey(key: "active_jobs")
        expiredJobsButton.setupTitleForKey(key: "expired_jobs")
    }
    
    override func loadData() {
        getActiveJobs()
        getExpiredJobs()
    }
    
    // MARK: - Helper Methods
    func loadNextPage() {
        if activeJobsButton.isSelected {
            activeJobsPage += 1
            
            ServerManager.sharedInstance.getUserAppliedJobsV2(type: AppliedJobType.active.rawValue, page: self.activeJobsPage) { (response, success, errMsg) in
                if success! {
                    if response.count == 0 {
                        self.isEndOfActiveJobsList = true
                    }
                    
                    for dict in response {
                        let offer = OfferModel(dict: dict)
                        self.activeJobsArray.append(offer)
                    }
                    self.activeJobsCollectionView.reloadData()
                    
                } else {
                    self.activeJobsPage -= 1
                }
            }
        } else if expiredJobsButton.isSelected {
            expiredJobsPage += 1
            
            ServerManager.sharedInstance.getUserAppliedJobsV2(type: AppliedJobType.expired.rawValue, page: self.expiredJobsPage) { (response, success, errMsg) in
                if success! {
                    if response.count == 0 {
                        self.isEndOfExpiredJobsList = true
                    }
                    
                    for dict in response {
                        let offer = OfferModel(dict: dict)
                        self.expiredJobsArray.append(offer)
                    }
                    self.expiredJobsCollectionView.reloadData()
                    
                } else {
                    self.expiredJobsPage -= 1
                }
            }
        }
    }
    
    private func getActiveJobs() {
        activeJobsPage = 0
        
        ServerManager.sharedInstance.getUserAppliedJobsV2(type: AppliedJobType.active.rawValue, page: activeJobsPage) { (response, success, errMsg) in
            self.activeJobsRefreshControl.endRefreshing()
            
            if success! {
                if response.count == 0 {
                    self.isEndOfActiveJobsList = true
                }
                
                self.activeJobsArray = [OfferModel]()
                for dict in response {
                    let offer = OfferModel(dict: dict)
                    self.activeJobsArray.append(offer)
                }
                self.activeJobsCollectionView.reloadData()
                
            } else {
                self.activeJobsPage -= 1
            }
        }
    }
    
    private func getExpiredJobs() {
        expiredJobsPage = 0
        
        ServerManager.sharedInstance.getUserAppliedJobsV2(type: AppliedJobType.expired.rawValue, page: expiredJobsPage) { (response, success, errMsg) in
            self.expiredJobsRefreshControl.endRefreshing()
            
            if success! {
                if response.count == 0 {
                    self.isEndOfExpiredJobsList = true
                }
                
                self.expiredJobsArray = [OfferModel]()
                for dict in response {
                    let offer = OfferModel(dict: dict)
                    self.expiredJobsArray.append(offer)
                }
                self.expiredJobsCollectionView.reloadData()
                
            } else {
                self.expiredJobsPage -= 1
            }
        }
    }
    
    private func movePointingArrow(index:Int) {
        self.view.layer.removeAllAnimations()
        switch index {
        case 0:
            activeJobsButton.isSelected = true
            expiredJobsButton.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.activeJobsButton.center.x
                self.view.layoutIfNeeded()
            }
            break
        
        case 1:
            expiredJobsButton.isSelected = true
            activeJobsButton.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.expiredJobsButton.center.x
                self.view.layoutIfNeeded()
            }
            break
            
        default:
            break
        }
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == activeJobsCollectionView {
            return activeJobsArray.count
        } else if collectionView == expiredJobsCollectionView {
            return expiredJobsArray.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == activeJobsCollectionView {
            if indexPath.row < activeJobsArray.count {
                
                if indexPath.row == self.activeJobsArray.count - 1 {
                    self.loadNextPage()
                }
                
                let tmp = activeJobsArray[indexPath.row]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
                cell.populateWith(offer: tmp)
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else if collectionView == expiredJobsCollectionView {
            if indexPath.row < expiredJobsArray.count {
                
                if indexPath.row == self.expiredJobsArray.count - 1 {
                    self.loadNextPage()
                }
                
                let tmp = expiredJobsArray[indexPath.row]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
                cell.populateWith(offer: tmp)
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width / 2
        let collectionViewHeight = collectionView.bounds.width * 2 / 3 + 30
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var offer: OfferModel?
        if collectionView == activeJobsCollectionView {
            offer = activeJobsArray[indexPath.row]
        } else if collectionView == expiredJobsCollectionView {
            offer = expiredJobsArray[indexPath.row]
        }
        
        guard let offer = offer else { return }
        
        let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
        vc.offer = offer
        vc.isEndController = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Actions
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
    
    @objc func activeJobsRefreshControlValueChanged() {
       getActiveJobs()
    }
    
    @objc func expiredJobsRefreshControlValueChanged() {
        getExpiredJobs()
    }
    
    @IBAction func activeJobsButtonAction(_ sender: UIButton) {
        movePointingArrow(index: 0)
        scrollView.scrollRectToVisible(self.activeJobsCollectionView.frame, animated: true)
    }
    
    @IBAction func expiredJobsButtonAction(_ sender: UIButton) {
        movePointingArrow(index: 1)
        scrollView.scrollRectToVisible(self.expiredJobsCollectionView.frame, animated: true)
    }
}

// MARK: - GalleryItemsDataSource
extension AppliedJobsViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imageGalleryItem!
    }
}

// MARK: - UIScrollViewDelegate
extension AppliedJobsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.isEqual(self.scrollView)) {
            let page:Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            movePointingArrow(index: page)
        }
    }
}

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

class BuyerActiveOffersViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    @IBOutlet weak var buyerAvatarImageView: UIImageView!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var buyerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var buyerRateView: CosmosView!
    @IBOutlet weak var rateCountLbl: UILabel!
    @IBOutlet weak var buyerHolderView: UIView!
    @IBOutlet weak var activeUserIndicator: UIButton!
    @IBOutlet weak var offersCollectionView: UICollectionView!

    // MARK: - Public Properties
    var buyerProfile = UserModel()
    var offersArray = [OfferModel]()
    
    // MARK: - Private Properties
    private var galleryController: GalleryViewController?
    private var imageGalleryItem: GalleryItem?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "buyer_profile", uppercased: true), withGradient: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped(gestureRecognizer:)))
        buyerAvatarImageView.isUserInteractionEnabled = true
        buyerAvatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Overridden Methods
    override func setupUI(){
        //buyerHolderView.layer.cornerRadius = 10
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
        
        offersCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        
    }
    
    override func setupStrings() {
    }
    
    override func loadData() {
        ServerManager.sharedInstance.getUserPostedJobs(user: self.buyerProfile, page: self.page) { (response, success, errMsg) in
            if success! {
                print(response)
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                self.offersArray = [OfferModel]()
                for dict in response {
                    let offer = OfferModel(dict: dict)
                    self.offersArray.append(offer)
                }
                self.offersCollectionView.reloadData()
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    }
    
    // MARK: - Private Methods
    func loadNextPage() {
    
        page += 1
        
        ServerManager.sharedInstance.getUserPostedJobs(user: self.buyerProfile, page: self.page) { (response, success, errMsg) in
            if success! {
                print(response)
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                for dict in response {
                    let offer = OfferModel(dict: dict)
                    self.offersArray.append(offer)
                }
                self.offersCollectionView.reloadData()
                
            } else {
                self.page -= 1
            }
        }
    }

    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row < offersArray.count) {
            
            if (indexPath.row == self.offersArray.count - 1 && !self.isEndOfList) {
                self.loadNextPage()
            }
            
            let tmp = offersArray[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
            
            cell.populateWith(offer: tmp)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width / 2
        let collectionViewHeight = collectionView.bounds.width * 2 / 3 + 30
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offer = self.offersArray[indexPath.row]
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
}

// MARK: - GalleryItemsDataSource
extension BuyerActiveOffersViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imageGalleryItem!
    }
}

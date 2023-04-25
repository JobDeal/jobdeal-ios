//
//  BookmarksUIViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/21/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import SideMenu
import GoogleMaps
import Toast_Swift

class BookmarksViewController: BaseViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JobOfferDelegate {
    
    @IBOutlet weak var bookMarksCollectionView: UICollectionView!
    
    var offersArray = [OfferModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar(title:LanguageManager.sharedInstance.getStringForKey(key: "bookmarks", uppercased: true), withGradient: true)
    }

    //MARK: - Private Methods
    
    override func setupUI(){
      bookMarksCollectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    
      self.view.backgroundColor = UIColor.separatorColor
    }
    override func setupStrings(){
        
        
    }
    
    override func loadData() {
        page = 0
        isEndOfList = false
        presentMidLoader()
        ServerManager.sharedInstance.getAllBookmarks(page: page) { (response, success, errMsg) in
            self.dismissLoader()
            if success!{
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                self.offersArray = [OfferModel]()
                for dict in response {
                    let job = OfferModel(dict: dict)
                    self.offersArray.append(job)
                }
                self.bookMarksCollectionView.reloadData()

            }else{
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    }
    
    func loadNextPage() {
        page += 1

        ServerManager.sharedInstance.getAllBookmarks(page: page) { (response, success, errMsg) in
            if success!{
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                for dict in response {
                    let job = OfferModel(dict: dict)
                    self.offersArray.append(job)
                }
                self.bookMarksCollectionView.reloadData()
            }else{
                self.page -= 1
            }
        }
    }

    
    // MARK: - Bookmarks CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offersArray.count
        //return isEndOfList ? self.offersArray.count : self.offersArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row < offersArray.count){
            let tmp = offersArray[indexPath.row]
            
            if indexPath.row == self.offersArray.count - 1 && !isEndOfList {
                loadNextPage()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
            
            cell.populateWith(offer: tmp)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpinerCollectionViewCell", for: indexPath) as! SpinerCollectionViewCell
            cell.spinerView.startAnimating()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width/2
        let collectionViewHeight = collectionView.bounds.width*2/3 + 30
        
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let offer = self.offersArray[indexPath.row]
        let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
        vc.offer = offer
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: - JobOffer Delegate
    
    func jobOfferUpdated(offer: OfferModel) {
        
        loadData()
    }
    
    func jobDeleted(offer: OfferModel) {
        
    }
}

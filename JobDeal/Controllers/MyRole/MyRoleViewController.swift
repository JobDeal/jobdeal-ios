//
//  MyRoleBuyerViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 2/1/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Cosmos

class MyRoleViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var userCityLabel: UILabel!
    @IBOutlet weak var activeUserIndicator: UIButton!
    
    @IBOutlet weak var sinceLbl: UILabel!
    
    @IBOutlet weak var doerHolderView: UIView!
    @IBOutlet weak var doerLbl: UILabel!
    @IBOutlet weak var doerRateLbl: UILabel!
    @IBOutlet weak var doerRateView: CosmosView!
    
    @IBOutlet weak var buyerHolderView: UIView!
    @IBOutlet weak var buyerLbl: UILabel!
    @IBOutlet weak var buyerRateView: CosmosView!
    @IBOutlet weak var buyerRateLbl: UILabel!
    
    @IBOutlet weak var jobsDoneLbl: UILabel!
    @IBOutlet weak var earnedLbl: UILabel!
    @IBOutlet weak var jobContractsLbl: UILabel!
    @IBOutlet weak var spentLbl: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    // MARK: - Public Properties
    var user = UserModel()
    var myInfo = NSDictionary()
    var rateArray = [RateModel]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "my_statistic", uppercased: true), withGradient: true)
    }
    
    // MARK: - Overridden Methods
    override func setupUI() {
        self.view.backgroundColor = UIColor.baseBackgroundColor
        doerRateView.isUserInteractionEnabled = false
        placeImageView.tintColor = UIColor.darkGray
        avatarImageView.setHalfCornerRadius()
        
        headerView.layer.cornerRadius = 10
        headerView.layer.applySketchShadow()
        
        doerHolderView.layer.cornerRadius = 10
        doerHolderView.layer.applySketchShadow()
        
        buyerHolderView.layer.cornerRadius = 10
        buyerHolderView.layer.applySketchShadow()
        
        aboutMeTextView.isEditable = false
    }
    
    override func setupStrings() {
        doerLbl.setupTitleForKey(key: "rated_as_doer", uppercased: true)
        buyerLbl.setupTitleForKey(key: "rated_as_buyer", uppercased: true)
    }
    
    override func loadData() {
        avatarImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        
        nameLbl.text = user.getUserFullName()
        userCityLabel.text = user.city
        sinceLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "user_since") + " " + user.createdAt
        
        doerRateLbl.text = user.getUserDoerRatingString()
        buyerRateLbl.text = user.getUserBuyerRatingString()

        doerRateView.rating = user.doerRating
        buyerRateView.rating = user.buyerRating
        
        activeUserIndicator.isHidden = !user.isPaid
        activeUserIndicator.isUserInteractionEnabled = false
        
        ServerManager.sharedInstance.getUser(id: Int(DataManager.sharedInstance.loggedUser.Id)) { (response, success, errMsg) in
            if success!, let myInfo = response["myInfo"] as? NSDictionary{
                self.jobsDoneLbl.text = "\(LanguageManager.sharedInstance.getStringForKey(key: "jobs_done")) \(myInfo["doerJobsDone"] ?? "/")"
                self.earnedLbl.text = "\(LanguageManager.sharedInstance.getStringForKey(key: "earned")) \(myInfo["doerEarned"] ?? "/") \(self.user.currency)"
                self.spentLbl.text = "\(LanguageManager.sharedInstance.getStringForKey(key: "spent")) \(myInfo["buyerSpent"] ?? "/") \(self.user.currency)"
                self.jobContractsLbl.text = "\(LanguageManager.sharedInstance.getStringForKey(key: "job_contracts")) \(myInfo["buyerContracts"] ?? "/")"
                self.myInfo = myInfo
            }
        }
        
        if user.aboutMe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            aboutMeTextView.removeFromSuperview()
            headerViewHeightConstraint.constant = 100
        } else {
            aboutMeTextView.text = user.aboutMe
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticUserHeaderTableViewCell", for: indexPath) as! StatisticUserHeaderTableViewCell
            cell.populateCell(user: self.user)
            
            return cell
        } else if indexPath.row < rateArray.count + 1 {
            let rate = rateArray[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "RateUserTableViewCell", for: indexPath) as! RateUserTableViewCell
            cell.populateCell(rate: rate)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Actions
    @IBAction func doerStatisticBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "RateDoer", bundle: nil).instantiateViewController(withIdentifier: "DoerRatePreviewViewController") as! DoerRatePreviewViewController
        vc.doerProfile = self.user
        vc.myInfo = self.myInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func buyerStatisticBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "RateBuyer", bundle: nil).instantiateViewController(withIdentifier: "BuyerPreviewRatingViewController") as! BuyerPreviewRatingViewController
        vc.buyerProfile = self.user
        vc.myInfo = self.myInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

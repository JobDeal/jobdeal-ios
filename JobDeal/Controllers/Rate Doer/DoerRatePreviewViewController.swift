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

class DoerRatePreviewViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, KlarnaPaymentDelegate {
    
    @IBOutlet weak var doerAvatarImageView: UIImageView!
    @IBOutlet weak var doerNameLbl: UILabel!
    @IBOutlet weak var doerLocationLbl: UILabel!
    @IBOutlet weak var pinIV: UIImageView!
    @IBOutlet weak var doerRateView: CosmosView!
    @IBOutlet weak var doerRateCountLbl: UILabel!
    @IBOutlet weak var doerHolderView: UIView!
    
    @IBOutlet weak var rateTableView: UITableView!
    @IBOutlet weak var activeUserIndicator: UIButton!
    
    @IBOutlet weak var roundingView: UIView!
    @IBOutlet weak var goToTopBackView: UIView!
    @IBOutlet weak var goToTopBtn: UIButton!
    @IBOutlet weak var activeUserBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var jobsDoneLbl: UILabel!
    @IBOutlet weak var jobsDoneValueLbl: UILabel!
    @IBOutlet weak var earnedLbl: UILabel!
    @IBOutlet weak var earnedValueLbl: UILabel!
    @IBOutlet weak var botBtn: TransitionButton!
    
    @IBOutlet weak var ratedAsLbl: UILabel!
    
    var doerProfile = UserModel()
    var myInfo = NSDictionary()
    var rateArray = [RateModel]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: LanguageManager.sharedInstance.getStringForKey(key: "doer_statistic", uppercased: true), withGradient: true)
    }
    
    // MARK: - Overriden Methods
    override func setupUI() {
        rateTableView.estimatedRowHeight = 150
        rateTableView.rowHeight = UITableView.automaticDimension
        rateTableView.layer.cornerRadius = 10
        roundingView.layer.cornerRadius = 10
        rateTableView.layer.applySketchShadow()
        doerHolderView.layer.cornerRadius = 10
        doerHolderView.layer.applySketchShadow()
        emptyView.layer.cornerRadius = 10
        doerRateView.isUserInteractionEnabled = false
        doerAvatarImageView.setHalfCornerRadius()
        doerNameLbl.text = doerProfile.name + " " + doerProfile.surname
        doerLocationLbl.text = doerProfile.city
        pinIV.tintColor = UIColor.darkGray
        doerRateView.rating = doerProfile.doerRating
        doerRateCountLbl.text = doerProfile.getUserDoerRatingString()
        doerAvatarImageView.sd_setImage(with: URL(string: doerProfile.avatar), placeholderImage: UIImage(named: "avatar1"), options: .refreshCached, completed: nil)
        
        rateTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        goToTopBackView.layer.cornerRadius = 10
        
        activeUserIndicator.isHidden = !doerProfile.isPaid
        activeUserIndicator.isUserInteractionEnabled = false
        
        self.view.backgroundColor = UIColor.separatorColor
        botBtn.setupForTransitionLayoutTypeBlack()
        
        activeUserBtn.titleLabel?.numberOfLines = 1;
        activeUserBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        activeUserBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }
    
    override func setupStrings() {
        goToTopBtn.setupTitleForKey(key: "go_to_top", uppercased: true)
        
        if doerProfile.isPaid {
            activeUserBtn.setupTitleForKey(key: "cancel_active_doer", uppercased: true)
        } else {
            activeUserBtn.setupTitleForKey(key: "become_active_doer", uppercased: true)
        }
        
        ratedAsLbl.setupTitleForKey(key: "rated_as_doer")
        earnedLbl.setupTitleForKey(key: "earned")
        jobsDoneLbl.setupTitleForKey(key: "jobs_done")
        botBtn.setupTitleForKey(key: "check_job")

        jobsDoneValueLbl.text = "\(myInfo["doerJobsDone"] ?? "/")"
        earnedValueLbl.text = "\(myInfo["doerEarned"] ?? "/") \(DataManager.sharedInstance.loggedUser.currency)"
    }
    
    override func loadData() {
        page = 0
        isEndOfList = false
        
        ServerManager.sharedInstance.getDoerRate(user: doerProfile, page: page) { (response, success, errMsg) in
            self.rateArray = [RateModel]()
            if success!{

                if response.count > 0 {
                    self.emptyView.isHidden = true
                }else{
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
    
    override func chosenKlarna() {
        // Dismiss ChoosePaymentViewController
        dismiss(animated: true, completion: nil)
        
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
        vc.paymentType = .subscription
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private Helper Methods
    private func loadNextData() {
        page += 1
        
        ServerManager.sharedInstance.getDoerRate(user: doerProfile, page: page) { (response, success, errMsg) in
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
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == rateArray.count - 2 && !isEndOfList{
            loadNextData()
        }
        
        let rate = rateArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RateUserTableViewCell", for: indexPath) as! RateUserTableViewCell
        cell.populateCell(rate: rate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - KlarnaPaymentDelegate
    func didFinishWithSuccess(payment: PaymentModel) {
        dismissLoader()
        
        if payment.status == "PAID" {
            DataManager.sharedInstance.loggedUser = payment.user
            self.doerProfile = payment.user
            self.loadData()
            self.setupUI()
            self.setupStrings()
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_success"),
                completion: { (index, str) in
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
    
    // MARK: - Actions
    @IBAction func activeUserBtnAction(_ sender: Any) {
        AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "do_you_want_to_cancel"), aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "yes")) { (index, title) in
            if index == 1{
                self.presentLoader()
                ServerManager.sharedInstance.klarnaCancelSubscriptionPayment(completition: { (response, success, errMsg) in
                    self.dismissLoader()
                    if success!{
                        DataManager.sharedInstance.loggedUser = UserModel(dict: response)
                        self.doerProfile = UserModel(dict: response)
                        self.loadData()
                        self.setupUI()
                        self.setupStrings()
                    } else {
                        AJAlertController.initialization().showAlertWithOkButton(
                            aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"),
                            completion: { (index, str) in
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func goTopBtnAction(_ sender: Any) {
        rateTableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func botBtnAction(_ sender: Any) {
        let vc = UIStoryboard(name: "AppliedJobs", bundle: nil).instantiateViewController(withIdentifier:
            "AppliedJobsViewController") as! AppliedJobsViewController
        vc.buyerProfile = DataManager.sharedInstance.loggedUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

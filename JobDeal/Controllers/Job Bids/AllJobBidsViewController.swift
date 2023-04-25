//
//  AllJobBidsViewController.swift
//  JobDeal
//
//  Created by Priba on 2/11/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class AllJobBidsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet private weak var bidsTableView: UITableView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var jobImageView: UIImageView!
    @IBOutlet private weak var jobName: UILabel!
    @IBOutlet private weak var clockImageView: UIButton!
    @IBOutlet private weak var jobExpirationLbl: UILabel!
    @IBOutlet private weak var descLbl: UILabel!
    @IBOutlet private weak var priceLbl: UILabel!
    @IBOutlet private weak var underBidderView: UIView?
    @IBOutlet private weak var underBidderLabel: UILabel?
    @IBOutlet private weak var unlockButton: UIButton?
    
    // MARK: - Public Properties
    var bidsArray = [BidModel]()
    var jobOffer = OfferModel()
    
    var selectedBid = BidModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title:LanguageManager.sharedInstance.getStringForKey(key: "check_doers", uppercased: true), withGradient: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    // MARK: - Overridden Methods
    override func setupUI() {
       
        bidsTableView.estimatedRowHeight = UITableView.automaticDimension
        bidsTableView.rowHeight = UITableView.automaticDimension
        
        bidsTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.backgroundColor = UIColor.baseBackgroundColor
        
        headerView.layer.cornerRadius = 8
        headerView.layer.applySketchShadow()
        
        jobImageView.layer.cornerRadius = 8
        jobImageView.sd_setImage(with: URL(string: jobOffer.imagesURLs.first ?? ""), placeholderImage: UIImage(named: "imagePlaceholder"), options: .fromCacheOnly, completed: nil)
        priceLbl.text = jobOffer.getFullPrice()
        jobName.text = jobOffer.name
        if jobOffer.isExpired {
            jobExpirationLbl.setupTitleForKey(key: "job_expired")
        } else {
            jobExpirationLbl.text = jobOffer.expireAt
        }
        descLbl.text = jobOffer.description
        if jobOffer.isSpeedy {
            clockImageView.tintColor = UIColor.speedyRedColor
            jobExpirationLbl.textColor = UIColor.speedyRedColor
        }
        
        if jobOffer.isUnderbidderListed {
            underBidderView?.removeFromSuperview()
        } else {
            underBidderLabel?.setupTitleForKey(key: "unlock_underbidders_label_text")
            unlockButton?.setupTitleForKey(key: "unlock_underbidders_button_title")
        }
    }
    
    override func setupStrings() { }
    
    override func loadData() {
        // This means that payment with Swish was successful so dismiss the payment dialog and show list of doers
        if navigationController?.visibleViewController is ChoosePaymentViewController {
            navigationController?.dismiss(animated: true)
        }
        
        ServerManager.sharedInstance.getJobById(id: self.jobOffer.id){ (response, success, message) in
            if success! {
                let jobOffer = OfferModel.init(dict: response)
                self.jobOffer = jobOffer
                self.setupUI()
            }
        }
        
        ServerManager.sharedInstance.getApplicantsForJob(jobOffer: self.jobOffer) { (response, success, errMsg) in
            if success! {
                self.bidsArray = [BidModel]()
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                for dict in response {
                    let bid = BidModel.init(dict: dict)
                    self.bidsArray.append(bid)
                }
                self.bidsTableView.reloadData()
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    }
    
    override func chosenSwish() {
        if !UIApplication.shared.canOpenURL(URL(string: "swish://")!){
            AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "swish_app_missing"), completion: { (index, str) in
            })
            return
        }
        
        ServerManager.sharedInstance.swishJobPayment(
            type: PriceCalculationType.payUnderBidderList.rawValue,
            job: jobOffer
        ) { (response, success, errMsg) in
            if success!, let refId = response["refId"] as? String {
                
                UserDefaults.standard.set(refId, forKey: "lastRefId")
                UIApplication.shared.open(URL(string: "swish://paymentrequest?token=\(refId)&callbackurl=com.jobDeal://swish/complete")!, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func chosenKlarna() {
        // Dismiss ChoosePaymentViewController
        dismiss(animated: true)
        
        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
        vc.paymentType = .underBidderList
        vc.targetJob = jobOffer
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private Helper Methods
    private func showChooseDoer(forBid bid: BidModel) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ChooseDoerViewController") as! ChooseDoerViewController
        vc.bid = bid
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK:- UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !isEndOfList && bidsArray.count == 0 ? 1 : bidsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < bidsArray.count {
            let bid = bidsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllJobBidTableViewCell", for: indexPath) as! AllJobBidTableViewCell
            cell.populateWith(bid: bid)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpinerTableViewCell", for: indexPath) as! SpinerTableViewCell
            cell.spiner.startAnimating()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bid = bidsArray[indexPath.row]
        guard !bid.bidJob.isExpired else { return }
        
        self.selectedBid = bid
        
        var alreadyChosen = false
        for bid in bidsArray {
            alreadyChosen = alreadyChosen || bid.choosed
        }
        
        if alreadyChosen && bid.choosed {
            // If doer has already chosen, show doer details
            showChooseDoer(forBid: bid)
        } else if !alreadyChosen && bid.bidPrice >= bid.bidJob.price {
            // If doer has no chosen but bid price is more or same as job price, show doer details
            showChooseDoer(forBid: bid)
        } else if bid.bidJob.isUnderbidderListed {
            // If buyer payed to see doers which offered less than job price, show doer details
            showChooseDoer(forBid: bid)
        } else if bid.bidPrice < bid.bidJob.price && !bid.bidJob.isUnderbidderListed {
            presentChoosePaymentScreen(job: jobOffer, type: .payUnderBidderList)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Actions
private extension AllJobBidsViewController {
    @IBAction private func unlockButtonAction(_ sender: UIButton) {
        presentChoosePaymentScreen(job: jobOffer, type: .payUnderBidderList)
    }
}

// MARK: - KlarnaPaymentDelegate
extension AllJobBidsViewController: KlarnaPaymentDelegate {
    func didFinishWithSuccess(payment: PaymentModel) {
        dismissLoader()
        
        if payment.status == "PAID" {
            jobOffer = payment.job
            DataManager.sharedInstance.loggedUser = payment.user
            loadData()
            setupUI()
            
            DispatchQueue.main.async {
                AJAlertController.initialization().showAlertWithOkButton(
                    aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_success"),
                    completion: { _, _ in })
                self.underBidderView?.removeFromSuperview()
            }
            
        } else {
            DispatchQueue.main.async {
                AJAlertController.initialization().showAlertWithOkButton(
                    aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_failed"),
                    completion: { _, _ in
                        self.navigationController?.popToViewController(self, animated: true)
                })
            }
        }
    }
    
    func didFinishWithFailure(errorMessage: String) {
        navigationController?.popToViewController(self, animated: true)
    }
}

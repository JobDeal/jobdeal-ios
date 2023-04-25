//
//  JobBidsViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 2/6/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class JobBidsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var jobBidsTableView: UITableView!
    
    var jobOffers = [OfferModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar(title:LanguageManager.sharedInstance.getStringForKey(key: "job_bids", uppercased: true), withGradient:  true )
    }
    
    override func setupUI() {
        self.view.backgroundColor = UIColor.baseBackgroundColor
        jobBidsTableView.backgroundColor = UIColor.clear
        
    }
    
    override func loadData() {
        ServerManager.sharedInstance.getUserPostedJobs(user: DataManager.sharedInstance.loggedUser, page: page, completition: { (response, success, errMsg) in
            
            if success! {
                
                if response.count == 0 {
                    self.isEndOfList = true
                }
                
                self.jobOffers = [OfferModel]()
                for dict in response {
                    let job = OfferModel.init(dict: dict)
                    if !job.isExpired {
                        self.jobOffers.append(job)
                    }
                }
                
                if self.jobOffers.isEmpty {
                    self.isEndOfList = true
                }
                
                self.jobBidsTableView.reloadData()
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        })
    }
    
    func loadNextPage() {
        page += 1
        
        let user = DataManager.sharedInstance.loggedUser
        ServerManager.sharedInstance.getUserPostedJobs(user: user, page: page, completition: { (response, success, errMsg) in
            if success! {
                
                if response.count < 10 {
                    self.isEndOfList = true
                }
                
                for dict in response {
                    let job = OfferModel.init(dict: dict)
                    if !job.isExpired {
                        self.jobOffers.append(job)
                    }
                }
                
                self.jobBidsTableView.reloadData()
                
            } else {
                self.page -= 1
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEndOfList ? self.jobOffers.count : self.jobOffers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < jobOffers.count) {
            
            if indexPath.row + 3 == jobOffers.count && !isEndOfList {
                loadNextPage()
            }
            
            let temp = jobOffers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobBidsTableViewCell", for: indexPath) as! JobBidsTableViewCell
            cell.populateWith(offer: temp)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpinerTableViewCell", for: indexPath) as! SpinerTableViewCell
            cell.spiner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < jobOffers.count) {
            let temp = jobOffers[indexPath.row]
            
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = temp
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

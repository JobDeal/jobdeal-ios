//
//  MessagesViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/22/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class MessagesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum NotificationType: Int {
        case doer = 0
        case buyer
    }
  
    // MARK: - Outlets
    @IBOutlet weak var tabHeaderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doerInboxMessageTableView: UITableView!
    @IBOutlet weak var buyerInboxMessageTableView: UITableView!
    @IBOutlet weak var inboxView: UIView!
    @IBOutlet weak var doerButton: UIButton!
    @IBOutlet weak var buyerButton: UIButton!
    @IBOutlet weak var pointingImageView: UIImageView!
    @IBOutlet weak var doerUnreadIndicator: UILabel!
    @IBOutlet weak var buyerUnreadIndicator: UILabel!
    
    // MARK: - Private Properties
    private let doerRefreshControl = UIRefreshControl()
    private let buyerRefreshControl = UIRefreshControl()
    var user = DataManager.sharedInstance.loggedUser

    
    private var doerPage = 0
    private var buyerPage = 0
    
    private var isEndOfDoerList = false
    private var isEndOfBuyerList = false

    // MARK: - Public Properties
    var doerInboxArray = [MessageModel]()
    var buyerInboxArray = [MessageModel]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar(title:LanguageManager.sharedInstance.getStringForKey(key: "notifications", uppercased: true), withGradient: true)
        
        if #available(iOS 10.0, *) {
            doerInboxMessageTableView.refreshControl = doerRefreshControl
            buyerInboxMessageTableView.refreshControl = buyerRefreshControl
        } else {
            doerInboxMessageTableView.addSubview(doerRefreshControl)
            buyerInboxMessageTableView.addSubview(buyerRefreshControl)
        }
        
        Utils.removeNotificationsCount()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: Notification.Name(rawValue: "pushNotificationReceived"), object: nil)
        
        doerRefreshControl.tintColor = UIColor.mainButtonColor
        doerRefreshControl.addTarget(self, action: #selector(doerRefreshControlValueChange), for: .valueChanged)
        
        buyerRefreshControl.tintColor = UIColor.mainButtonColor
        buyerRefreshControl.addTarget(self, action: #selector(buyerRefreshControlValueChanged), for: .valueChanged)
        
        if Utils.isIphoneSeriesX() {
            headerViewTopConstraint.constant = (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotifications()
        
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
        
        doerInboxMessageTableView.backgroundColor = UIColor.clear
        doerInboxMessageTableView.separatorColor  = UIColor.clear
        doerInboxMessageTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        buyerInboxMessageTableView.backgroundColor = UIColor.clear
        buyerInboxMessageTableView.separatorColor  = UIColor.clear
        buyerInboxMessageTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        doerUnreadIndicator.setHalfCornerRadius()
        buyerUnreadIndicator.setHalfCornerRadius()
        
        inboxView.backgroundColor = UIColor.baseBackgroundColor
    }
    
    override func setupStrings() {
        doerButton.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "doer_tab_title"), for: .normal)
        buyerButton.setTitle(LanguageManager.sharedInstance.getStringForKey(key: "buyer_tab_title"), for: .normal)
    }
    
    // MARK: - Helper Methods
    private func loadNotifications() {
        doerInboxArray.removeAll()
        doerInboxMessageTableView.reloadData()
        buyerInboxArray.removeAll()
        buyerInboxMessageTableView.reloadData()
        
        getDoerNotifications()
        getBuyerNotifications()
    }
    
    /*
     Since we now filter notification in the backend,
     this will not return the correct undread amount.
     
     Endpoint "/notification/types/\(type)/\(page)"
     should return correct amount based on filtering.
     */
    
    // private func refreshUnreadCount() {
    //     ServerManager.sharedInstance.getUnreadNotificationCount(){(response, success, errMsg) in
    //         if success! {
    //             let unreadCount = UnreadCount.init(dict: response)

    //             if(unreadCount.unreadBuyerCount > 0){
    //                 self.buyerUnreadIndicator.isHidden = false
    //                 self.buyerUnreadIndicator.text = String(unreadCount.unreadBuyerCount)
    //             } else {
    //                 self.buyerUnreadIndicator.isHidden = true
    //             }

    //             if(unreadCount.unreadDoerCount > 0){
    //                 self.doerUnreadIndicator.isHidden = false
    //                 self.doerUnreadIndicator.text = String(unreadCount.unreadDoerCount)
    //             } else {
    //                 self.doerUnreadIndicator.isHidden = true
    //             }
    //         }
    //     }
    // }
    
    private func refreshUnreadCount(isBuyer: Bool, unreadCount: Int){
        if isBuyer {
            if(unreadCount > 0){
                self.buyerUnreadIndicator.isHidden = false
                self.buyerUnreadIndicator.text = String(unreadCount)
            } else {
                self.buyerUnreadIndicator.isHidden = true
            }

        } else {
            if(unreadCount > 0){
                self.doerUnreadIndicator.isHidden = false
                self.doerUnreadIndicator.text = String(unreadCount)
            } else {
                self.doerUnreadIndicator.isHidden = true
            }
        }
    }
    
    private func getDoerNotifications() {
        doerPage = 0
        var unreadCount: Int = 0
        // Doer Notifications
        ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.doer.rawValue, page: page) { (response, success, errMsg) in
            self.doerRefreshControl.endRefreshing()

            if success! {
                if response.count == 0 {
                    self.isEndOfDoerList = true
                }
                
                self.doerInboxArray = [MessageModel]()
                for dict in response {
                    let inbox = MessageModel.init(dict: dict)
                    if !inbox.isSeen {
                        unreadCount = unreadCount + 1
                    }
                    self.doerInboxArray.append(inbox)
                }
                self.doerInboxMessageTableView.reloadData()
                self.refreshUnreadCount(isBuyer: false, unreadCount: unreadCount)
                
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    }
    
    private func getBuyerNotifications() {
        buyerPage = 0
        var unreadCount: Int = 0
        // Buyer Notifications
        ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.buyer.rawValue, page: page) { (response, success, errMsg) in
            self.buyerRefreshControl.endRefreshing()

            if success! {
                if response.count == 0 {
                    self.isEndOfBuyerList = true
                }
                
                self.buyerInboxArray = [MessageModel]()
                for dict in response {
                    let inbox = MessageModel.init(dict: dict)
                    if !inbox.isSeen {
                        unreadCount = unreadCount + 1
                    }
                    print(inbox.isSeen)
                    self.buyerInboxArray.append(inbox)
                }
                self.buyerInboxMessageTableView.reloadData()
                self.refreshUnreadCount(isBuyer: true, unreadCount: unreadCount)

                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    }

    private func movePointingArrow(index:Int) {
        self.view.layer.removeAllAnimations()
        switch index {
        case 0:
            buyerButton.isSelected = true
            doerButton.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.buyerButton.center.x
                self.view.layoutIfNeeded()
            }
            break
        
        case 1:
            doerButton.isSelected = true
            buyerButton.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.doerButton.center.x
                self.view.layoutIfNeeded()
            }
            break
            
        default:
            break
        }
    }
    
    private func loadNextPage() {
        if doerButton.isSelected {
            doerPage += 1
            ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.doer.rawValue, page: doerPage) { (response, success, errMsg) in
                if success! {
                    
                    if response.count == 0 {
                        self.isEndOfDoerList = true
                    }
                    
                    for dict in response {
                        let inbox = MessageModel.init(dict: dict)
                        self.doerInboxArray.append(inbox)
                    }
                    self.doerInboxMessageTableView.reloadData()
                    
                } else {
                    self.doerPage -= 1
                }
            }
        } else if buyerButton.isSelected {
            buyerPage += 1
            ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.buyer.rawValue, page: buyerPage) { (response, success, errMsg) in
                if success! {
                    
                    if response.count == 0 {
                        self.isEndOfBuyerList = true
                    }
                    
                    for dict in response {
                        let inbox = MessageModel.init(dict: dict)
                        self.buyerInboxArray.append(inbox)
                    }
                    self.buyerInboxMessageTableView.reloadData()
                    
                } else {
                    self.buyerPage -= 1
                }
            }
        }
    }
    
    // MARK: - Notifications
    @objc func refreshList() {
        if doerButton.isSelected {
            doerRefreshControlValueChange()
        } else if buyerButton.isSelected {
            buyerRefreshControlValueChanged()
        }
        Utils.removeNotificationsCount()
    }
    
    // MARK: - Actions
    @IBAction func doyerButtonAction(_ sender: UIButton) {
        movePointingArrow(index: 1)
        scrollView.scrollRectToVisible(self.doerInboxMessageTableView.frame, animated: true)
    }
    
    @IBAction func buyerButtonAction(_ sender: UIButton) {
        movePointingArrow(index: 0)
        scrollView.scrollRectToVisible(self.buyerInboxMessageTableView.frame, animated: true)
    }
    
    @objc func doerRefreshControlValueChange() {
        getDoerNotifications()
    }
    
    @objc func buyerRefreshControlValueChanged() {
        getBuyerNotifications()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == doerInboxMessageTableView {
            return isEndOfDoerList ? self.doerInboxArray.count : self.doerInboxArray.count + 1
        } else if tableView == buyerInboxMessageTableView {
            return isEndOfBuyerList ? self.buyerInboxArray.count : self.buyerInboxArray.count + 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == doerInboxMessageTableView {
            if indexPath.row < doerInboxArray.count {
                if indexPath.row == doerInboxArray.count - 1 && !isEndOfDoerList {
                    loadNextPage()
                }
                
                let tmp = doerInboxArray[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InboxMessageTableViewCell", for: indexPath) as! InboxMessageTableViewCell
                
                cell.populateWith(inboxMessage:tmp)
                return cell
            } else {
                if !isEndOfDoerList {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SpinerTableViewCell", for: indexPath) as! SpinerTableViewCell
                    cell.spiner.startAnimating()
                    return cell
                }
            }
        } else if tableView == buyerInboxMessageTableView {
            if indexPath.row < buyerInboxArray.count {
                if indexPath.row == buyerInboxArray.count - 1 && !isEndOfBuyerList {
                    loadNextPage()
                }
                
                let tmp = buyerInboxArray[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InboxMessageTableViewCell", for: indexPath) as! InboxMessageTableViewCell
                
                cell.populateWith(inboxMessage:tmp)
                return cell
            } else {
                if !isEndOfBuyerList {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SpinerTableViewCell", for: indexPath) as! SpinerTableViewCell
                    cell.spiner.startAnimating()
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == doerInboxMessageTableView && indexPath.row < doerInboxArray.count) ||
            (tableView == buyerInboxMessageTableView && indexPath.row < buyerInboxArray.count) {
            
            let message = doerButton.isSelected ? doerInboxArray[indexPath.row] : buyerInboxArray[indexPath.row]
            print("MESSAGE_TYPE:\(message.type)")
            message.isSeen = true
            ServerManager.sharedInstance.readNotification(id: message.id)
            switch message.type {
            case .doerBid:
                
                let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
                vc.offer = message.job
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .buyerAccepted:
                
                let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
                vc.offer = message.job
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .wishListJob:
                
                let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
                vc.offer = message.job
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .rateDoer:
                
                let vc =  UIStoryboard(name: "RateBuyer", bundle: nil).instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
                vc.offer = message.job
                vc.ratingDoer = true
                vc.ratingUser = message.sender
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .rateBuyer:
                
                let vc =  UIStoryboard(name: "RateBuyer", bundle: nil).instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
                vc.offer = message.job
                vc.ratingDoer = false
                vc.ratingUser = message.sender
                self.navigationController?.pushViewController(vc, animated: true)
                
            default:
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - UIScrollViewDelegate
extension MessagesViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.isEqual(self.scrollView)) {
            let page:Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            movePointingArrow(index: page)
        }
    }
}

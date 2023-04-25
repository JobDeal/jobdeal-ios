//
//  DashboardViewController.swift
//  JobDeal
//
//  Created by Priba on 12/8/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import SideMenu
import GoogleMaps
import Toast_Swift
import Foundation
import GoogleUtilities
import SwiftEntryKit
import MaterialComponents

class DashboardViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, GMSMapViewDelegate, LocationDelegate, CreateOfferDelegate, JobOfferDelegate, KlarnaPaymentDelegate,JobOfferEditDelegate {
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addOfferBtn: MDCFloatingButton!
    @IBOutlet weak var jobsBtn: UIButton!
    @IBOutlet weak var speedyJobsBtn: UIButton!
    @IBOutlet weak var deliveryJobsBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jobsCollectionView: UICollectionView!
    @IBOutlet weak var speedyCollectionView: UICollectionView!
    @IBOutlet weak var deliveryCollectionView: UICollectionView!
    @IBOutlet weak var sortHeaderLbl: UILabel!
    @IBOutlet weak var sortOptionView: UIView!
    @IBOutlet weak var sortTitleLbl: UILabel!
    @IBOutlet weak var publishedLbl: UILabel!
    @IBOutlet weak var priceSortLbl: UILabel!
    @IBOutlet weak var jobsCountLbl: UILabel!
    @IBOutlet weak var expirationDateLbl: UILabel!
    @IBOutlet weak var notificationIndicatorView: UIView!
    @IBOutlet var buttonsSortArray : [UIButton]!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pointingImageView: UIImageView!
    @IBOutlet weak var versionText: UILabel!
        
    var selectedSort = "published"
    var selectedSortDirection = "DESC"
    var selectedIndex = 1
    var selectedTmpSort = "published"
    var selectedTmpSortDirection = "DESC"
    var selectedTmpIndex = 1

    var sideMenuKey = ""
    
    var userMarker: GMSMarker = GMSMarker()
 
    private let jobsRefreshControl = UIRefreshControl()
    private let speedyJobsRefreshControl = UIRefreshControl()
    private let deliveryJobsRefreshControl = UIRefreshControl()
    
    var offersArray = [OfferModel]()
    var speedyOffersArray = [OfferModel]()
    var deliveryOffersArray = [OfferModel]()
    var mapOffersArray = [OfferModel]()
    var mapMarkersArray = [GMSMarker]()
    var becomeBuyerRequested = false
    var becomeDoerRequested = false

    var pageSpeedy = 0
    var isEndOfSpeedyList = true
    
    var pageDelivery = 0
    var isEndOfDeliveryList = true

    var userLastTargetLocation = CLLocation()
    var lastUserDistance: CLLocationDistance = 50000
    var shouldLoadMarkerPlaceOnIdle = true

    var firstLocation = true
    var offer = OfferModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE: Because in the app will be only "Jobs" tab visible, this is quick solution to prevent user to scroll and see other jobs
        // Remove this line of code when we get back "Speedy" and "Delivery" jobs
        scrollView.isScrollEnabled = false
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)

        self.mapView.isHidden = true
        self.mapBtn.isSelected = false
        
        self.jobsCollectionView.reloadData()
        
        self.mapView.animate(toLocation: CLLocationCoordinate2D.init(latitude: 44.810407, longitude: 20.447849))
        mapView.animate(toZoom: 13)
        
        userMarker = GMSMarker()
        userMarker.position = mapView.camera.target
        userMarker.icon = UIImage(named: "userMarker")
        userMarker.map = mapView

        self.view.backgroundColor = UIColor.separatorColor

        headerView.layer.applySketchShadow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),name: Notification.Name(rawValue: "filterUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sideMenuNotification(notification:)), name: Notification.Name(rawValue: "sideMenuNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushNotificationReceived(notification:)), name: Notification.Name(rawValue: "pushNotificationReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openNotifications), name: Notification.Name(rawValue: "openNotifications"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(rawValue: "loadData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if let flag = UserDefaults.standard.value(forKey: "openNotificationDidLaunch") as? Bool, flag{
            UserDefaults.standard.set(false, forKey: "openNotificationDidLaunch")
            openNotifications()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = UserDefaults.standard.value(forKey: "visitedJobId") as? Int, id > 0 {
            UserDefaults.standard.set(0, forKey: "visitedJobId")
            
            let offer = OfferModel()
            offer.id = id
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = offer
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        reloadData()
        updateUnreadNotificationIndicatorIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSideMenuKey()
        refreshUnreadNotificationCount()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addGradientToBackground()
    }
    
    override func setupUI() {
        addOfferBtn.setupTitleForKey(key: "create_an_ad")
        addOfferBtn.setTitleFont(UIFont.systemFont(ofSize: 14), for: .normal)
        addOfferBtn.setMode(.expanded, animated: true)
        
        jobsBtn.isSelected = true
        pointingImageView.tintColor = UIColor.white
        notificationIndicatorView.setHalfCornerRadius()
        
        updateUnreadNotificationIndicatorIfNeeded()
        
        jobsBtn.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        jobsBtn.setTitleColor(UIColor.white, for: .selected)
        jobsBtn.titleLabel?.font = jobsBtn.titleLabel?.font.withSize(20)

        speedyJobsBtn.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        speedyJobsBtn.setTitleColor(UIColor.white, for: .selected)
        
        speedyCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        jobsCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        deliveryCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        
        mapView.setMinZoom(8, maxZoom: 16)
        
        getCategories()
        
        // Jobs
        if #available(iOS 10.0, *) {
            jobsCollectionView.refreshControl = jobsRefreshControl
        } else {
            jobsCollectionView.addSubview(jobsRefreshControl)
        }
        jobsRefreshControl.tintColor = UIColor.mainButtonColor
        jobsRefreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        // Speedy Jobs
        if #available(iOS 10.0, *) {
            speedyCollectionView.refreshControl = speedyJobsRefreshControl
        } else {
            speedyCollectionView.addSubview(speedyJobsRefreshControl)
        }
        speedyJobsRefreshControl.tintColor = UIColor.mainButtonColor
        speedyJobsRefreshControl.addTarget(self, action: #selector(loadSpeedyJobsData), for: .valueChanged)
        // Delivery Jobs
        if #available(iOS 10.0, *) {
            deliveryCollectionView.refreshControl = deliveryJobsRefreshControl
        } else {
            deliveryCollectionView.addSubview(deliveryJobsRefreshControl)
        }
        deliveryJobsRefreshControl.tintColor = UIColor.mainButtonColor
        deliveryJobsRefreshControl.addTarget(self, action: #selector(loadDeliveryJobsData), for: .valueChanged)
        
        sortOptionView.layer.cornerRadius = 10
        sortOptionView.layer.applySketchShadow()

        //Sort View
        buttonsSortArray.setHalfCornerRadiusToAll()
        sortBtn.layer.cornerRadius = 10
    }

    override func setupStrings(){

        self.jobsBtn.setupTitleForKey(key: "jobs")
        self.speedyJobsBtn.setupTitleForKey(key: "speedy_jobs")
        self.deliveryJobsBtn.setupTitleForKey(key: "delivery_jobs")
        changeSortStatus()

        self.sortTitleLbl.setupTitleForKey(key: "sort_by", uppercased: true)
        publishedLbl.setupTitleForKey(key: "published")
        priceSortLbl.setupTitleForKey(key: "price_sort")
        expirationDateLbl.setupTitleForKey(key: "expiration_sort")
        sortBtn.setupTitleForKey(key: "sort_search", uppercased: true)
        for button in buttonsSortArray{
            button.changeSelectedBackground()
            switch button.tag {
                
            case 1: button.setupTitleForKey(key: "lastest")
            case 2: button.setupTitleForKey(key: "oldest")
            case 3: button.setupTitleForKey(key: "lowest")
            case 4: button.setupTitleForKey(key: "highest")
            case 5: button.setupTitleForKey(key: "first")
            case 6: button.setupTitleForKey(key: "last")
            default: break
            }
        }
    }
    
    private func handleBackgroundNotificationIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "openNotificationOnWakeUp") || UserDefaults.standard.bool(forKey: "openNotificationDidLaunch") else {
            return
        }
        
        if let userInfo = UserDefaults.standard.dictionary(forKey: "notificationUserInfo") {
            if let action = userInfo["action"] as? String,
               let actionInt = Int(action),
               let notificationType = NotificationType(rawValue: actionInt),
               let notificationData = (userInfo["job"] as? String)?.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: notificationData, options: .allowFragments),
               let notificationJSON = jsonObject as? [String : Any] {
                
                switch notificationType {
                case .doerBid, .buyerAccepted, .wishListJob:
                    guard
                        let offerIdInt = notificationJSON["id"] as? Int,
                        let offer = offersArray.first(where: { $0.id == offerIdInt })
                    else {
                        Utils.cleanupUserDefaultsForPushNotifications()
                        return
                    }
                    
                    Utils.cleanupUserDefaultsForPushNotifications()
                    
                    // Do not present JobOfferViewController if it's already presented
                    guard !(self.navigationController?.visibleViewController?.isKind(of: JobOfferViewController.self) ?? false) else { return }
                    
                    offer.id = offerIdInt
                    let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
                    vc.offer = offer
                    vc.delegate = self
                    
                    readMessageOnLocalNotificationTap(for: offerIdInt)
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                case .rateBuyer, .rateDoer:
                    guard
                        let offerIdInt = notificationJSON["id"] as? Int,
                        let offer = offersArray.first(where: { $0.id == offerIdInt }),
                        let senderDict = notificationJSON["sender"] as? NSDictionary
                    else {
                        Utils.cleanupUserDefaultsForPushNotifications()
                        return
                    }
                    
                    Utils.cleanupUserDefaultsForPushNotifications()
                    
                    // Do not present RateViewController if it's already presented
                    guard !(self.navigationController?.visibleViewController?.isKind(of: RateViewController.self) ?? false) else { return }
                    
                    let vc =  UIStoryboard(name: "RateBuyer", bundle: nil).instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
                    vc.offer = offer
                    vc.ratingUser = UserModel(dict: senderDict)
                    vc.ratingDoer = notificationType == .rateDoer
                    self.navigationController?.pushViewController(vc, animated: true)

                default:
                    sideMenuKey = "messages"
                    checkSideMenuKey()
                    Utils.cleanupUserDefaultsForPushNotifications()
                }
            }
        } else {
            sideMenuKey = "messages"
            checkSideMenuKey()
            Utils.cleanupUserDefaultsForPushNotifications()
        }
    }
    
    private func readMessageOnLocalNotificationTap(for offerId: Int) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.tryToReadNotification(
                for: .buyer,
                and: offerId
            ) { didReadBuyer in
                if !didReadBuyer {
                    self.tryToReadNotification(
                        for: .doer,
                        and: offerId,
                        onComplete: { didReadDoer in
                            if didReadDoer {
                                self.dercreaseNotificationByOne()
                            }
                        }
                    )
                } else {
                    self.dercreaseNotificationByOne()
                }
            }
        }
    }
    
    private func tryToReadNotification(
        for type: MessagesViewController.NotificationType,
        and offerId: Int,
        onComplete: ((Bool) -> ())?
    ) {
        ServerManager.sharedInstance.getNotificationsByType(
            type: type.rawValue,
            page: page
        ) { (response, success, errMsg) in
            let resp = response.compactMap { MessageModel(dict: $0) }
            
            let message: MessageModel? = resp.first { $0.job.id == offerId }
            
            if let message = message, message.isSeen == false {
                ServerManager.sharedInstance.readNotification(id: message.id)
                onComplete?(true)
            } else {
                onComplete?(false)
            }
        }
    }
    
    private func dercreaseNotificationByOne() {
        let currentNotificationCount = DataManager.sharedInstance.loggedUser.notificationCount
        DataManager.sharedInstance.loggedUser.notificationCount = currentNotificationCount - 1
        
        Utils.decreaseNotificationCount()
    }
    
    private func updateUnreadNotificationIndicatorIfNeeded() {
        if DataManager.sharedInstance.loggedUser.notificationCount > 0 {
            notificationIndicatorView.isHidden = false
        } else {
            notificationIndicatorView.isHidden = true
        }
    }
    
    func getCategories() {
        ServerManager.sharedInstance.getCategories { (response, success, errMsg) in
            self.jobsRefreshControl.endRefreshing()
            if success! {
                DataManager.sharedInstance.categoriesArray.removeAll()
                for dict in response {
                    let category = CategoryModel.init(dict: dict)
                    DataManager.sharedInstance.categoriesArray.append(category)
                }
                DataManager.sharedInstance.mainFilterCategories = DataManager.sharedInstance.categoriesArray.clone()
                DataManager.sharedInstance.mainFilterCategories.deselectAllCategories()
                DataManager.sharedInstance.mainFilterCategories.selectFromFilter(filter: DataManager.sharedInstance.mainFilter)
                DataManager.sharedInstance.wishListCategories = DataManager.sharedInstance.categoriesArray.clone()
                DataManager.sharedInstance.wishListCategories.deselectAllCategories()
                DataManager.sharedInstance.wishListCategories.selectFromFilter(filter: DataManager.sharedInstance.wishListFilter)
            }
        }
    }
    
    @objc override func loadData() {
        jobsRefreshControl.tintColor = UIColor.mainButtonColor
        jobsRefreshControl.beginRefreshing()
        
        page = 0
        isEndOfList = false
        
        ServerManager.sharedInstance.getJobs(speedy:false, page: page, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.jobsRefreshControl.endRefreshing()
            
            if success! {
                let total = response["total"]
                self.jobsCountLbl.text = "\(total ?? "")"
                
                if let dictArray = response["jobs"] as? [NSDictionary] {
                    
                    if dictArray.count == 0 {
                        self.isEndOfList = true
                    }
                    
                    self.offersArray = [OfferModel]()
                    for dict in dictArray {
                        let job = OfferModel.init(dict: dict)
                        self.offersArray.append(job)
                    }
                    
                    self.jobsCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc func loadSpeedyJobsData() {
        speedyJobsRefreshControl.tintColor = UIColor.mainButtonColor
        speedyJobsRefreshControl.beginRefreshing()
        
        pageSpeedy = 0
        isEndOfSpeedyList = false
        
        ServerManager.sharedInstance.getJobs(speedy:true, page: pageSpeedy, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.speedyJobsRefreshControl.endRefreshing()

            if success! {
                
                if let dictArray = response["jobs"] as? [NSDictionary]{
                    
                    if dictArray.count == 0 {
                        self.isEndOfSpeedyList = true
                    }
                    
                    self.speedyOffersArray = [OfferModel]()
                    for dict in dictArray{
                        let job = OfferModel.init(dict: dict)
                        self.speedyOffersArray.append(job)
                    }
                    self.speedyCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc func loadDeliveryJobsData() {
        deliveryJobsRefreshControl.tintColor = UIColor.mainButtonColor
        deliveryJobsRefreshControl.beginRefreshing()
        
        pageDelivery = 0
        isEndOfDeliveryList = false
        
        ServerManager.sharedInstance.getJobs(speedy:false, delivery: true, page: pageDelivery, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.deliveryJobsRefreshControl.endRefreshing()

            if success! {
                
                if let dictArray = response["jobs"] as? [NSDictionary]{
                    
                    if dictArray.count == 0 {
                        self.isEndOfDeliveryList = true
                    }
                    
                    self.deliveryOffersArray = [OfferModel]()
                    for dict in dictArray{
                        let job = OfferModel.init(dict: dict)
                        self.deliveryOffersArray.append(job)
                    }
                    self.deliveryCollectionView.reloadData()
                }
            }
        }
    }
    
    func loadNextJobsPage() {
        page += 1
        
        ServerManager.sharedInstance.getJobs(speedy:false, page: page, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.jobsRefreshControl.endRefreshing()
            
            if success! {
                let total = response["total"]
                self.jobsCountLbl.text = "\(total ?? "")"
                
                if let dictArray = response["jobs"] as? [NSDictionary] {
                    
                    if dictArray.count == 0 {
                        self.isEndOfList = true
                    }
                    
                    for dict in dictArray{
                        let job = OfferModel.init(dict: dict)
                        self.offersArray.append(job)
                    }
                    self.jobsCollectionView.reloadData()
                }

            } else {
                self.page -= 1
            }
        }
    }
    
    func loadNextSpeedyPage() {
        pageSpeedy += 1
        
        ServerManager.sharedInstance.getJobs(speedy:true, page: pageSpeedy, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.speedyJobsRefreshControl.endRefreshing()
            
            if success! {
                if let dictArray = response["jobs"] as? [NSDictionary] {
                    
                    if dictArray.count == 0 {
                        self.isEndOfSpeedyList = true
                    }
                    
                    for dict in dictArray {
                        let job = OfferModel.init(dict: dict)
                        self.speedyOffersArray.append(job)
                    }
                    self.speedyCollectionView.reloadData()
                }
            } else {
                self.pageSpeedy -= 1
            }
        }
    }
    
    
    func loadNextDeliveryPage() {
        pageDelivery += 1
        
        ServerManager.sharedInstance.getJobs(speedy:false, delivery: true, page: pageDelivery, sortBy: selectedSort, sortDirection: selectedSortDirection) { (response, success, errMsg) in
            self.deliveryJobsRefreshControl.endRefreshing()
            
            if success! {
                if let dictArray = response["jobs"] as? [NSDictionary] {
                    
                    if dictArray.count == 0 {
                        self.isEndOfDeliveryList = true
                    }
                    
                    for dict in dictArray {
                        let job = OfferModel.init(dict: dict)
                        self.deliveryOffersArray.append(job)
                    }
                    self.deliveryCollectionView.reloadData()
                }
            } else {
                self.pageDelivery -= 1
            }
        }
    }
    
    func loadMapJobs(passDistaceCheck: Bool = false){
        
        let topRightCorner = mapView.projection.visibleRegion().farRight
        
        let coordinate0 = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        
        if userLastTargetLocation.distance(from: coordinate0) > Double(lastUserDistance)/2 && shouldLoadMarkerPlaceOnIdle || passDistaceCheck{
            let coordinate1 = CLLocation(latitude: topRightCorner.latitude, longitude: topRightCorner.longitude)
            
            let distance = coordinate0.distance(from: coordinate1)
            
            lastUserDistance = distance
            userLastTargetLocation = coordinate0
            
            let isSpeedy = speedyJobsBtn.isSelected
            let isDelivery = deliveryJobsBtn.isSelected
            ServerManager.sharedInstance.getMapJobs(speedy: isSpeedy, delivery: isDelivery, latitude: coordinate0.coordinate.latitude, longitude: coordinate0.coordinate.longitude, distance: distance) { (response, success, errMsg) in
                
                if success! {
                    if let dictArray = response["jobs"] as? [NSDictionary] {
                        self.mapOffersArray = [OfferModel]()
                        for dict in dictArray {
                            let job = OfferModel.init(dict: dict)
                            self.mapOffersArray.append(job)
                        }
                        self.loadMarkers()
                    }
                } else { // In case of error just remove all markers from map
                    self.mapOffersArray = [OfferModel]()
                    self.loadMarkers()
                }
            }
        } else if !shouldLoadMarkerPlaceOnIdle {
            shouldLoadMarkerPlaceOnIdle = true
        }
    }
    
    @objc func reloadData() {
        loadData()
        loadSpeedyJobsData()
        loadDeliveryJobsData()
    }
    
    @objc func didBecomeActiveNotification() {
        refreshUnreadNotificationCount()
    }
    
    func refreshUnreadNotificationCount(){
        if !DataManager.sharedInstance.isUserLoggedIn {
            return
        }
        enum NotificationType: Int {
            case doer = 0
            case buyer
        }
        
        var notificationCount: Int = 0
        ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.buyer.rawValue, page: 0) { (response, success, errMsg) in
            if success! {
        
                for dict in response {
                    let inbox = MessageModel.init(dict: dict)
                    if !inbox.isSeen {
                        notificationCount = notificationCount + 1
                    }
                   
                }
                
                ServerManager.sharedInstance.getNotificationsByType(type: NotificationType.doer.rawValue, page: 0) { (response, success, errMsg) in
                    if success! {
                
                        for dict in response {
                            let inbox = MessageModel.init(dict: dict)
                            if !inbox.isSeen {
                                notificationCount = notificationCount + 1
                            }
                           
                        }
                        DataManager.sharedInstance.loggedUser.notificationCount = notificationCount
                        self.updateUnreadNotificationIndicatorIfNeeded()
                        
                    } else {
                        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                        })
                    }
                }
                
            } else {
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "server_failure_message"), completion: { (index, str) in
                })
            }
        }
    
    }
    
    func movePointingArrow(index:Int){
        self.view.layer.removeAllAnimations()
        switch index {
        case 0:
            jobsBtn.isSelected = true
            speedyJobsBtn.isSelected = false
            deliveryJobsBtn.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.jobsBtn.center.x
                self.view.layoutIfNeeded()
            }
            break
        
        case 1:
            speedyJobsBtn.isSelected = true
            jobsBtn.isSelected = false
            deliveryJobsBtn.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.speedyJobsBtn.center.x
                self.view.layoutIfNeeded()
            }
            break
            
        case 2:
            deliveryJobsBtn.isSelected = true
            jobsBtn.isSelected = false
            speedyJobsBtn.isSelected = false
            UIView.animate(withDuration: 0.3) {
                self.pointingImageView.center.x = self.deliveryJobsBtn.center.x
                self.view.layoutIfNeeded()
            }
            break
            
        default:
            break
        }
        
    }
    
    func loadMarkers(){
        mapMarkersArray.removeAll()
        mapView.clear()
        userMarker.map = mapView
        
        DispatchQueue.main.async {
            for offer in self.mapOffersArray {
                let marker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: offer.latitude, longitude: offer.longitude))
                marker.map = self.mapView
                marker.iconView = Utils.getPriceMarkerViewFor(offer: offer)
                marker.userData = offer
                marker.tracksViewChanges = false
                marker.isFlat = false
                marker.zIndex = 0
                self.mapMarkersArray.append(marker)
            }
        }
    }
    
    func loadExtendendMarker(marker:GMSMarker){
        self.minimizeAllMarkers()
        view.addTransitionAnimationToView()
        mapView.padding = UIEdgeInsets(top: 240, left: 0, bottom: 0, right: 0)
        marker.iconView = Utils.getExtendedMarkerViewFor(offer: marker.userData as! OfferModel)
        marker.zIndex = 1
    }
    
    func minimizeAllMarkers(){
        view.addTransitionAnimationToView()
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        for marker in mapMarkersArray {
            marker.iconView = Utils.getPriceMarkerViewFor(offer: marker.userData as! OfferModel)
        }
    }
    
    @objc func pushNotificationReceived(notification:NSNotification) {
        
        if let userInfo = notification.userInfo as NSDictionary?, !(self.navigationController?.viewControllers.last?.isKind(of: MessagesViewController.self) ?? true){
            print(userInfo)

            guard let typeStr = userInfo["action"] as? String else{
                return
            }
            
            var typeInt = 0
            if Int(typeStr) != nil {
                typeInt = Int(typeStr)! - 1
            }
            
            let type = NotificationType(rawValue: typeInt)
            
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: .standardBackground)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .init(width: 1, height: 1)))
            attributes.statusBar = .dark
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
            attributes.positionConstraints.maxSize = .init(width: .intrinsic, height: .intrinsic)
            attributes.displayDuration = 4
            
            attributes.entryInteraction.customTapActions.append { [weak self] in
                guard let self = self else { return }
                self.handleBackgroundNotificationIfNeeded()
            }

            let title = EKProperty.LabelContent(text: userInfo["title"] as? String ?? "", style: .init(font: UIFont.systemFont(ofSize: 15, weight: .semibold), color: .black))
            let description = EKProperty.LabelContent(text: userInfo["body"] as? String ?? "", style: .init(font: UIFont.systemFont(ofSize: 13, weight: .medium), color: .black))
            
            let image = EKProperty.ImageContent(image: Utils.getColorImageForNotificationType(type: type ?? .doerBid), size: CGSize(width: 52, height: 52))
            
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationCount"), object: nil, userInfo: nil)
            
            updateUnreadNotificationIndicatorIfNeeded()
        }
    }
    
    @objc func openNotifications() {
        handleBackgroundNotificationIfNeeded()
    }
    
    @objc func sideMenuNotification(notification:NSNotification){
        if let dict = notification.userInfo as? [String : Any] {
            sideMenuKey = dict["key"] as! String
        }
        checkSideMenuKey()
    }
    
    func checkSideMenuKey() {
        if sideMenuKey != "" {
            
            switch sideMenuKey {
                
            case "logOut" :
                AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "log_out_check"), aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "log_out")) { (index, title) in
                    if index == 1{
                        ServerManager.sharedInstance.logOut()
                        UserDefaults.standard.removeObject(forKey: "authToken")
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    }
                }
                
            case "home":
                LocationManager.sharedInstance.stopUpdatingLocation()
                view.addTransitionAnimationToView()
                mapView.isHidden = true
                mapBtn.isSelected = false
                
            case "contactUs" :
                let vc =  UIStoryboard(name: "ContactUs", bundle: nil).instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "settings" :
                let vc =  UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "statistic" :
                let vc =  UIStoryboard(name: "MyRole", bundle: nil).instantiateViewController(withIdentifier: "MyRoleViewController") as! MyRoleViewController
                vc.user = DataManager.sharedInstance.loggedUser
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "becomePremium" :
                
                self.presentSubscriptionScreen(price: DataManager.sharedInstance.prices.subscribe, currency: DataManager.sharedInstance.prices.currency, message: LanguageManager.sharedInstance.getStringForKey(key: "subscription_message"))
                
                break
                
            case "wishList" :
                
                let vc =  UIStoryboard(name: "WishList", bundle: nil).instantiateViewController(withIdentifier: "WishListViewController") as! WishListViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
                break
                
            case "messages" :
                let vc =  UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "postedJobs" :
                let vc = UIStoryboard(name: "JobBids", bundle: nil).instantiateViewController(withIdentifier: "JobBidsViewController") as! JobBidsViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "appliedJobs" :
                let vc = UIStoryboard(name: "AppliedJobs", bundle: nil).instantiateViewController(withIdentifier: "AppliedJobsViewController") as! AppliedJobsViewController
                vc.buyerProfile = DataManager.sharedInstance.loggedUser
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "loginVisitor" :
                self.navigationController?.popToRootViewController(animated: true)
                
            default: break
                
            }
            sideMenuKey = ""
        }
    }
    
    override func chosenKlarna() {
        // Dismiss ChoosePaymentViewController
        dismiss(animated: true)

        let vc =  UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "KlarnaViewController") as! KlarnaViewController
        vc.paymentType = .subscription
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func openSortView(){
        buttonsSortArray.selectAtTag(tag: selectedIndex)
        view.addTransitionAnimationToView()
        self.sortOptionView.isHidden = false
    }
    
    func closeSortView(){
        if !sortOptionView.isHidden{
            changeSortStatus()
            view.addTransitionAnimationToView()
            self.sortOptionView.isHidden = true
        }
    }
    
    func changeSortStatus() {
        switch selectedIndex {
            case 1: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "published").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "lastest").uppercased()
            case 2: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "published").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "oldest").uppercased()
            case 3: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "price_sort").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "lowest").uppercased()
            case 4: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "price_sort").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "highest").uppercased()
            case 5: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "expiration_sort").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "first").uppercased()
            case 6: sortHeaderLbl.text = LanguageManager.sharedInstance.getStringForKey(key: "expiration_sort").uppercased() + " / " + LanguageManager.sharedInstance.getStringForKey(key: "last").uppercased()
            
            default: break
        }
    }
    
    //MARK: - Collection View Data Source and Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Jobs
        if collectionView == jobsCollectionView {
            if self.offersArray.count == 0 {
                return 0
            } else {
                return isEndOfList ? self.offersArray.count : self.offersArray.count + 1
            }
            
        } else if collectionView == speedyCollectionView { // Speedy Jobs
            if self.speedyOffersArray.count == 0 {
                return 0
            } else {
                return isEndOfSpeedyList ? self.speedyOffersArray.count : self.speedyOffersArray.count + 1
            }
        } else if collectionView == deliveryCollectionView {
            if self.deliveryOffersArray.count == 0 {
                return 0
            } else {
                return isEndOfList ? self.deliveryOffersArray.count : self.deliveryOffersArray.count + 1
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == jobsCollectionView {
            if(indexPath.row < offersArray.count) {
                
                if indexPath.row == offersArray.count - 1 && !isEndOfList {
                    self.loadNextJobsPage()
                }
                
                let tmp = offersArray[indexPath.row]
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
                
                cell.populateWith(offer: tmp)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpinerCollectionViewCell", for: indexPath) as! SpinerCollectionViewCell
                cell.spinerView.startAnimating()
                return cell
            }
            
        } else if collectionView == speedyCollectionView {
            if (indexPath.row < speedyOffersArray.count) {
                if indexPath.row == speedyOffersArray.count - 1 && !self.isEndOfSpeedyList {
                    self.loadNextSpeedyPage()
                }
                
                let tmp = speedyOffersArray[indexPath.row]
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
                
                cell.populateWith(offer: tmp)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpinerCollectionViewCell", for: indexPath) as! SpinerCollectionViewCell
                cell.spinerView.startAnimating()
                return cell
                
            }
        } else if collectionView == deliveryCollectionView {
            if(indexPath.row < deliveryOffersArray.count) {
                
                if indexPath.row == deliveryOffersArray.count - 1 && !isEndOfList {
                    self.loadNextDeliveryPage()
                }
                
                let tmp = deliveryOffersArray[indexPath.row]
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionViewCell", for: indexPath) as! OfferCollectionViewCell
                
                cell.populateWith(offer: tmp)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpinerCollectionViewCell", for: indexPath) as! SpinerCollectionViewCell
                cell.spinerView.startAnimating()
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width / 2
        let collectionViewHeight = collectionView.bounds.width * 2 / 3 + 30
        
        if collectionView == jobsCollectionView {
            if indexPath.row < self.offersArray.count {
                return CGSize(width: collectionViewWidth, height: collectionViewHeight)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 70)
            }
            
        } else if collectionView == speedyCollectionView {
            if indexPath.row < self.speedyOffersArray.count {
                return CGSize(width: collectionViewWidth, height: collectionViewHeight)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 70)
            }
        } else if collectionView == deliveryCollectionView {
            if indexPath.row < self.deliveryOffersArray.count {
                return CGSize(width: collectionViewWidth, height: collectionViewHeight)
            } else {
                return CGSize(width: collectionView.bounds.width, height: 70)
            }
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == jobsCollectionView {
            let offer = self.offersArray[indexPath.row]
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = offer
            vc.delegate = self
            vc.delegateEdit = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if collectionView == speedyCollectionView {
            let offer = self.speedyOffersArray[indexPath.row]
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = offer
            vc.delegate = self
            vc.delegateEdit = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == deliveryCollectionView {
            let offer = self.deliveryOffersArray[indexPath.row]
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = offer
            vc.delegate = self
            vc.delegateEdit = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        closeSortView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.isEqual(self.scrollView)) {
            let page:Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            movePointingArrow(index: page)
        }
    }

    //MARK: - Map delegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if (!(marker.iconView?.isKind(of: ExtendedMarker.self) ?? true)) {
            loadExtendendMarker(marker: marker)
            shouldLoadMarkerPlaceOnIdle = false
            mapView.animate(toLocation: marker.position)
        } else if(marker.isEqual(userMarker)) {
            return true
        } else {
            let offer = marker.userData as! OfferModel
            let vc =  UIStoryboard(name: "JobOffer", bundle: nil).instantiateViewController(withIdentifier: "JobOfferViewController") as! JobOfferViewController
            vc.offer = offer
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        minimizeAllMarkers()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        loadMapJobs()
    }
    
    //MARK: - CreateOfferDelegate Delegate

    func offerCreated(offer: OfferModel) {
        if offer.isDelivery {
            deliveryOffersArray.append(offer)
            deliveryCollectionView.reloadData()
        } else if offer.isSpeedy {
            speedyOffersArray.append(offer)
            speedyCollectionView.reloadData()
        } else {
            offersArray.append(offer)
            jobsCollectionView.reloadData()
        }
    }
    
    func didEditOffer(offer: OfferModel) {
        // Jobs
        guard let jobIndex = offersArray.firstIndex(where: {$0.id == offer.id}) else { return }
        offersArray[jobIndex] = offer
        jobsCollectionView.reloadData()
        // Speedy Jobs
        guard let speedyJobIndex = speedyOffersArray.firstIndex(where: {$0.id == offer.id}) else { return }
        speedyOffersArray[speedyJobIndex] = offer
        speedyCollectionView.reloadData()
        // Delivery Jobs
        guard let deliveryJobIndex = deliveryOffersArray.firstIndex(where: {$0.id == offer.id}) else { return }
        deliveryOffersArray[deliveryJobIndex] = offer
        deliveryCollectionView.reloadData()
    }

    //MARK: - Klarna Payment Delegate
    
    func didFinishWithSuccess(payment: PaymentModel) {
        self.dismissLoader()
        
        if payment.status == "PAID" {
            DataManager.sharedInstance.loggedUser = payment.user
            AJAlertController.initialization().showAlertWithOkButton(
                aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "payment_success"),
                completion: { _, _ in })
            
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
    
    //MARK: - JobOffer Delegate

    func jobOfferUpdated(offer: OfferModel) {
        
        if let index = offersArray.index(where: {$0.id == offer.id}) {
            offersArray[index] = offer
            jobsCollectionView.reloadData()
        }
        
        if let index = speedyOffersArray.index(where: {$0.id == offer.id}) {
            speedyOffersArray[index] = offer
            speedyCollectionView.reloadData()
        }
        
        if let index = deliveryOffersArray.index(where: {$0.id == offer.id}) {
            deliveryOffersArray[index] = offer
            deliveryCollectionView.reloadData()
        }
        
        if let index = mapOffersArray.index(where: {$0.id == offer.id}) {
            mapOffersArray[index] = offer
            loadMarkers()
        }
    }
    
    func jobDeleted(offer: OfferModel) {
        
        if let index = offersArray.index(where: {$0.id == offer.id}) {
            offersArray.remove(at: index)
            jobsCollectionView.reloadData()
        }
        
        if let index = speedyOffersArray.index(where: {$0.id == offer.id}) {
            speedyOffersArray.remove(at: index)
            speedyCollectionView.reloadData()
        }
        
        if let index = deliveryOffersArray.index(where: {$0.id == offer.id}) {
            deliveryOffersArray.remove(at: index)
            deliveryCollectionView.reloadData()
        }
        
        if let index = mapOffersArray.index(where: {$0.id == offer.id}) {
            mapOffersArray.remove(at: index)
            loadMarkers()
        }
    }
    
    //MARK: - Location Delegate

    func didUpdateLocations(newLocation: CLLocation) {
        
        if firstLocation {
            firstLocation = false
            mapView.animate(toLocation: newLocation.coordinate)
        }
        
        if(newLocation.course > 0){
            userMarker.rotation = newLocation.course
        }
        
        userMarker.position = newLocation.coordinate
        userMarker.zIndex = 1
        
        let dateOfLastLocationUpdate = DataManager.sharedInstance.dateOfLastLocationUpdate
        // Update location in range of 10 minutes so to avoid constatly sending API request to backend when user is moving
        if dateOfLastLocationUpdate == nil || dateOfLastLocationUpdate!.addingTimeInterval(600) <= Date()  {
            DataManager.sharedInstance.dateOfLastLocationUpdate = Date()
            ServerManager.sharedInstance.updateUserLocation(params: ["lat" : newLocation.coordinate.latitude,
                                                                     "lng" : newLocation.coordinate.longitude])
        }
    }
    
    //MARK: - Buttons actions

    @IBAction func mapBtnAction(_ sender: UIButton) {
        closeSortView()
        LocationManager.sharedInstance.delegate = self
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            LocationManager.sharedInstance.startUpdatingAccuratLocation()
            self.loadMapJobs(passDistaceCheck: true)
        } else {
            LocationManager.sharedInstance.stopUpdatingLocation()
        }
        view.addTransitionAnimationToView()
        self.mapView.isHidden = !sender.isSelected

    }
    
    @IBAction func jobsBtnAction(_ sender: UIButton) {
        closeSortView()
        movePointingArrow(index: 0)
        scrollView.scrollRectToVisible(self.jobsCollectionView.frame, animated: true)
        loadMapJobs(passDistaceCheck: mapBtn.isSelected)
    }
    
    @IBAction func speedyJobsBtnAction(_ sender: UIButton) {
        closeSortView()
        movePointingArrow(index: 1)
        scrollView.scrollRectToVisible(self.speedyCollectionView.frame, animated: true)
        loadMapJobs(passDistaceCheck: mapBtn.isSelected)
    }
    
    @IBAction func deliveryJobsBtnAction(_ sender: UIButton) {
        closeSortView()
        movePointingArrow(index: 2)
        scrollView.scrollRectToVisible(self.deliveryCollectionView.frame, animated: true)
        loadMapJobs(passDistaceCheck: mapBtn.isSelected)
    }
    
    @IBAction func addOfferBtnAction(_ sender: UIButton) {
        closeSortView()
        if(DataManager.sharedInstance.loggedUser.role == .visitor){
            
            AJAlertController.initialization().showAlert(aStrMessage: LanguageManager.sharedInstance.getStringForKey(key: "login_required"), aCancelBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "cancel"), aOtherBtnTitle: LanguageManager.sharedInstance.getStringForKey(key: "confirm")) { (index, title) in
                if index == 1{
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }else{
            let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CreateOfferViewController") as! CreateOfferViewController
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
      
    }
    
    @IBAction func filterBtnAction(_ sender: Any) {
        closeSortView()
        let vc =  UIStoryboard(name: "Filters", bundle: nil).instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController        
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Sort Actions
    @IBAction func opetSortViewAction(_ sender: Any) {
        view.addTransitionAnimationToView()
        buttonsSortArray.selectAtTag(tag: selectedIndex)
        sortOptionView.isHidden = !sortOptionView.isHidden
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        selectedIndex = selectedTmpIndex
        selectedSort = selectedTmpSort
        selectedSortDirection = selectedTmpSortDirection
        closeSortView()

        reloadData()
    }
    
    @IBAction func lastestBtnAction(_ sender: Any) {
        selectedTmpSort = "published"
        selectedTmpIndex = 1
        selectedTmpSortDirection = "DESC"
        buttonsSortArray.selectAtTag(tag: 1)
    }
    
    @IBAction func oldestBtnAction(_ sender: Any) {
        selectedTmpSort = "published"
        selectedTmpIndex = 2
        selectedTmpSortDirection = "ASC"
        buttonsSortArray.selectAtTag(tag: 2)
    }
    
    @IBAction func lowestBtnAction(_ sender: Any) {
        selectedTmpSort = "price"
        selectedTmpIndex = 3
        selectedTmpSortDirection = "ASC"
        buttonsSortArray.selectAtTag(tag: 3)
    }
    
    @IBAction func heighestBtnAction(_ sender: Any) {
        selectedTmpSort = "price"
        selectedTmpIndex = 4
        selectedTmpSortDirection = "DESC"
        buttonsSortArray.selectAtTag(tag: 4)
    }
    
    @IBAction func firstSortBtnAction(_ sender: Any) {
        selectedTmpSort = "expiration"
        selectedTmpIndex = 5
        selectedTmpSortDirection = "ASC"
        buttonsSortArray.selectAtTag(tag: 5)
    }
    
    @IBAction func lastSortBtnAction(_ sender: Any) {
        selectedTmpSort = "expiration"
        selectedTmpIndex = 6
        selectedTmpSortDirection = "DESC"
        buttonsSortArray.selectAtTag(tag: 6)
    }
}

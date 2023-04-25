//
//  WishListViewController.swift
//  JobDeal
//
//  Created by Priba on 3/5/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Foundation
import PWSwitch
import MultiSlider
import TransitionButton
import GoogleMaps
import TTRangeSlider

class WishListViewController: BaseViewController, CategorySelectorDelegate, AddressSelectionDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryTotalSelected: UILabel!
    
    @IBOutlet weak var priceTitleLbl: UILabel!
    @IBOutlet weak var priceValueLbl: UILabel!
    @IBOutlet weak var priceMinValueLbl: UILabel!
    @IBOutlet weak var priceMaxValueLbl: UILabel!
    @IBOutlet weak var priceSlider: TTRangeSlider!
    
    @IBOutlet weak var distanceTitleLbl: UILabel!
    @IBOutlet weak var distanceValueLbl: UILabel!
    @IBOutlet weak var distanceMinValueLbl: UILabel!
    @IBOutlet weak var distanceMaxValueLbl: UILabel!
    @IBOutlet weak var distanceSlider: TTRangeSlider!
    
    @IBOutlet weak var customAddressBtn: UIButton!
    @IBOutlet weak var myLocationBtn: UIButton!
    @IBOutlet weak var explanationLabel: UILabel!
    
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var saveBtn: TransitionButton!
    @IBOutlet weak var resetFilterBtn: UIButton!
    
    var selectedCategoriesIds = [Int]()
    var filter = FilterModel()
    var categoryArray = [CategoryModel]()

    override func viewDidLoad() {
        filter = DataManager.sharedInstance.wishListFilter.copy() as! FilterModel
        
        super.viewDidLoad()
        
        categoryArray = DataManager.sharedInstance.wishListCategories
        categoryTotalSelected.text = getTotalSelectedText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: Private Methods
    
    override func setupUI(){
        
        self.view.addGradientToBackground()
        
        categoryView.layer.cornerRadius = 10
        
        priceSlider.minValue = Float(CGFloat(DataManager.sharedInstance.info.minPrice))
        priceSlider.maxValue = Float(DataManager.sharedInstance.info.maxPrice)
        priceSlider.selectedMinimum = Float(filter.fromPrice)
        priceSlider.selectedMaximum = Float(filter.toPrice)

        distanceSlider.minValue = 0
        distanceSlider.maxValue = 100000
        distanceSlider.selectedMinimum = Float(filter.fromDistance)
        distanceSlider.selectedMaximum = Float(filter.toDistance)
        
        filter = DataManager.sharedInstance.mainFilter.copy() as! FilterModel
        
        setupSliderUI(slider: distanceSlider)
        setupSliderUI(slider: priceSlider)
        
        customAddressBtn.layer.cornerRadius = 10
        myLocationBtn.layer.cornerRadius = 10
        
        saveBtn.setupForTransitionLayoutTypeBlack()
        
        if filter.isUsingCustomeLocation {
            customAddressBtn.setupTitleForKey(key: "custome_address")
        } else {
            customAddressBtn.setupTitleForKey(key: "select_address")
        }
        checkBtnStates()

    }
    
    func setupSliderUI(slider: MultiSlider){
        
        slider.hasRoundTrackEnds = true
        slider.showsThumbImageShadow = false
        slider.backgroundColor = UIColor.clear
        
        slider.orientation = .horizontal
        slider.trackWidth = 20
        slider.tintColor = .blue
        
        slider.thumbViews.first!.image = UIImage(named: "icSliderLeft")
        slider.thumbViews.last!.image = UIImage(named: "icSliderRight")
    }
    
    func setupSliderUI(slider: TTRangeSlider){
        
        slider.lineHeight = 20
        slider.handleDiameter = 30
        slider.handleColor = .black
        slider.tintColor = .lightGray
        slider.tintColorBetweenHandles = .white
        slider.hideLabels = true
        slider.selectedHandleDiameterMultiplier = 1
        
        slider.handleImage = UIImage(named: "icSliderRight")
    }
    
    override func setupStrings(){
        titleLbl.setupTitleForKey(key: "wish_list", uppercased: true)
        
        categoryLbl.setupTitleForKey(key: "categories", uppercased: true)
        categoryTotalSelected.text = getTotalSelectedText()
        
        priceTitleLbl.setupTitleForKey(key: "price", uppercased: true)
        priceValueLbl.text = "   \(Int(priceSlider!.selectedMinimum)) - \(Int(priceSlider!.selectedMaximum)) \(DataManager.sharedInstance.loggedUser.currency)"
        priceMinValueLbl.text = "\(DataManager.sharedInstance.info.minPrice)"
        priceMaxValueLbl.text = "\(DataManager.sharedInstance.info.maxPrice)"
        
        distanceTitleLbl.setupTitleForKey(key: "distance", uppercased: true)
        distanceValueLbl.text = "   \(Int(distanceSlider.selectedMinimum)) - \(Int(distanceSlider.selectedMaximum)) km"
        distanceMinValueLbl.text = "0 m"
        distanceMaxValueLbl.text = ">100 km"
        
        myLocationBtn.setupTitleForKey(key: "my_location", uppercased: true)
        explanationLabel.setupTitleForKey(key: "wish_list_explanation")
        
        bottomLbl.setupTitleForKey(key: "wish_list_bottom_description")
        saveBtn.setupTitleForKey(key: "save_parameters", uppercased: true)
        resetFilterBtn.setupTitleForKey(key: "reset_filters", uppercased: true)
        updateDistanceLbl()
    }
    
    func getTotalSelectedText() -> String {
        let array = Utils.getSelectedItemsIds(array: categoryArray)
        if array.count > 0 {
            return "\(array.count) " + LanguageManager.sharedInstance.getStringForKey(key: "selected")
        } else {
            return ""
        }
    }
    
    func checkBtnStates() {
        myLocationBtn.backgroundColor = .clear
        customAddressBtn.backgroundColor = .clear
        if filter.isUsingCustomeLocation {
            customAddressBtn.layer.borderWidth = 1.2
            customAddressBtn.layer.borderColor = UIColor.white.cgColor
            customAddressBtn.layer.cornerRadius = 10
            myLocationBtn.layer.borderColor = UIColor.clear.cgColor
        }else{
            myLocationBtn.layer.borderWidth = 1.2
            myLocationBtn.layer.borderColor = UIColor.white.cgColor
            myLocationBtn.layer.cornerRadius = 10
            customAddressBtn.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    //MARK: PWSwitch Actions
    @IBAction func priceSliderValueChanged(_ sender: Any) {
        priceValueLbl.text = "   \(Int(priceSlider!.selectedMinimum)) - \(Int(priceSlider!.selectedMaximum)) \(DataManager.sharedInstance.loggedUser.currency)"
    }
    
    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        updateDistanceLbl()
    }
    
    func updateDistanceLbl(){
        let distanceTo = Int(distanceSlider!.selectedMaximum)
        let distanceFrom = Int(distanceSlider!.selectedMinimum)
        
        var distanceToStr = ""
        var distanceFromStr = ""
        
        if distanceTo > 1000 {
            distanceToStr = "\(Int(distanceTo/1000)) km"
            if distanceTo >= 100000{
                distanceToStr = "100+ km"
            }
        }else{
            distanceToStr = "\(distanceTo) m"
        }
        
        if distanceFrom > 1000{
            distanceFromStr = "\(Int(distanceFrom/1000)) km"
        }else{
            distanceFromStr = "\(distanceFrom) m"
        }
        
        distanceValueLbl.text = "\(distanceFromStr) - \(distanceToStr)"
    }
    
    //MARK: Button Actions
    @IBAction func closeBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryBtnAction(_ sender: Any) {

        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CategoryPreviewViewController") as! CategoryPreviewViewController
        vc.delegate = self
        
        vc.categoryArray = categoryArray
        vc.isSelectingCategory = false
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func selectAddressBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        vc.delegate = self
        vc.isSelectingFilterAddress = true

        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func myLocationAddressBtn(_ sender: Any) {
        customAddressBtn.setupTitleForKey(key: "select_address")
        filter.isUsingCustomeLocation = false
        checkBtnStates()
    }
    
    @IBAction func resetFilterBtnAction(_ sender: Any) {
        priceSlider.minValue = DataManager.sharedInstance.info.minPrice
        priceSlider.maxValue = DataManager.sharedInstance.info.maxPrice
        priceSlider.selectedMaximum = DataManager.sharedInstance.info.maxPrice
        priceSlider.selectedMinimum = DataManager.sharedInstance.info.minPrice

        distanceSlider.minValue = 0
        distanceSlider.maxValue = 100000
        distanceSlider.selectedMinimum = 0
        distanceSlider.selectedMaximum = 100000
        
        customAddressBtn.setupTitleForKey(key: "select_address")
        
        filter.isUsingCustomeLocation = false
        checkBtnStates()
        categoryArray.deselectAllCategories()
        categoryTotalSelected.text = getTotalSelectedText()
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {        
        filter.categoriesIds = selectedCategoriesIds
        
        filter.fromPrice = Double(priceSlider.selectedMinimum)
        filter.toPrice = Double(priceSlider.selectedMaximum)
        
        filter.fromDistance = Double(distanceSlider.selectedMinimum)
        filter.toDistance = Double(distanceSlider.selectedMaximum)
        
        DataManager.sharedInstance.wishListFilter = filter.copy() as! FilterModel
        
        ServerManager.sharedInstance.setWishList()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Category selector delegate
    
    func categorySelectorDidSelectCategory(category: CategoryModel) {
        
    }
    
    func categoriesUpdated(categorieIds: [Int]) {
        selectedCategoriesIds = categorieIds
        if categorieIds.count > 0 {
            categoryTotalSelected.text = "\(categorieIds.count) " + LanguageManager.sharedInstance.getStringForKey(key: "selected")
        } else {
            categoryTotalSelected.text = ""
        }
        print(categorieIds)
    }
    
    func updateCategory(category: CategoryModel) {
    }
    
    //MARK: - AddressSelectionDelegate Delegate
    
    func selectedCoordinate(coordinate: CLLocationCoordinate2D, address: String) {
        customAddressBtn.setTitle(address, for: .normal)
        filter.isUsingCustomeLocation = true
        filter.latitude = coordinate.latitude
        filter.longitude = coordinate.longitude
        checkBtnStates()
    }
}

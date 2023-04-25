//
//  FilterViewController.swift
//  JobDeal
//
//  Created by Priba on 2/20/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import Foundation
import PWSwitch
import MultiSlider
import TransitionButton
import GoogleMaps
import TTRangeSlider

class FilterViewController: BaseViewController, CategorySelectorDelegate, AddressSelectionDelegate {
    
    // MARK: - Outlets
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
    
    @IBOutlet weak var resetFilterBtn: UIButton!
    @IBOutlet weak var saveBtn: TransitionButton!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var helpOnTheWayLabel: UILabel!
    @IBOutlet weak var helpOnTheWaySwitch: PWSwitch!
    
    // MARK: - Private Properties
    private var selectedCategoriesIds = [Int]()
    private var categoryArray = [CategoryModel]()
    private var filter = FilterModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        filter = DataManager.sharedInstance.mainFilter.copy() as! FilterModel
        
        super.viewDidLoad()

        categoryArray = DataManager.sharedInstance.mainFilterCategories
        categoryTotalSelected.text = getTotalSelectedText()
    }

    // MARK: Overridden Methods
    override func setupUI() {
        view.addGradientToBackground()
        
        categoryView.layer.cornerRadius = 10
        
        setupSliderUI(slider: distanceSlider)
        setupSliderUI(slider: priceSlider)
        
        priceSlider.minValue = DataManager.sharedInstance.info.minPrice
        priceSlider.maxValue = DataManager.sharedInstance.info.maxPrice
        priceSlider.selectedMinimum = Float(filter.fromPrice)
        priceSlider.selectedMaximum = Float(filter.toPrice)
        
        distanceSlider.minValue = 0
        distanceSlider.maxValue = 100000
        distanceSlider.selectedMinimum = Float(filter.fromDistance)
        distanceSlider.selectedMaximum = Float(filter.toDistance)

        borderView.layer.cornerRadius = 10
        borderView.layer.borderWidth = 1.2
        borderView.layer.borderColor = UIColor.white.cgColor
        myLocationBtn.layer.cornerRadius = 10
        customAddressBtn.layer.cornerRadius = 10
        myLocationBtn.layer.cornerRadius = 10
        
        saveBtn.setupForTransitionLayoutTypeBlack()
        
        if filter.isUsingCustomeLocation {
            customAddressBtn.setupTitleForKey(key: "custome_address")
        } else {
            customAddressBtn.setupTitleForKey(key: "select_address")
        }
        
        helpOnTheWaySwitch.setOn(filter.helpOnTheWay, animated: false)
    }
    
    override func setupStrings() {
        titleLbl.setupTitleForKey(key: "filter", uppercased: true)

        categoryLbl.setupTitleForKey(key: "categories", uppercased: true)
        categoryTotalSelected.text = getTotalSelectedText()
        
        priceTitleLbl.setupTitleForKey(key: "price", uppercased: true)
        priceValueLbl.text = "   \(Int(priceSlider!.selectedMinimum)) - \(Int(priceSlider!.selectedMaximum)) kr"
        priceMinValueLbl.text = "\(DataManager.sharedInstance.info.minPrice)"
        priceMaxValueLbl.text = "\(DataManager.sharedInstance.info.maxPrice)"
        
        distanceTitleLbl.setupTitleForKey(key: "distance", uppercased: true)
        distanceValueLbl.text = "   \(Int(distanceSlider.selectedMinimum)) - \(Int(distanceSlider.selectedMaximum)) km"
        distanceMinValueLbl.text = "0 m"
        distanceMaxValueLbl.text = ">100 km"
        
        myLocationBtn.setupTitleForKey(key: "my_location", uppercased: true)

        resetFilterBtn.setupTitleForKey(key: "reset_filters", uppercased: true)
        saveBtn.setupTitleForKey(key: "save", uppercased: true)
        updateDistanceLbl()
        
        helpOnTheWayLabel.setupTitleForKey(key: "show_help_on_the_way_jobs")
    }
    
    override func loadData() {
        checkBtnStates()
    }
    
    // MARK: - Helper Methods
    func setupSliderUI(slider: TTRangeSlider) {
        slider.lineHeight = 20
        slider.handleDiameter = 30
        slider.handleColor = .black
        slider.tintColor = .lightGray
        slider.tintColorBetweenHandles = .white
        slider.hideLabels = true
        slider.selectedHandleDiameterMultiplier = 1
        
        slider.handleImage = UIImage(named: "icSliderRight")
    }
    
    private func getTotalSelectedText() -> String {
        let array = Utils.getSelectedItemsIds(array: categoryArray)
        if array.count > 0 {
            return "\(array.count) " + LanguageManager.sharedInstance.getStringForKey(key: "selected")
        } else {
            return ""
        }
    }
    
    private func updateDistanceLbl() {
        let distanceTo = Int(distanceSlider!.selectedMaximum)
        let distanceFrom = Int(distanceSlider!.selectedMinimum)
        
        var distanceToStr = ""
        var distanceFromStr = ""
        
        if distanceTo > 1000 {
            distanceToStr = "\(Int(distanceTo/1000)) km"
            if distanceTo >= 100000{
                distanceToStr = "100+ km"
            }
        } else {
            distanceToStr = "\(distanceTo) m"
        }
        
        if distanceFrom > 1000 {
            distanceFromStr = "\(Int(distanceFrom/1000)) km"
        } else {
            distanceFromStr = "\(distanceFrom) m"
        }
        
        distanceValueLbl.text = "\(distanceFromStr) - \(distanceToStr)"
    }
    
    private func checkBtnStates() {
        myLocationBtn.backgroundColor = .clear
        customAddressBtn.backgroundColor = .clear
        if filter.isUsingCustomeLocation {
            customAddressBtn.layer.borderWidth = 1.2
            customAddressBtn.layer.borderColor = UIColor.white.cgColor
            customAddressBtn.layer.cornerRadius = 10
            myLocationBtn.layer.borderColor = UIColor.clear.cgColor
        } else {
            myLocationBtn.layer.borderWidth = 1.2
            myLocationBtn.layer.borderColor = UIColor.white.cgColor
            myLocationBtn.layer.cornerRadius = 10
            customAddressBtn.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: Actions
    @IBAction func priceSliderValueChanged(_ sender: Any) {
        priceValueLbl.text = "   \(Int(priceSlider!.selectedMinimum)) - \(Int(priceSlider!.selectedMaximum)) \(DataManager.sharedInstance.loggedUser.currency)"
    }
    
    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        updateDistanceLbl()
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        
        dismiss(animated: true) { }
    }
    
    @IBAction func categoryBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CategoryPreviewViewController") as! CategoryPreviewViewController
        vc.delegate = self
        
        vc.categoryArray = categoryArray
        vc.isSelectingCategory = false
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func customeAddressBtnAction(_ sender: Any) {
        let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        vc.delegate = self
        vc.isSelectingFilterAddress = true
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func myLocationAddressBtn(_ sender: Any) {
        customAddressBtn.setupTitleForKey(key: "select_address")
        customAddressBtn.backgroundColor = UIColor.clear
        checkBtnStates()
        filter.isUsingCustomeLocation = false
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
        customAddressBtn.backgroundColor = UIColor.clear
        
        filter.isUsingCustomeLocation = false
        checkBtnStates()
        
        helpOnTheWaySwitch.setOn(false, animated: false)

        categoryArray.deselectAllCategories()
        categoryTotalSelected.text = getTotalSelectedText()
        setupStrings()
        updateDistanceLbl()
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        filter.categoriesIds = selectedCategoriesIds
        
        filter.fromPrice = Double(priceSlider.selectedMinimum)
        filter.toPrice = Double(priceSlider.selectedMaximum)
        
        filter.fromDistance = Double(distanceSlider.selectedMinimum)
        filter.toDistance = Double(distanceSlider.selectedMaximum)
        
        filter.helpOnTheWay = helpOnTheWaySwitch.on
                
        DataManager.sharedInstance.mainFilter = filter.copy() as! FilterModel
        filter.saveMainFilterToUserDefaults()
        
        NotificationCenter.default.post(name: Notification.Name("filterUpdated"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CategorySelectorDelegate
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
        for cat in categoryArray {
            if cat.id == category.id {
                let index = categoryArray.index(where: {$0 === category})
                categoryArray[index ?? 0] = category
                break
            }
        }
    }
    
    // MARK: - AddressSelectionDelegate
    func selectedCoordinate(coordinate: CLLocationCoordinate2D, address: String) {
        customAddressBtn.setTitle(address, for: .normal)
        myLocationBtn.backgroundColor = UIColor.clear
        filter.isUsingCustomeLocation = true
        filter.latitude = coordinate.latitude
        filter.longitude = coordinate.longitude
        checkBtnStates()
    }
}

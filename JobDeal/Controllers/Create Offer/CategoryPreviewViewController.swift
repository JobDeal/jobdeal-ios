//
//  CategoryPreviewViewController.swift
//  JobDeal
//
//  Created by Priba on 2/20/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit
import TransitionButton
import TweeTextField

protocol CategorySelectorDelegate: class {
    func categorySelectorDidSelectCategory(category: CategoryModel)
    func categoriesUpdated(categorieIds: [Int])
    func updateCategory(category: CategoryModel)
}

class CategoryPreviewViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, CategorySelectorDelegate, UITextFieldDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var filterTextField: TweeAttributedTextField!
    @IBOutlet weak var searchIV: UIImageView!
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var saveBtn: TransitionButton!
    @IBOutlet weak var resetCategoryTopConstraint: NSLayoutConstraint!

    var categoryArray = [CategoryModel]()
    var filteredCategories = [CategoryModel]()

    var presentingCategory = CategoryModel()
    var isSelectingCategory = false
    var showingFiltred = false
    
    weak var delegate: CategorySelectorDelegate?
    
    var headerString = LanguageManager.sharedInstance.getStringForKey(key: "categories", uppercased: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetCategoryTopConstraint.constant = isSelectingCategory ? 16 : -60

        if presentingCategory.id == 0 && isSelectingCategory {
            // Single selection
            categoryArray = DataManager.sharedInstance.categoriesArray.clone()
        } else if presentingCategory.id != 0 {
            // Subcategory preview
            categoryArray = presentingCategory.subCategories
        }
        
        for cat in categoryArray {
            cat.checkHalfSelected()
        }
        
        filteredCategories = categoryArray.clone()
        categoryTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.addGradientToBackground()
    }
    
    //MARK: Private Methods
    
    override func setupUI(){
        saveBtn.setupForTransitionLayoutTypeBlack()
        
        filterTextField.layer.cornerRadius = 10
        filterTextField.layer.borderWidth = 1
        filterTextField.setLeftPaddingPoints(16)
        filterTextField.setRightPaddingPoints(42)
        filterTextField.layer.borderColor = UIColor.white.cgColor
        filterTextField.textColor = UIColor.white
        
        filterTextField.attributedPlaceholder = NSAttributedString(string: LanguageManager.sharedInstance.getStringForKey(key: "search"),
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

    }
    override func setupStrings(){
        saveBtn.setupTitleForKey(key: "save", uppercased: true)
        titleLbl.text = headerString
    }
    
    override func loadData() {
        //ViewDidLoad()
    }

    //MARK: Button Actions
    
    @IBAction func saveBtnAction(_ sender: Any) {
        if isSelectingCategory {
            let selectedCategories = getSelectedItem()
            
            if selectedCategories.count > 0 {
                delegate?.categorySelectorDidSelectCategory(category: selectedCategories.first!)
            }
        } else {
            if presentingCategory.id == 0 {
                DataManager.sharedInstance.mainFilterCategories = categoryArray.clone()
                delegate?.categoriesUpdated(categorieIds: Utils.getSelectedItemsIds(array: categoryArray))
            } else {
                presentingCategory.subCategories = categoryArray.clone()
                delegate?.updateCategory(category: presentingCategory)
            }
        }

        dismiss(animated: true, completion: nil)
    }
    
    func getSelectedItem() -> [CategoryModel] {
        
        let selectedItem = categoryArray.filter { (item) -> Bool in
            return item.isSelected == true
        }
        
        return selectedItem
    }
    
    @IBAction func forwardBtnAction(_ sender: UIButton) {
        if sender.tag < filteredCategories.count {
            
            let vc =  UIStoryboard(name: "CreateOffer", bundle: nil).instantiateViewController(withIdentifier: "CategoryPreviewViewController") as! CategoryPreviewViewController
            vc.delegate = isSelectingCategory ? self.delegate : self
            vc.presentingCategory = filteredCategories[sender.tag]
            vc.isSelectingCategory = isSelectingCategory
            
            vc.headerString = headerString + " / " + filteredCategories[sender.tag].title.uppercased()
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetCategoriesBtnAction(_ sender: Any) {
        categoryArray.deselectAllCategories()
        filteredCategories.deselectAllCategories()
        categoryTableView.reloadData()
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {

        if !isSelectingCategory {
            delegate?.updateCategory(category: presentingCategory)
            
            if presentingCategory.id == 0 {
                delegate?.categoriesUpdated(categorieIds: Utils.getSelectedItemsIds(array: categoryArray))
            }
        }
        dismiss(animated: true) {}
    }
    
    //MARK: - Text field Delegate

    @IBAction func searchTextFieldChanged(_ sender: Any) {
        if (filterTextField.text?.count ?? 0 > 0) {
            filterArray()
            showingFiltred = true
        } else {
            showingFiltred = false
            filteredCategories = categoryArray.clone()
            categoryTableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func filterArray() {
        let key = filterTextField.text!
        
        filteredCategories = [CategoryModel]()
        
        for cat in categoryArray {
            
            for subCat in cat.subCategories {
                let filterLayer1 = subCat.subCategories.filter { $0.title.uppercased().contains(key.uppercased())}
                filteredCategories.append(contentsOf: filterLayer1)
            }
            
            let filterLayer2 = cat.subCategories.filter { $0.title.uppercased().contains(key.uppercased())}
            filteredCategories.append(contentsOf: filterLayer2)
        }
        
        let filterLayer3 = categoryArray.filter { $0.title.uppercased().contains(key.uppercased())}
        filteredCategories.append(contentsOf: filterLayer3)
        
        categoryTableView.reloadData()
    }
    
    //MARK: - TableView Data and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < filteredCategories.count {
            let cat = filteredCategories[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
            cell.populate(category: cat)
            cell.forwardBtn.tag = indexPath.row
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < filteredCategories.count {
            
            if isSelectingCategory {
                filteredCategories.deselectAllCategories()
                categoryArray.deselectAllCategories()
                filteredCategories[indexPath.row].isSelected = true
                for cat:CategoryModel in categoryArray {
                    if cat.id == filteredCategories[indexPath.row].id{
                        cat.isSelected = true
                        break;
                    }
                }
                tableView.reloadData()
            } else {
                filteredCategories[indexPath.row].isSelected = !filteredCategories[indexPath.row].isSelected
                
                filteredCategories[indexPath.row].changeSubArrayState()
                
                for cat:CategoryModel in categoryArray {
                    if cat.id == filteredCategories[indexPath.row].id{
                        cat.isSelected = filteredCategories[indexPath.row].isSelected
                        cat.changeSubArrayState()
                        break;
                    }
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //MARK: - Category Delegate
    
    func categorySelectorDidSelectCategory(category: CategoryModel) {
        
    }
    
    func categoriesUpdated(categorieIds: [Int]) {

    }
    
    func updateCategory(category: CategoryModel) {
        
        for cat in categoryArray{
            cat.checkHalfSelected()
        }
        
        for cat in filteredCategories{
            cat.checkHalfSelected()
        }
        
        for cat in categoryArray {
            if cat.id == category.id {
                let index = categoryArray.index(where: {$0.id == category.id})
                categoryArray[index ?? 0] = category

                break
            }
        }
        
        for cat in filteredCategories {
            if cat.id == category.id {
                
                let index = filteredCategories.index(where: {$0 === category})
                filteredCategories[index ?? 0] = category
                
                break
            }
        }
        categoryTableView.reloadData()
    }
}

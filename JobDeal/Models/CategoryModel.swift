//
//  CategoryModel.swift
//  JobDeal
//
//  Created by Priba on 2/18/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation

class CategoryModel: NSCopying, Selectable {
    
    var title: String = ""
    var isSelected: Bool = false {
        didSet{
            self.isHalfSelected = isSelected
            print("Selected: \(title)")
        }
    }
    
    var isHalfSelected = false
    var isUserSelectEnable: Bool = true
    
    var id = 0
    var name = ""
    var color = ""
    var imageUrl = ""
    var desc = ""
    var subCategories = [CategoryModel]()
    
    init(dict: NSDictionary) {
        if let temp = dict["id"] as? Int{
            id = temp
        }
        
        if let temp = dict["name"] as? String{
            name = temp
            title = temp
        }
        
        if let temp = dict["color"] as? String {
            color = temp
        }
        
        if let temp = dict["image"] as? String {
            imageUrl = temp
        }
        
        if let temp = dict["description"] as? String {
            desc = temp
        }
        
        if let temp = dict["subCategory"] as? [NSDictionary] {
            for dict in temp {
                let cat = CategoryModel.init(dict: dict)
                self.subCategories.append(cat)
            }
        }
    }
    
    init() {}
    
    init(title:String,isSelected:Bool,isUserSelectEnable:Bool) {
        self.title = title
        self.isSelected = isSelected
        self.isUserSelectEnable = isUserSelectEnable
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copiedCategoryModel = CategoryModel(title: title, isSelected: isSelected, isUserSelectEnable: isUserSelectEnable)
        copiedCategoryModel.isHalfSelected = self.isHalfSelected
        copiedCategoryModel.name = self.name
        copiedCategoryModel.color = self.color
        copiedCategoryModel.imageUrl = self.imageUrl
        copiedCategoryModel.desc = self.desc
        var copiedSubcategories = [CategoryModel]()
        for subCategory in subCategories {
            copiedSubcategories.append(subCategory.copy() as! CategoryModel)
        }
        copiedCategoryModel.subCategories = copiedSubcategories
        copiedCategoryModel.id = self.id
        
        return copiedCategoryModel
    }
    
    func changeStateInRootCategories(){
        for sub in subCategories {
            sub.isSelected = self.isSelected
            for subSub in sub.subCategories{
                subSub.isSelected = self.isSelected
            }
        }
    }
    
    func checkHalfSelected(){
        
        if subCategories.count > 0{
            
            let tmp = subCategories.filter({$0.isSelected})
            if tmp.count == subCategories.count{
                isSelected = true
                return
            }
            
            for sub in subCategories {
                if sub.isSelected {
                    isSelected = false
                    isHalfSelected = true
                    return
                }
                for subSub in sub.subCategories{
                    if subSub.isSelected {
                        isSelected = false
                        isHalfSelected = true
                        return
                    }
                }
                
            }
            isHalfSelected = false
            isSelected = false
        }
    }
    
    func changeSubArrayState(){
        
        if isSelected{
            subCategories.selectAllCategories()
        }else{
            subCategories.deselectAllCategories()
        }
        
    }
}

extension Array where Element: CategoryModel {
    func selectAllCategories() {
        for element in self {
            element.isSelected = true
            element.subCategories.selectAllCategories()
        }
    }
    
    func deselectAllCategories() {
        for element in self {
            element.isSelected = false
            element.subCategories.deselectAllCategories()
        }
    }
    
    func selectFromFilter(filter: FilterModel) {
        for element in self {
            
            if filter.categoriesIds.contains(element.id) {
                element.isSelected = true
            }
            element.subCategories.selectFromFilter(filter: filter)
        }
    }
}

extension Array where Element: NSCopying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy() as! Element)
        }
        return copiedArray
    }
}

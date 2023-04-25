//
//  DataManager.swift
//  JobDeal
//
//  Created by Priba on 12/7/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import GoogleMaps

class DataManager{
    static let sharedInstance = DataManager()

    var creatingUser = UserModel.init()
    var loggedUser = UserModel.init()
    
    var info = InfoModel()
    
    var mainFilter: FilterModel {
        set {
            newValue.saveMainFilterToUserDefaults()
        } get {
            return FilterModel.loadMainFilterFromUserDefaults()
        }
    }
    
    var wishListFilter: FilterModel {
        set {
            newValue.saveWishListFilterToUserDefaults()
        } get {
            return FilterModel.loadWishListFromUserDefaults()
        }
    }

    var selectedCategory = CategoryModel()
    var categoriesArray = [CategoryModel]()
    var mainFilterCategories = [CategoryModel]()
    var wishListCategories = [CategoryModel]()
    var userLastLocation = CLLocationCoordinate2D()
    var dateOfLastLocationUpdate: Date?
    var prices = PricesModel()
    
    var isUserLoggedIn: Bool {
        get {
            UserDefaults.standard.object(forKey: "authToken") != nil
        }
    }
}

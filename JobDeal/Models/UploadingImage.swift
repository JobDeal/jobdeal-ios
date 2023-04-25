//
//  UploadingImage.swift
//  JobDeal
//
//  Created by Priba on 1/23/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import Foundation
import UIKit

class UploadingImage{
    
    var image = UIImage()
    var fullUrl = ""
    var path = ""
    var isUploading = false
    
    init(image:UIImage) {
        self.image = image
    }
    
    func loadFromDict(dict:NSDictionary){
        if let temp = dict["fullUrl"] as? String{
            fullUrl = temp
        }
        
        if let temp = dict["path"] as? String{
            path = temp
        }
    }
}

//
//  SideMenuNavigationViewController.swift
//  JobDeal
//
//  Created by Priba on 12/26/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuNavigationViewController: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuWidth = self.view.frame.size.width <= 320 ? self.view.frame.size.width-30 : self.view.frame.size.width-70
        self.presentationStyle = .menuSlideIn
    }


}

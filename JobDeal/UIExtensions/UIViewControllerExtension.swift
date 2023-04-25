//
//  UIViewControllerExtension.swift
//  JobDeal
//
//  Created by Darko Batur on 27/01/2021.
//  Copyright © 2021 Priba. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func addToChild(vc: UIViewController, view: UIView) {
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(vc)
        vc.view.frame = view.frame
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    func removeFromChild(vc: UIViewController) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
}

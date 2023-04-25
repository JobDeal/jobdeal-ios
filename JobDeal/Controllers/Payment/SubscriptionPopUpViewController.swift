//
//  SubscriptionPopUpViewController.swift
//  JobDeal
//
//  Created by Priba on 3/28/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class SubscriptionPopUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var largePriceLbl: UILabel!
    @IBOutlet weak var klarnaBtn: UIButton!
    
    // MARK: - Public Properties
    weak var delegate: ChoosePaymentDelegate?
    
    var price: Float = 0.0
    var currency = ""
    var message = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        titleLbl.setupTitleForKey(key: "become_active_doer")
        messageLbl.text = message
        
        holderView.layer.cornerRadius = 10
        
        largePriceLbl.text = "\(Utils.getRoundedPrice(price: price)) " + currency

        klarnaBtn.setHalfCornerRadius()
        klarnaBtn.layer.borderColor = UIColor.lightGray.cgColor
        klarnaBtn.layer.borderWidth = 2
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewControllerAction)))
        self.view.insertSubview(visualEffectView, at: 0)
    }
    
    // MARK: - Actions
    @IBAction func klarnaBntAction(_ sender: Any) {
        delegate?.chosenKlarna()
    }
    
    @objc func dismissViewControllerAction() {
        dismiss(animated: true, completion: nil)
    }
}

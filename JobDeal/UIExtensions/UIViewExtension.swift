//
//  UIViewExtension.swift
//  JobDeal
//
//  Created by Priba on 12/8/18.
//  Copyright © 2018 Priba. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow2() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
    
    func addTransitionAnimationToView() {
        let transition = CATransition()
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        self.window?.layer.add(transition, forKey: kCATransition)
    }

    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addGradientToBackground() {
        let colorTop = UIColor.mainColor1.cgColor
        let colorBottom = UIColor.mainColor2.cgColor
        let gl: CAGradientLayer = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.startPoint = CGPoint(x: 0.0, y: 0.0)
        gl.endPoint = CGPoint(x: 1.0, y: 1.0)
        gl.frame = self.frame
        
        self.layer.insertSublayer(gl, at: 0)
    }
    
    func addBoostGradientToBackground() {
        let colorTop = UIColor.boostColor1.cgColor
        let colorBottom = UIColor.boostColor2.cgColor
        let gl: CAGradientLayer = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.startPoint = CGPoint(x: 0.0, y: 0.0)
        gl.endPoint = CGPoint(x: 1.0, y: 1.0)
        gl.frame = self.frame
        self.layer.insertSublayer(gl, at: 0)
    }
    
    func addMarkerGradientToBackground() {
        let colorTop = UIColor.mainColor1.cgColor
        let colorBottom = UIColor.mainColor2.cgColor
        
        let gl: CAGradientLayer = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.frame = self.frame
        gl.cornerRadius = self.frame.size.height/2
        self.layer.insertSublayer(gl, at: 0)
    }
    
    func setHalfCornerRadius() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func setupDarkLayout() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.separatorColor.cgColor
        self.layer.cornerRadius = 8
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


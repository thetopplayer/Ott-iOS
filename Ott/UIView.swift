//
//  UIView.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

extension UIView {
    
    func addDownShadow() {
        
        addShadow(offset: CGSizeMake(0, 2.0), opacity: 0.2, radius: 3)
    }
    
    
    func addUpShadow() {
        
        addShadow(offset: CGSizeMake(0, -2.0), opacity: 0.2, radius: 3)
    }
    
    
    func addShadow(offset offset: CGSize, opacity: Float, radius: CGFloat) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    
    func addBorder(withColor color: UIColor, width: CGFloat = 0.5) {
        
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = width
        self.layer.masksToBounds = true
    }
    
    
    func addBorder() {
        
        addBorder(withColor: UIColor.darkGrayColor())
    }

    
    func addRoundedBorder(withColor color: UIColor, width: CGFloat = 0.5) {
        
        self.layer.cornerRadius = 4.0
        addBorder(withColor: color, width: width)
    }
    
    
    func addRoundedBorder() {
        
        addRoundedBorder(withColor: UIColor.darkGrayColor())
    }
    
    
    func removeBorder() {
        
        self.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    
    func addGradient(colors: CGColor...) {
        
        self.backgroundColor = UIColor.clearColor()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    
    func image() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        layer.renderInContext(context!)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return snapshotImage;
    }
}

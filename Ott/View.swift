//
//  View.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 2.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2.5
    }
    
    func addBorder(withColor color: UIColor) {
        
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 0.5
    }
    
    func addBorder() {
        
        addBorder(withColor: UIColor.darkGrayColor())
    }

    func addRoundedBorder() {
        
        self.layer.cornerRadius = 4.0
        addBorder()
    }
}

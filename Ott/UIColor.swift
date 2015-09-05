//
//  UIColor.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

extension UIColor {
    
    //MARK: - Colors
    
    static func background() -> UIColor {
        return UIColor(hex: 0xF6D87D)
    }
    
    static func tint() -> UIColor {
        return UIColor(hex: 0x3266CC)
    }
    
    
    //MARK: - Methods
    
    convenience init (hex: Int) {
        
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b =  CGFloat(hex & 0xFF) / 255.0
        
        self.init(red:r, green: g, blue:b, alpha:1.0)
    }
    
    
    class func colorWithHex (hex: Int) -> UIColor {
        
        return UIColor(hex: hex)
    }
    
    
    func isDark () -> Bool {
        
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        getRed(&red, green:&green, blue:&blue, alpha:&alpha);
        red = CGFloat(0.2421 * powf(Float(red), 2));
        green = CGFloat(0.691 * powf(Float(green), 2));
        blue = CGFloat(0.068 * powf(Float(blue), 2));
        
        let intensity = sqrt(red + green + blue) * 255.0;
        return intensity < 130.0;
    }
    

}

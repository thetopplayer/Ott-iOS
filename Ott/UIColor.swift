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
//        return UIColor(hex: 0xFFE082)
//        return UIColor(hex: 0xFFEFB0)
        return UIColor(white: 0.92, alpha: 1.0)
    }
    
    static func separator() -> UIColor {
        return UIColor(white: 0.4, alpha: 0.5)
    }
    
    
    static func tint() -> UIColor {
//        return UIColor(hex: 0x3266CC)
        return aqua()
    }
    
    static func fern() -> UIColor {
        return UIColor(hex: 0x408000)
    }
    
    static func aqua() -> UIColor {
        return UIColor(hex: 0x0080FF)
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

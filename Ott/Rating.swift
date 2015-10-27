//
//  Rating.swift
//  Ott
//
//  Created by Max on 7/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

struct Rating {
    
    static let Unrated = 0
    static let Minimum = 1
    static let Maximum = 10
    
    var value: Int?
    
    // float is between 0 and 1.0
    init(withFloat floatValue: Float?) {
        
        guard let floatValue = floatValue else {
            value = nil
            return
        }
        
        if floatValue == 0.0 {
            value = nil
        }
        else if floatValue > 1.0 {
            value = nil
            assert(false)
        }
        else {
            value = Int(1 + floor(floatValue * 9))
        }
    }
    
    
    init(withValue value: Int?) {
        
        if Rating.withinRange(value) {
            self.value = value
        }
        else {
            self.value = nil
        }
    }
    
    
    private static func withinRange(value: Int?) -> Bool {
        
        if let value = value {
            return (value >= Rating.Minimum) && (value <= Rating.Maximum)
        }
        
        return false
    }
    
    
    func color() -> UIColor {
        
        if let r = value {
            
            var color: UIColor
            if r <= 3 {
                color = UIColor.red()
            }
            else if r <= 7 {
                color = UIColor.green()
            }
            else {
                color = UIColor.gold()
            }
            return color
        }
        return UIColor.lightGrayColor()
    }
    
    
    func text() -> String {
       
        if let value = value {
            return "\(value)"
        }
        return "-"
    }
}

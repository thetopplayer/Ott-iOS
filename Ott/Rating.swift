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
    
    init(withFloat floatValue: Float?) {
        
        if let fv = floatValue {
            
            let tempValue = Int(1 + floor(fv * 9))
            if Rating.withinRange(tempValue) {
                value = tempValue
            }
        }
    }
    
    
    init(withValue value: Int?) {
        
        if Rating.withinRange(value) {
            self.value = value
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
            
            let color = r < 5 ? UIColor.redColor() : UIColor.fern()
            return color
        }
        return UIColor.darkGrayColor()
    }
    
    
    func text() -> String {
        
        if let r = value {
            return "\(r)"
        }
        return "_"
    }
}

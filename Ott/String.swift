//
//  String.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation

extension String {
    
    func containsCharacter(inCharacterSet charSet: NSCharacterSet) -> Bool {
       
        let range = self.rangeOfCharacterFromSet(charSet)
        if range == nil {
            return false
        }
        
        return true
    }
    
    
    var length : Int {
        
        return self.characters.count
    }
    
    
    func stringWithDigits() -> String {
        
        return "".join(self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
    }

}
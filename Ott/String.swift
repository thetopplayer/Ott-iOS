//
//  String.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation


var _unnacceptableHandleCharacters: NSCharacterSet = {
    
    var allowedChars = NSMutableCharacterSet.alphanumericCharacterSet()
    let additionalChars = NSCharacterSet(charactersInString: "_")
    allowedChars.formUnionWithCharacterSet(additionalChars)
    
    return allowedChars.invertedSet
    }()


var _unnacceptableNameCharacters: NSCharacterSet = {
    
    var allowedChars = NSMutableCharacterSet.alphanumericCharacterSet()
    let additionalChars = NSCharacterSet(charactersInString: "_ ") // allow space
    allowedChars.formUnionWithCharacterSet(additionalChars)
    
    return allowedChars.invertedSet
    }()


let _maximumHandleLength = 15
let _maximumUserNameLength = 60


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
    
    
    func stringByRemovingNonDecimalDigits() -> String {
        
        return "".join(self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
    }
    
    
    func isSuitableForHandle() -> Bool {
        
        if length > _maximumHandleLength {
            return false
        }
        
        return containsCharacter(inCharacterSet: _unnacceptableHandleCharacters) == false
    }
    
    
    func isSuitableForUserName() -> Bool {
        
        if length > _maximumUserNameLength {
            return false
        }
        
        return containsCharacter(inCharacterSet: _unnacceptableNameCharacters) == false
    }

}
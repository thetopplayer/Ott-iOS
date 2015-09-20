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
    
    
    func characterAtIndex(index: Int) -> Character? {
        
        if index < self.length {
            
            let idx = startIndex.advancedBy(index)
            return self[idx]
        }
        return nil
    }
    
    
    func substring(startingAt startingAt: Int, length: Int) -> String {
        
        let start = startIndex.advancedBy(startingAt)
        let end = start.advancedBy(length)
        let range = start..<end
        return substringWithRange(range)
    }
    
    
    func substringToEnd(startingAt startingAt: Int) -> String {
        
        let index = startIndex.advancedBy(startingAt)
        return substringFromIndex(index)
    }
    
    
    func stringByRemovingNonDecimalDigits() -> String {
        
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
    }
    
    
    func stringByRemovingCharactersInString(string: String) -> String {
        
        let characterSet = NSCharacterSet(charactersInString: string)
        return self.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
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
    
    
    static func randomOfLength(length: Int) -> String {
        
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789-"
        let possibleIndicies = UInt32(characters.length)
        
        var result = ""
        for _ in 0...(length - 1) {
            let i = Int(arc4random_uniform(possibleIndicies))
            result += String(characters.characterAtIndex(i)!)
        }
        
        return result
    }
}
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
}
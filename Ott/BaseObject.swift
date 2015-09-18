//
//  BaseObject.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/**

Abstract class at root of all data

*/

import UIKit

class DataKeys {
    
    static var CreatedAt: String {
        return "createdAt"
    }
    
    static var UpdatedAt: String {
        return "updatedAt"
    }
    
}


class BaseObject: PFObject {
    
    
    //MARK: - NSObject Protocol
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let otherObject = object as? BaseObject {
            return otherObject.hash == hash
        }
        
        return false
    }
    
    
    override var hash: Int {
        
        if let objectId = objectId {
            return objectId.hash
        }
        
        return super.hash
    }
    
    
    @NSManaged var phoneNumber: String?
}

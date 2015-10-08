//
//  DataObject.swift
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
    
    static var PinName: String {
        return "pinName"
    }
}


class DataObject: PFObject {
    
    
    //MARK: - Attributes
    
    /// used in some cases to keep track of the object's pinName when cached in the local datastore
    @NSManaged var pinName: String?
    
    
    
    //MARK: - NSObject Protocol
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let otherObject = object as? DataObject {
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
}

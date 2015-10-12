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


//MARK: - DataKeys

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



//MARK: - DataObject

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



//MARK: - Utilities

func sortByUpdatedAt(var objects: [DataObject]) {
    
    let sortFn = { (a: AnyObject, b: AnyObject) -> Bool in
        
        let firstTime = (a as! DataObject).updatedAt!
        let secondTime = (b as! DataObject).updatedAt!
        return firstTime.laterDate(secondTime) == firstTime
    }
    
    return objects.sortInPlace(sortFn)
}







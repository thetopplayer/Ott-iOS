//
//  PrivateUserData.swift
//  Ott
//
//  Created by Max on 9/16/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PrivateUserData: DataObject, PFSubclassing {

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    class func parseClassName() -> String {
        return "PrivateUserData"
    }
    

    //MARK: - Attributes
    
    @NSManaged var phoneNumber: String?
}

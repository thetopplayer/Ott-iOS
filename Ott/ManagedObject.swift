//
//  ManagedObject.swift
//  Ott
//
//  Created by Max on 6/26/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func instance(inContext context: NSManagedObjectContext) -> NSManagedObject {
        return context.objectWithID(self.objectID)
    }
}

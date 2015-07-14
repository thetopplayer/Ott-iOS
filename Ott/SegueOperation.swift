//
//  SegueOperation.swift
//  Ott
//
//  Created by Max on 7/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

/**
An `Operation` subclass that performs a segue if certain operationConditions are met.
*/

class SegueOperation: Operation {

    private let presentationController: UIViewController
    private let identifer: String
    
    init(presentationController: UIViewController, identifer: String, conditions: [OperationCondition]?) {
        
        self.presentationController = presentationController
        self.identifer = identifer
        
        super.init()
        
        if let conditions = conditions {
            for c in conditions {
                addCondition(c)
            }
        }
        
        /*
        This operation modifies the view controller hierarchy.
        Doing this while other such operations are executing can lead to
        inconsistencies in UIKit. So, let's make them mutally exclusive.
        */
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    override func execute() {
        
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.presentationController.performSegueWithIdentifier(self.identifer, sender: nil)
            weakSelf!.finish()
        }
    }

}

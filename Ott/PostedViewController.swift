//
//  PostedViewController.swift
//  taq
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PostedViewController: TagListTableViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectionSegueIdentifier = "segueToRatingEntry"
        
        fetchPredicate = NSPredicate(format: "userDidPostRating = true")
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        update()
    }
    
    
    
    //MARK: - NavigatorToTagCreation
    
    @IBAction func presentTagCreationViewController(sender: AnyObject) {
        
        let segueToCreationIdentifier = "segueToTagCreation"
        
        let segueOperation = SegueOperation(presentationController: self, identifer: segueToCreationIdentifier, conditions: [LocationCondition(usage: .WhenInUse)])
        operationQueue.addOperation(segueOperation)
    }
    
    
    @IBAction func presentTagScanViewController(sender: AnyObject) {
        
        let segueToScanIdentifier = "segueToScan"
        
        let segueOperation = SegueOperation(presentationController: self, identifer: segueToScanIdentifier, conditions: [LocationCondition(usage: .WhenInUse)])
        operationQueue.addOperation(segueOperation)
    }
}

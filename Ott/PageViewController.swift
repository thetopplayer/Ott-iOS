//
//  PageViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    var tasksCompleted = false
    
    var preferredSize : CGSize? {
        
        didSet {
            
            if self.parentViewController != nil {
                 if let parent = self.parentViewController as? PageCollectionViewController {
                     parent.pageViewPreferredSizeDidChange(self)
                }
            }
        }
    }
    
    
    // called by PagingViewController when the view becomes visible
    func didShow () {
    }
    
    
    // called by PagingViewController when the view is about to hide
    func willHide () {
    }
    
    
    func enableButton(button: UIButton, value: Bool) {
        
        if value {
            
            button.enabled = true
            button.backgroundColor = UIColor.tint()
        }
        else {
            
            button.enabled = false
            button.backgroundColor = UIColor.background().colorWithAlphaComponent(0.5)
        }
    }
    
    
    func gotoNextPage() {
        
        let parent = self.parentViewController as! PageCollectionViewController
        parent.next(self)
    }
}
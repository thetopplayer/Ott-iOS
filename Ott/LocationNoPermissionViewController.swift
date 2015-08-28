//
//  LocationNoPermissionViewController.swift
//  Ott
//
//  Created by Max on 8/28/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LocationNoPermissionViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var accessButton: UIButton!
    
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background()
        
        containerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        containerView.addRoundedBorder()
        accessButton.tintColor = UIColor.tint()
    }

    
    //MARK: - Actions
    
    @IBAction func getPermissionAction(sender: AnyObject) {
        
        LocationManager.sharedInstance.requestPermission() { granted in }
    }

}

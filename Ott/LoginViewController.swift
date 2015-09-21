//
//  LoginViewController.swift
//  Ott
//
//  Created by Max on 7/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class LoginViewController: PageCollectionViewController {
    
    static var handleUsedToLogin = ""
    static var phoneNumberUsedToLogin = ""
    
    override func viewDidLoad() {
        
        func setupDialogView() {
            
            scrollView.addRoundedBorder()
            
            let vc0 = HandleEntryViewController(nibName: "HandleEntryViewController", bundle: nil)
            let vc1 = PhoneNumberEntryViewController(nibName: "PhoneNumberEntryViewController", bundle: nil)
            let vc2 = ConfirmCodeEntryViewController(nibName: "ConfirmCodeEntryViewController", bundle: nil)
            vc2.successAction = .LogIn
            
            pageViewControllers = [vc0, vc1, vc2]
        }
        
        super.viewDidLoad()
        backButton!.tintColor = UIColor.tint()
        backButton!.setTitleColor(UIColor.tint(), forState: UIControlState.Normal)
        
        setupDialogView()
    }
    
    
    override func handleCompletion() {
        
        presentViewController(mainViewController(), animated: true, completion: nil)
    }
}

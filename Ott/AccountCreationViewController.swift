//
//  AccountCreationViewController.swift
//  Ott
//
//  Created by Max on 4/24/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class AccountCreationViewController: PageCollectionViewController {

    override func viewDidLoad() {
        
        func setupDialogView() {
            
            scrollView.addRoundedBorder()
            
            let vc0 = Intro0ViewController(nibName: "Intro0ViewController", bundle: nil)
            let vc1 = AccountSetupViewController(nibName: "AccountSetupViewController", bundle: nil)
            let vc2 = Intro1ViewController(nibName: "Intro1ViewController", bundle: nil)
            let vc3 = PhoneNumberEntryViewController(nibName: "PhoneNumberEntryViewController", bundle: nil)
            let vc4 = ConfirmCodeEntryViewController(nibName: "ConfirmCodeEntryViewController", bundle: nil)
            pageViewControllers = [vc0, vc1, vc2, vc3, vc4]
        }
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        backButton!.tintColor = UIColor.tint()
        backButton!.setTitleColor(UIColor.tint(), forState: UIControlState.Normal)
        
        setupDialogView()
    }

    
    override func handleCompletion() {
        
        performSegueWithIdentifier("segueToAvatarCreation", sender: self)
    }
}

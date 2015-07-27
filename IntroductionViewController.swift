//
//  IntroductionViewController.swift
//  mailr
//
//  Created by Max on 4/24/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class IntroductionViewController: PageCollectionViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func setupDialogView() {
        
        scrollView.layer.borderColor = UIColor.lightGrayColor().CGColor
        scrollView.layer.borderWidth = 1.0
        scrollView.layer.cornerRadius = 4.0
        
        let vc0 = Intro0ViewController(nibName: "Intro0ViewController", bundle: nil)
        let vc1 = Intro1ViewController(nibName: "Intro1ViewController", bundle: nil)
        let vc2 = Intro2ViewController(nibName: "Intro2ViewController", bundle: nil)
        let vc3 = Intro3ViewController(nibName: "Intro3ViewController", bundle: nil)
        pageViewControllers = [vc0, vc1, vc2, vc3]
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupDialogView()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func handleCompletion() {
        
        func associatedWithExistingAccount(phoneNumber: String) -> Bool {
            
            // query Parse for users with phoneNumber
            
            return false
        }
        
        if associatedWithExistingAccount(currentUser()!.phoneNumber!) {
            
            // present existing account data and login
            
        }
        else {
            
            performSegueWithIdentifier("segueToSetupView", sender: self)
        }
    }
}

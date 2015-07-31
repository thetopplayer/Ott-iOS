//
//  IntroductionViewController.swift
//  mailr
//
//  Created by Max on 4/24/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class IntroductionViewController: PageCollectionViewController {
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    
    func setupDialogView() {
        
        scrollView.layer.borderColor = UIColor.darkGrayColor().CGColor
        scrollView.layer.borderWidth = 0.5
        scrollView.layer.cornerRadius = 4.0
        
        let vc0 = Intro0ViewController(nibName: "Intro0ViewController", bundle: nil)
        let vc1 = Intro1ViewController(nibName: "Intro1ViewController", bundle: nil)
        let vc2 = PhoneNumberEntryViewController(nibName: "PhoneNumberEntryViewController", bundle: nil)
        let vc3 = ConfirmCodeEntryViewController(nibName: "ConfirmCodeEntryViewController", bundle: nil)
        pageViewControllers = [vc0, vc1, vc2, vc3]
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupDialogView()
    }

    
    override func handleCompletion() {
        
        func login(user: AuthorObject) {
            
            let alertViewController = UIAlertController(title: "Welcome Back", message: "Logging in...", preferredStyle: .Alert)
            
            presentViewController(alertViewController, animated: true, completion: nil)
            
            user.loginInBackground() {
                
                (user: PFUser?, error: NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(false, completion: {
                        action in
                        self.presentViewController(mainViewController(), animated: true, completion: nil)
                    })
                }
            }
        }
        
        
        confirmUniquePhoneNumber(phoneNumber: currentUser().phoneNumber!) {
            
            (isUnique: Bool, error: NSError?) -> Void in
            
            if error == nil {
                
                if isUnique {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("segueToSetupView", sender: self)
                    }                    
                }
                else {
                    
                    fetchUserInBackground(phoneNumber: currentUser().phoneNumber!) {
                        
                        (object: PFObject?, error: NSError?) -> Void in
                        
                        var existingUser: AuthorObject?
                        if error == nil {
                            existingUser = (object as? AuthorObject)!
                        }
                        else {
                            print("error fetching existing account information")
                        }
                        
                        if let existingUser = existingUser {
                            login(existingUser)
                        }
                        else {
                            
                            // todo - error alert
                            print("error processing existing account information")
                        }
                    }

                }
            }
            else {
                
                // todo - error alert
                print("error confirming unique phone number")
            }
        }
    }
}

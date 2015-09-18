//
//  ConfirmCodeEntryViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//


import UIKit

class ConfirmCodeEntryViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let validationCodeLength = 4
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
        button.setTitle("Next", forState: UIControlState.Normal)
        button.enabled = false
        startObservations()
    }

    
    deinit {
        
        endObservations()
    }

    
    //MARK: - Display
    
    private func resetDisplay() {
        
        textField.text = ""
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
        button.enabled = false
        activityIndicator.stopAnimating()
    }
    
    
    
    //MARK: - Main
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        textField.becomeFirstResponder()
    }
    
    
    override func willHide() {
        
        super.willHide()
        textField.resignFirstResponder()
        resetDisplay()
    }
    
    
    private func verifyPhoneNumberAndSignIn(phoneNumber phoneNumber: String, verificationCode: String) {
        
        let params: [String: String] = ["phoneNumber": phoneNumber, "verificationCode": verificationCode]
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let error = error {
                    
                    self.presentOKAlertWithError(error, messagePreamble: "Error requesting verification code: ", actionHandler: {
                        
                        self.resetDisplay()
                        self.textField.becomeFirstResponder()
                    })
                    
                }
                else {
                    
                    currentUser().setRandomPassword()
                    currentUser().signUpInBackgroundWithBlock({ (user, error) -> Void in
                        
                        self.button.setTitle("Creating account...", forState: UIControlState.Disabled)
                        
                        if let error = error {

                            self.presentOKAlertWithError(error, messagePreamble: "Error signing up.  Please try again. ", actionHandler: { self.resetDisplay() })
                        }
                        else {
                            
                            self.activityIndicator.stopAnimating()
                            self.tasksCompleted = true
                            (self.parentViewController as! PageCollectionViewController).next(self)
                        }
                    })
                }
            }
        }
        
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        func presentErrorAlert() {
            
            let alertViewController = UIAlertController(title: "Validation Error", message: "The code you entered does not match the one we sent.", preferredStyle: .Alert)
            
            let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { action in print("try again") })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in print("cancel") })
            
            alertViewController.addAction(tryAgainAction)
            alertViewController.addAction(cancelAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        button.enabled = false
        button.setTitle("Validating...", forState: UIControlState.Disabled)
        activityIndicator.startAnimating()
        
        verifyPhoneNumberAndSignIn(phoneNumber: phoneNumberUsedToLogin!, verificationCode: textField.text!)
    }

    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        button.enabled = textField.text!.length == validationCodeLength
    }
    

}

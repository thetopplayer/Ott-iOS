//
//  ConfirmCodeEntryViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//


import UIKit

class ConfirmCodeEntryViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
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

    
    //MARK: - Main
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        textField.becomeFirstResponder()
    }
    
    
    override func willHide() {
        
        super.willHide()
        textField.resignFirstResponder()
        textField.text = ""
        activityIndicator.stopAnimating()
        
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
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
        
        // need to validate number by confirming that the code entered is the same as 
        // that returned by the sms request
        
        if textField.text! == currentUser().phoneNumberValidationCode {
            
            activityIndicator.stopAnimating()
            self.tasksCompleted = true
            let parent = self.parentViewController as! PageCollectionViewController
            parent.next(self)
            
        }
        else {
            
            activityIndicator.stopAnimating()
            presentErrorAlert()
        }
        
    }

    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        button.enabled = textField.text!.length == PhoneNumberEntryViewController.validationCodeLength
    }
    

}

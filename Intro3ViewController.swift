//
//  Intro3ViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit

class Intro3ViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
        button.setTitle("Submit", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Disabled)
        enableButton(button, value: false)
        
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
        activityIndicator.stopAnimating()
        
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        enableButton(button, value: false)
        button.setTitle("Validating....", forState: UIControlState.Disabled)
        activityIndicator.startAnimating()
        
        validateCode { (success, error) -> Void in
            
            if success {
                
                self.tasksCompleted = true
                
                let parent = self.parentViewController as! PageCollectionViewController
                parent.next(self)
            }
        }
    }

    
    func validateCode(completion completion:  (success:  Bool, error: NSError?) -> Void) {
        
        //todo - validate the code
        
        completion(success: true, error: nil)
    }
    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        enableButton(button, value: textField.text!.stringWithDigits().length == 4)
    }
    

}

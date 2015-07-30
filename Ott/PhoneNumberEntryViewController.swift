//
//  PhoneNumberEntryViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class PhoneNumberEntryViewController: PageViewController, UITextFieldDelegate {

    static let validationCodeLength = 5

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        
//        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Disabled)
        button.enabled = false
//        enableButton(button, value: false)
        
        startObservations()
    }

    
    deinit {
        
        endObservations()
    }

    
    //MARK: - Main
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return range.location > 1;
    }
    
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        textField.becomeFirstResponder()
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        textField.resignFirstResponder()
        currentUser().phoneNumber = textField.text
        currentUser().phoneNumberValidationCode = randomNumericCode(length: PhoneNumberEntryViewController.validationCodeLength)
        let message = "Your Ott validation code is: \(currentUser().phoneNumberValidationCode!)"
        SMS.sharedInstance.sendMessage(message: message, phoneNumber: "+19366976430")
        
        tasksCompleted = true
        let parent = parentViewController as! PageCollectionViewController
        parent.next(self)
    }
    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        button.enabled = textField.text!.stringWithDigits().length > 6
    }
}

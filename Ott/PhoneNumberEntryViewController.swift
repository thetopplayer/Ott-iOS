//
//  PhoneNumberEntryViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class PhoneNumberEntryViewController: PageViewController, UITextFieldDelegate {

    static let validationCodeLength = 4

    /*
    let phoneUtil: NBPhoneNumberUtil = {
        
        return NBPhoneNumberUtil()
        }()
    
    
    let phoneNumberFormatter: NBAsYouTypeFormatter = {
        
        return NBAsYouTypeFormatter(regionCode: "US")
        }()
    */
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        textField.text = "+1"
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
    }

    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        func presentErrorAlert(message: String?) {
            
            var fullMessage: String
            if let message = message {
                
                fullMessage = "Error:  \(message)  Please try again."
            }
            else {
                
                fullMessage = "We were unable to send a text message to \(currentUser().phoneNumber!).  Please check the number and try again."
            }
            
            let alertViewController = UIAlertController(title: "Unable to Send Text", message: fullMessage, preferredStyle: .Alert)
            
            let tryAgainAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in })
            
            alertViewController.addAction(tryAgainAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        
        textField.resignFirstResponder()
        currentUser().phoneNumber = textField.text
        currentUser().phoneNumberValidationCode = randomNumericCode(length: PhoneNumberEntryViewController.validationCodeLength)
        let message = "Your Ott validation code is: \(currentUser().phoneNumberValidationCode!)"
        SMS.sharedInstance.sendMessage(message: message, phoneNumber: currentUser().phoneNumber!) {(success: Bool, message: String?) -> Void in
            
            if success == false {
                presentErrorAlert(message)
            }
        }
        
        tasksCompleted = true
        let parent = parentViewController as! PageCollectionViewController
        parent.next(self)
    }
    
    
    //MARK: - Observations and TextField Delegate
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return range.location > 1
    }
    
    
    func isValidPhoneNumber(phoneNumber: String?) -> Bool {
        
        if let phoneNumber = phoneNumber {
            return phoneNumber.stringByRemovingNonDecimalDigits().length == 11
        }
        else {
            return false
        }
    }
    
    
    func E164FormattedPhoneNumber(phoneNumber: String) -> String {
        
        return "+1" + phoneNumber.stringByRemovingNonDecimalDigits()
    }
    
    
    func prettyPhoneNumber(input: String?) -> String? {
        
        if let input = input {
            
            let digits = input.stringByRemovingNonDecimalDigits() as NSString
            var formattedNumber = ""
            switch digits.length {
                
            case 0...1:
                formattedNumber = "+1 "
                
            case 2...4:
                let areaCode = digits.substringWithRange(NSMakeRange(1, digits.length - 1))
                formattedNumber = "+1 \(areaCode)"
                
            case 5...7:
                let areaCode = digits.substringWithRange(NSMakeRange(1, 3))
                let remainder = digits.substringWithRange(NSMakeRange(4, digits.length - 4))
                formattedNumber = "+1 (\(areaCode)) \(remainder)"
                
            default:
                let areaCode = digits.substringWithRange(NSMakeRange(1, 3))
                let prefix = digits.substringWithRange(NSMakeRange(4, 3))
                let remainder = digits.substringWithRange(NSMakeRange(7, digits.length - 7))
                formattedNumber = "+1 (\(areaCode)) \(prefix)-\(remainder)"
            }
            
            return formattedNumber
        }
        else {
            return nil
        }
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        let inputText = textField.text!
        textField.text = prettyPhoneNumber(inputText)
        
        if isValidPhoneNumber(inputText) {
            
            currentUser().phoneNumber = E164FormattedPhoneNumber(inputText)
            button.enabled = true
        }
        else {
            button.enabled = false
        }
    }
}

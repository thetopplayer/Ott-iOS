//
//  PhoneNumberEntryViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//


import UIKit

class PhoneNumberEntryViewController: PageViewController, UITextFieldDelegate {

    
    //MARK: - Lifecycle
    
    private func setupView() {
        
        button.setTitle("Authorize", forState: .Normal)
        button.setTitle("Authorize", forState: .Disabled)
        
        resetTextField()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        setupView()
        startObservations()
    }

    
    
    //MARK: - Display
    
    private func resetTextField() {
        
        textField.text = "+1"
        button.enabled = false
    }
    
    
    
    //MARK: - Data
    
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
    
    
    
    //MARK: - Main
    
    override func didShow() {
        
        super.didShow()
        startObservations()
        tasksCompleted = false
        textField.becomeFirstResponder()
    }
    

    override func willHide() {

        super.willHide()
        endObservations()
        textField.resignFirstResponder()
    }

    
    private func sendVerificationCode(toPhoneNumber phoneNumber: String) {
        
        let formattedNumber = E164FormattedPhoneNumber(phoneNumber)
        AccountCreationViewController.phoneNumberUsedToLogin = formattedNumber
        
        PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber": formattedNumber]) {(response: AnyObject?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    
                    self.presentOKAlertWithError(error, messagePreamble: "Error requesting verification code: ", actionHandler: {
                        
                        self.resetTextField()
                        self.textField.becomeFirstResponder()
                    })
                    
                }
                else {
                    self.tasksCompleted = true
                    self.gotoNextPage()
                }
            }
        }
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        func presentErrorAlert(message: String?) {
            
            var fullMessage: String
            if let message = message {
                
                fullMessage = "Error:  \(message)  Please tryp again."
            }
            else {
                
                fullMessage = "We were unable to send a text message to \(currentUser().phoneNumber!).  Please check the number and try again."
            }
            
            let alertViewController = UIAlertController(title: "Unable to Send Text", message: fullMessage, preferredStyle: .Alert)
            
            let tryAgainAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                self.setupView()
                self.textField.becomeFirstResponder()
            })
            
            alertViewController.addAction(tryAgainAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        button.setTitle("Sending Text...", forState: .Disabled)
        button.enabled = false
        textField.resignFirstResponder()
        
        sendVerificationCode(toPhoneNumber: textField.text!)
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
    
    
    func handleTextFieldDidChange(notification: NSNotification) {
        
        let inputText = textField.text!
        textField.text = prettyPhoneNumber(inputText)
        button.enabled = isValidPhoneNumber(inputText)
    }
}

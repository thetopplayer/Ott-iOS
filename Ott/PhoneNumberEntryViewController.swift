//
//  PhoneNumberEntryViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//


import UIKit

class PhoneNumberEntryViewController: PageViewController, UITextFieldDelegate {

    
    enum VerificationType {
        case Phone, PhoneAndHandle
    }
    
    var verificationType = VerificationType.Phone
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textField.delegate = self
    }

    
    
    //MARK: - Display
    
    private func resetTextField() {
        
        self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
        
        textField.text = "+1"
        collectionController?.enableNextButton(false)
    }
    
    
    override func willShow() {
        
        super.willShow()
        numberIsReadyToValidate = false
        resetTextField()
    }
    
    
    override func didShow() {
        
        super.didShow()
        startObservations()
        textField.becomeFirstResponder()
    }
    
    
    override func willHide() {
        
        super.willHide()
        endObservations()
        textField.resignFirstResponder()
    }
    
    
    
    
    //MARK: - Data
    
    var numberIsReadyToValidate = false
    
    
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
    
    

    
    //MARK: - Main
    
    private func validateHandleIsAssociatedWithPhoneNumber() {
        
        let params = ["phoneNumber": Globals.sharedInstance.phoneNumberUsedToLogin, "handle": Globals.sharedInstance.handleUsedToLogin]
        PFCloud.callFunctionInBackground("verifyMatchingUsernameAndPhoneNumber", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let error = error {
                    
                    self.presentOKAlertWithError(error, messagePreamble: "Error confirming account.", actionHandler: {
                        
                        self.resetTextField()
                        self.textField.becomeFirstResponder()
                    })
                }
                else {
                    
                    if let matchConfirmed = response as? Bool {
                        
                        if matchConfirmed {
                            self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Sending SMS...")
                            self.sendVerificationCode()
                        }
                        else {
                            
                            self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
                            
                            let message = "The handle \(Globals.sharedInstance.handleUsedToLogin) is not associated with the phone number you entered.  Please make sure to enter the correct phone number and try again."
                            self.presentOKAlert(title: "Incorrect Data", message: message, actionHandler: {
                                
                                self.resetTextField()
                                self.textField.becomeFirstResponder()
                            })
                        }
                    }
                    else {
                        
                        self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
                        
                        self.presentOKAlert(title: "Error", message: "Error confirming account.  Please try again", actionHandler: {
                            
                            self.resetTextField()
                            self.textField.becomeFirstResponder()
                        })
                    }
                }
            }
        }
        
    }
    
    
    private func sendVerificationCode() {
        
        collectionController?.enableNextButton(false)
        
        let params = ["phoneNumber": Globals.sharedInstance.phoneNumberUsedToLogin]
        PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let error = error {
                    
                    self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
                    self.presentOKAlertWithError(error, messagePreamble: "Error requesting verification code: ", actionHandler: {
                        
                        self.resetTextField()
                        self.textField.becomeFirstResponder()
                    })
                    
                }
                else {
                    self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Sending Code...")
                    self.collectionController?.presentNextView()
                }
            }
        }
    }
    
    
    override func didTapNextButton() {

        super.didTapNextButton()
    
        textField.resignFirstResponder()
        
        let formattedNumber = E164FormattedPhoneNumber(textField.text!)
        Globals.sharedInstance.phoneNumberUsedToLogin = formattedNumber
        
        if verificationType == .Phone {
            collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Sending Text...")

            sendVerificationCode()
        }
        else {
            collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Verifying Account...")
            validateHandleIsAssociatedWithPhoneNumber()
        }
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
    
    
    func handleTextFieldDidChange(notification: NSNotification) {
        
        let inputText = textField.text!
        textField.text = prettyPhoneNumber(inputText)
        numberIsReadyToValidate = isValidPhoneNumber(inputText)
        collectionController?.enableNextButton(numberIsReadyToValidate)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if numberIsReadyToValidate {
            sendVerificationCode()
        }
        
        return numberIsReadyToValidate
    }
}

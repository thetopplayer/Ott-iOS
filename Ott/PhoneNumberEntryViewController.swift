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
    var phoneNumberEntered: String?
    let phoneUtil: NBPhoneNumberUtil = {
        
        return NBPhoneNumberUtil()
        }()
    
    
    let phoneNumberFormatter: NBAsYouTypeFormatter = {
        
        return NBAsYouTypeFormatter(regionCode: "US")
        }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        textField.text = "+1"
        button.enabled = false
        
        phoneNumberEntered = ""
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
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        textField.resignFirstResponder()
        currentUser().phoneNumber = textField.text
        currentUser().phoneNumberValidationCode = randomNumericCode(length: PhoneNumberEntryViewController.validationCodeLength)
        let message = "Your Ott validation code is: \"\(currentUser().phoneNumberValidationCode!)\""
        SMS.sharedInstance.sendMessage(message: message, phoneNumber: "+19366976430")
        
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
        
        phoneNumberEntered = string
        print(phoneNumberEntered)
        return range.location > 1
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        let inputText = textField.text!
        
        let formattedNumber = phoneNumberFormatter.inputString(inputText)
        textField.text = formattedNumber
        
        do {
            
            let nbNumber = try phoneUtil.parse(inputText, defaultRegion: "US")
            if phoneUtil.isValidNumber(nbNumber) {
                
                do {
                    let formattedNumber = try phoneUtil.format(nbNumber, numberFormat: NBEPhoneNumberFormatE164)
                    currentUser().phoneNumber = formattedNumber
                    button.enabled = true
                }
                catch {
                    print("error formatting number")
                }
            }
            else {
                button.enabled = false
            }
        }
        catch {
            
            print("error parsing number")
        }
    }
}

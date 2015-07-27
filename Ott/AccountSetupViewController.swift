//
//  AccountSetupViewController.swift
//  Ott
//
//  Created by Max on 7/27/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class AccountSetupViewController: ViewController, UITextFieldDelegate {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var handleExistsLabel: UILabel!
    @IBOutlet weak var nameTooShortLabel: UILabel!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
  
    private var handleIsUnique = false
    let minimumHandleLength = 3
    let minimumUserNameLength = 3
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        
        topLabel.text = "Setup your account with a unique handle and a user name."
        
        startObservations()
        handleTextField.becomeFirstResponder()
    }

    
    deinit {
        
        endObservations()
    }
    
    
    //MARK: - Actions
    
    @IBAction func doneAction(sender: AnyObject) {
        
        currentUser().username = handleTextField.text
        currentUser().password = currentUser().phoneNumber
        
        currentUser().signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            
            if error != nil {
                
                self.presentViewController(mainViewController(), animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    //MARK: - Observations and TextField Delegate
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: handleTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == handleTextField {
            
            if string.containsCharacter(inCharacterSet: NSCharacterSet.newlineCharacterSet()) {
                nameTextField.becomeFirstResponder()
                return false
            }
            
            if string.containsCharacter(inCharacterSet: NSCharacterSet.whitespaceCharacterSet()) {
                return false
            }
            
            return true
        }
        
        return true
    }
    

    func handleTextFieldDidChange(notification: NSNotification) {
        
        func textFieldsFilled() -> Bool {
            
            return (nameTextField.text!.length >= minimumUserNameLength) && (handleTextField.text!.length >= minimumHandleLength)
        }
        
        
        func confirmUniqueHandle() {
            
            handleIsUnique = false
            
            // query parse
            
            // if unique
            handleIsUnique = true
            handleExistsLabel.hidden = handleIsUnique
        }
        
        if (notification.object as! UITextField) == handleTextField {
            
            if handleTextField.text!.length >= minimumHandleLength {
                confirmUniqueHandle()
            }
        }
        
        doneButton.enabled = textFieldsFilled() && handleIsUnique
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == handleTextField {
            nameTextField.becomeFirstResponder()
        }
    }
}

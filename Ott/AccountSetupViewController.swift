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
    let handleTextFieldTag = 12333
    let nameTextFieldTag = 8823
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        
        startObservations()
        handleTextField.becomeFirstResponder()
    }

    
    deinit {
        
        endObservations()
    }
    
    
    //MARK: - Actions
    
    @IBAction func doneAction(sender: AnyObject) {
        
        if let user = currentUser() {
            
            user.username = handleTextField.text
            user.password = currentUser()!.phoneNumber
            
            user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
                
                if error != nil {
                    
                    self.presentViewController(mainViewController(), animated: true, completion: nil)
                }
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
        
        if let tf = notification.object as? UITextField {
            
            if tf.tag == handleTextFieldTag {
                if handleTextField.text!.length >= minimumHandleLength {
                    confirmUniqueHandle()
                }
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

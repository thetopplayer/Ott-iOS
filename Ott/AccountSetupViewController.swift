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
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleExistsLabel: UILabel!
    @IBOutlet weak var handleEntryStatusImageView: UIImageView!
    @IBOutlet weak var nameEntryStatusImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var createAccountActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var validatingHandleActivityIndicator: UIActivityIndicatorView!
  
    private var handleIsUnique = false
    let minimumHandleLength = 4
    let minimumUserNameLength = 4
    
    private let okImage = UIImage(named: "tick")
    private let errImage = UIImage(named: "multiply")
    
    private func indicateHandleOK(ok: Bool) {
        
        if ok {
            self.handleEntryStatusImageView.tintColor = UIColor.fern()
            self.handleEntryStatusImageView.image = self.okImage
        }
        else {
            handleEntryStatusImageView.tintColor = UIColor.redColor()
            handleEntryStatusImageView.image = errImage
        }
    }
    
    
    private func indicateNameOK(ok: Bool) {
        
        if ok {
            self.nameEntryStatusImageView.tintColor = UIColor.fern()
            self.nameEntryStatusImageView.image = self.okImage
        }
        else {
            nameEntryStatusImageView.tintColor = UIColor.redColor()
            nameEntryStatusImageView.image = errImage
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        
        topLabel.text = "Setup your account with a unique handle and a user name."
        handleTextField.text = "@"
        doneButton.setTitle("Sign Up", forState: .Normal)
        doneButton.setTitle("Sign Up", forState: .Disabled)

        indicateHandleOK(false)
        indicateNameOK(false)
        
        handleExistsLabel.hidden = true
        
        handleTextField.becomeFirstResponder()
        startObservations()
    }

    
    deinit {
        
        endObservations()
    }
    
    
    //MARK: - Actions
    
    @IBAction func doneAction(sender: AnyObject) {
        
        currentUser().name = nameTextField.text
        currentUser().username = handleTextField.text
        
        doneButton.setTitle("Creating Account...", forState: .Disabled)
        doneButton.enabled = false
        createAccountActivityIndicator.startAnimating()
        
        currentUser().signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            
            self.createAccountActivityIndicator.stopAnimating()
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(mainViewController(), animated: true, completion: nil)
                }
            }
            else {
                // todo handle error
                print("error signin up: \(error)")
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
            
            // @ sign
            if range.location == 0 {
                return false
            }
            
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
        
        func handleIsLongEnough() -> Bool {
            return handleTextField.text!.length >= minimumHandleLength
         }
        
        
        func nameIsLongEnough() -> Bool {
            return nameTextField.text!.length >= minimumUserNameLength
        }
        
        func confirmUniqueHandle() {
            
            handleIsUnique = false
            
            // query parse
            handleEntryStatusImageView.hidden = true
            validatingHandleActivityIndicator.startAnimating()
            confirmUniqueUserHandle(handle: handleTextField.text!) {
                
                (isUnique: Bool, error: NSError?) -> Void in
                
                if error == nil {
                    
                    self.handleIsUnique = isUnique
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.handleExistsLabel.hidden = self.handleIsUnique
                        self.validatingHandleActivityIndicator.stopAnimating()
                       
                        self.indicateHandleOK(self.handleIsUnique)
                        self.handleEntryStatusImageView.hidden = false
                    }
                }
                else {
                    print("error confirming unique user handle")
                }
            }
        }
        
        
        if (notification.object as! UITextField) == handleTextField {
            
            if handleIsLongEnough() {
                confirmUniqueHandle()
            }
            else {
                indicateHandleOK(false)
                handleExistsLabel.hidden = true
            }
        }
        
        indicateNameOK(nameIsLongEnough())
        doneButton.enabled = handleIsLongEnough() && nameIsLongEnough() && handleIsUnique
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == handleTextField {
            nameTextField.becomeFirstResponder()
        }
    }
}

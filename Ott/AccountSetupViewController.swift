//
//  AccountSetupViewController.swift
//  Ott
//
//  Created by Max on 7/27/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class AccountSetupViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleExistsLabel: UILabel!
    @IBOutlet weak var handleEntryStatusImageView: UIImageView!
    @IBOutlet weak var nameEntryStatusImageView: UIImageView!
    @IBOutlet weak var validatingHandleActivityIndicator: UIActivityIndicatorView!
  
    private func indicateHandleOK(ok: Bool) {
        handleEntryStatusImageView.indicateOK(ok)
    }
    
    
    private func indicateNameOK(ok: Bool) {
        nameEntryStatusImageView.indicateOK(ok)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        
        topLabel.text = "Enter a handle and your name.  Both can be changed later in the app settings."
        handleTextField.text = "@"
        button.setTitle("Next", forState: .Normal)
        button.setTitle("Next", forState: .Disabled)
        
        // need to start off with nil to get the tint to behave correctly when the images are set
        handleEntryStatusImageView.image = nil
        nameEntryStatusImageView.image = nil
        
        handleExistsLabel.hidden = true
        button.enabled = false
    }

    
    deinit {
        
        endObservations()
    }
    
    
    //MARK: - Main
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        
        handleTextField.becomeFirstResponder()
        startObservations()
    }
    
    
    override func willHide() {
        
        super.willHide()
        endObservations()
    }

    
    //MARK: - Actions
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        currentUser().name = nameTextField.text
        currentUser().handle = handleTextField.text
        
        let parent = self.parentViewController as! PageCollectionViewController
        parent.next(self)
        
        /*
        doneButton.setTitle("Creating Account...", forState: .Disabled)
        doneButton.enabled = false
        createAccountActivityIndicator.startAnimating()
        
        currentUser().signUpInBackgroundWithBlock { (succeeded, error) in
            
            self.createAccountActivityIndicator.stopAnimating()
            
            if error == nil {
                
                setUserSignedUp(true)
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.performSegueWithIdentifier("segueToAvatarCreation", sender: self)
                }
            }
            else {
                
                setUserSignedUp(false)
                
               // todo handle error
                print("error signing up: \(error)")
            }
        }
        */
        
    }
    
    
    //MARK: - Data
    
    private var okToContinue: Bool = false {
        
        didSet {
            button.enabled = okToContinue
            tasksCompleted = okToContinue
        }
    }
    
    
    private var handleIsUnique = false {
        
        didSet {
            indicateHandleOK(handleIsUnique)
            okToContinue = handleIsUnique && nameIsValid
        }
    }
    
    private var nameIsValid = false {
        
        didSet {
            indicateNameOK(nameIsValid)
            okToContinue = handleIsUnique && nameIsValid
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
            
            return string.isSuitableForHandle()
        }
        else if textField == nameTextField {
            
            return string.isSuitableForUserName()
        }
        
        
        return true
    }
    

    func handleTextFieldDidChange(notification: NSNotification) {
        
        func handleIsLongEnough() -> Bool {
            return handleTextField.text!.length >= User.minimumHandleLength
         }
        
        
        func nameIsLongEnough() -> Bool {
            return nameTextField.text!.length >= User.minimumUserNameLength
        }
        
        func confirmUniqueHandle(handle: String) {
            
            func handleFetchCompletion(user: User?, error: NSError?) {
                
                handleIsUnique = user == nil
                handleExistsLabel.hidden = handleIsUnique
                validatingHandleActivityIndicator.stopAnimating()
                handleEntryStatusImageView.hidden = false
                
                if let error = error {
                    presentOKAlertWithError(error, messagePreamble: "Error validating handle: ")
                }
           }
            
            handleIsUnique = false
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, completion: handleFetchCompletion)
            FetchQueue.sharedInstance.addOperation(fetchUserOperation)
        }
        
        
        if (notification.object as! UITextField) == handleTextField {
            
            if handleIsLongEnough() {
                confirmUniqueHandle(handleTextField.text!)
            }
            else {
                indicateHandleOK(false)
                handleExistsLabel.hidden = true
            }
        }
        else if (notification.object as! UITextField) == nameTextField {
            nameIsValid = nameIsLongEnough()
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == handleTextField {
            nameTextField.becomeFirstResponder()
        }
    }
}

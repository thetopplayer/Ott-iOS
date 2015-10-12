//
//  SettingsViewController.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


// note that a lot of this is copied from AccountSetupViewController


class SettingsViewController: TableViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleExistsLabel: UILabel!
    @IBOutlet weak var handleEntryStatusImageView: UIImageView!
    @IBOutlet weak var nameEntryStatusImageView: UIImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var validatingHandleActivityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.background()
        
        bioTextView.backgroundColor = UIColor.clearColor()
        bioTextView.addRoundedBorder()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        bioTextView.delegate = self
        saveButton.enabled = false
        
        nameTextField.text = currentUser().name
        handleTextField.text = currentUser().handle
        bioTextView.text = currentUser().bio
        
        // need to start off with nil to get the tint to behave correctly when the images are set
        handleEntryStatusImageView.image = nil
        nameEntryStatusImageView.image = nil

        handleExistsLabel.hidden = true
        isDirty = false
        startObservations()
    }

    
    deinit {
        
        endObservations()
    }
    
    
    
    //MARK: - Display

    var saveButton: UIBarButtonItem {
        return navigationItem.rightBarButtonItem!
    }
    
    
    private func indicateHandleOK(ok: Bool) {
        handleEntryStatusImageView.indicateOK(ok)
    }
    
    
    private func indicateNameOK(ok: Bool) {
        nameEntryStatusImageView.indicateOK(ok)
    }
    
    
    
    //MARK: - Data

    private var isDirty: Bool = false {
        
        didSet {
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    
    private var handleIsUnique = true {
        
        didSet {
            indicateHandleOK(handleIsUnique)
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    private var nameIsValid = true {
        
        didSet {
            indicateNameOK(nameIsValid)
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }

    
    private func saveChanges() {
        
        guard handleIsUnique && nameIsValid else {
            return
        }
        
        currentUser().name = nameTextField.text
        currentUser().handle = handleTextField.text
        currentUser().bio = bioTextView.text
        
        MaintenanceQueue.sharedInstance.addOperation(UpdateUserOperation(completion: nil))
    }
    
    
    
    //MARK: - Actions

    @IBAction func handleSaveAction(sender: AnyObject) {
        
        saveChanges()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func logout() {

        let alertViewController: UIAlertController = {
            
            let controller = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in
                MaintenanceQueue.sharedInstance.addOperation(LogoutOperation())
                self.presentViewController(introViewController(), animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            
            return controller
        }()
        
        presentViewController(alertViewController, animated: true, completion: {
            
        })
    }
    
    
    
    //MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
        
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        logout()
    }
    
    
    //MARK: - Observations and Delegate Methods
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: handleTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, caseInsensitive: true) {
                
                (fetchResults, error) in
                
                var handleIsUnique = true
                if let _ = fetchResults?.first {
                    handleIsUnique = false
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                
                    self.handleExistsLabel.hidden = handleIsUnique
                    self.validatingHandleActivityIndicator.stopAnimating()
                    self.handleEntryStatusImageView.hidden = false
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error validating handle: ")
                    }
                }
            }
            
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
    
    
    func textViewDidChange(textView: UITextView) {
        
        isDirty = true
    }

}

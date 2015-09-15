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
    
    
    private let okImage = UIImage(named: "tick")
    private let errImage = UIImage(named: "multiply")
    
    private func indicateHandleOK(ok: Bool) {
        
        handleEntryStatusImageView.hidden = false
        
        if ok {
            handleEntryStatusImageView.tintColor = UIColor.tint()
            handleEntryStatusImageView.image = self.okImage
        }
        else {
            handleEntryStatusImageView.tintColor = UIColor.redColor()
            handleEntryStatusImageView.image = errImage
        }
    }
    
    
    private func indicateNameOK(ok: Bool) {
        
        nameEntryStatusImageView.hidden = false
        
        if ok {
            nameEntryStatusImageView.tintColor = UIColor.tint()
            nameEntryStatusImageView.image = self.okImage
        }
        else {
            nameEntryStatusImageView.tintColor = UIColor.redColor()
            nameEntryStatusImageView.image = errImage
        }
    }
    
    
    
    //MARK: - Data

    private var isDirty: Bool = false {
        
        didSet {
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    
    private var handleIsUnique = true {
        
        didSet {
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    private var nameIsValid = true {
        
        didSet {
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
        
        let updateOperation = UpdateUserOperation(user: currentUser())
        MaintenanceQueue.sharedInstance.addOperation(updateOperation)
    }
    
    
    
    //MARK: - Actions

    @IBAction func handleSaveAction(sender: AnyObject) {
        
        saveChanges()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
        
    
    
    //MARK: - Observations and Delegate Methods
    
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
        saveButton.enabled = handleIsLongEnough() && nameIsLongEnough() && handleIsUnique
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

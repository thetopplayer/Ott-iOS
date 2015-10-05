//
//  HandleEntryViewController.swift
//  Ott
//
//  Created by Max on 9/21/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class HandleEntryViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var validatingHandleActivityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        label.text = "Enter your handle to log in."
        resetDisplay()
    }
    
    
    private func resetDisplay() {
        
        textField.text = "@"
        textField.enabled = true
        textField.becomeFirstResponder()
        
        button.setTitle("Next", forState: .Normal)
        button.setTitle("Next", forState: .Disabled)
        button.enabled = false
    }
    

    //MARK: - Main
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        
        resetDisplay()
        startObservations()
    }
    
    
    override func willHide() {
        
        super.willHide()
        endObservations()
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        func confirmHandleExists(handle: String) {
            
            func handleFetchCompletion(user: User?, error: NSError?) {
                
            }
            
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, caseInsensitive: false) {
               
                (fetchResults, error) in
                
                self.validatingHandleActivityIndicator.stopAnimating()
                
                if let error = error {
                    self.presentOKAlertWithError(error, messagePreamble: "Error fetching data from server.", actionHandler: { self.resetDisplay() })
                }
                else {
                    
                    if let _ = fetchResults?.first as? User {
                        
                        self.tasksCompleted = true
                        self.gotoNextPage()
                    }
                    else {
                        
                        let message = "No user could be found with the handle \(Globals.sharedInstance.handleUsedToLogin)."
                        self.presentOKAlert(title: "No Such User", message: message, actionHandler: { () -> Void in
                            self.resetDisplay()
                        })
                    }
                }
            }
            
            FetchQueue.sharedInstance.addOperation(fetchUserOperation)
        }
        
        textField.resignFirstResponder()
        textField.enabled = false
        button.setTitle("Fetching data...", forState: .Disabled)
        validatingHandleActivityIndicator.startAnimating()
        
        Globals.sharedInstance.handleUsedToLogin = textField.text!
        confirmHandleExists(Globals.sharedInstance.handleUsedToLogin)
    }
    
    
    
    //MARK: - Observations and TextField Delegate
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func textFieldDidChange(notification: NSNotification) {
        
        button.enabled = textField.text!.length >= User.minimumHandleLength
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // @ sign
        if range.location == 0 {
            return false
        }
        
        return true
    }
}

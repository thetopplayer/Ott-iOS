//
//  ConfirmCodeEntryViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//


import UIKit

class ConfirmCodeEntryViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    enum SuccessAction {
        case SignUp, LogIn
    }
    var successAction: SuccessAction = .SignUp
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
        button.setTitle("Next", forState: UIControlState.Normal)
        button.enabled = false
    }

    
    
    //MARK: - Display
    
    private func resetDisplay() {
        
        textField.text = ""
        button.setTitle("Enter Code", forState: UIControlState.Disabled)
        button.enabled = false
        activityIndicator.stopAnimating()
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
        resetDisplay()
    }
    
    
    private func signUpWithPassword(password: String) {
        
        self.button.setTitle("Creating account...", forState: UIControlState.Disabled)
        
        let signupOperation = SignUpOperation(phoneNumber: globals.phoneNumberUsedToLogin, handle: globals.handleUsedToLogin, nickname: globals.nameUsedToLogin, password: password)
        MaintenanceQueue.sharedInstance.addOperation(signupOperation)
    }
    
    
    private func loginWithPassword(password: String) {
        
        self.button.setTitle("Logging in...", forState: UIControlState.Disabled)
        
        let logInOperation = LogInOperation(handle: globals.handleUsedToLogin, password: password)
        MaintenanceQueue.sharedInstance.addOperation(logInOperation)
    }
    
    
    private func verifyPhoneNumber(verificationCode: String) {
        
        let params: [String: String] = ["phoneNumber": globals.phoneNumberUsedToLogin, "verificationCode": verificationCode]
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let error = error {
                    
                    self.presentOKAlertWithError(error, messagePreamble: "Error requesting verification code: ", actionHandler: {
                        
                        self.resetDisplay()
                        self.textField.becomeFirstResponder()
                    })
                }
                else {
                    
                    if let password = response as? String {
                        
                        switch self.successAction {
                            
                        case .SignUp:
                            self.signUpWithPassword(password)
                            
                        case .LogIn:
                            self.loginWithPassword(password)
                        }
                    }
                    else {
                        
                        self.presentOKAlert(title: "Error", message: "There was an error signing in.  Please try again", actionHandler: {
                            
                            self.resetDisplay()
                            self.textField.becomeFirstResponder()
                        })
                    }
                    
                }
            }
        }
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        func presentErrorAlert() {
            
            let alertViewController = UIAlertController(title: "Validation Error", message: "The code you entered does not match the one we sent.", preferredStyle: .Alert)
            
            let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { action in print("try again") })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in print("cancel") })
            
            alertViewController.addAction(tryAgainAction)
            alertViewController.addAction(cancelAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        button.enabled = false
        button.setTitle("Validating...", forState: UIControlState.Disabled)
        activityIndicator.startAnimating()
        
        verifyPhoneNumber(textField.text!)
    }

    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidSignUpNotification:", name: SignUpOperation.Notifications.DidSignUp, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSignUpDidFailNotification:", name: SignUpOperation.Notifications.SignUpDidFail, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidLogInNotification:", name: LogInOperation.Notifications.DidLogIn, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLoginDidFailNotification:", name: LogInOperation.Notifications.LogInDidFail, object: nil)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange(notification: NSNotification) {
        
        button.enabled = textField.text!.length > 0
    }

    
    func handleDidSignUpNotification(notification: NSNotification) {
        
        self.activityIndicator.stopAnimating()
        self.tasksCompleted = true
        gotoNextPage()
    }
    
    
    func handleSignUpDidFailNotification(notification: NSNotification) {
        
        let userinfo: [NSObject: AnyObject] = notification.userInfo!
        let error = userinfo[SignUpOperation.Notifications.ErrorKey] as! NSError
        
        presentOKAlertWithError(error, messagePreamble: "Error signing up.  Please try again. ", actionHandler: { self.resetDisplay() })
    }
    
    
    func handleDidLogInNotification(notification: NSNotification) {
        
        self.activityIndicator.stopAnimating()
        self.tasksCompleted = true
        gotoNextPage()
    }
    
    
    func handleLoginDidFailNotification(notification: NSNotification) {
        
        let userinfo: [NSObject: AnyObject] = notification.userInfo!
        let error = userinfo[LogInOperation.Notifications.ErrorKey] as! NSError
        
        presentOKAlertWithError(error, messagePreamble: "Error logging in.  Please try again. ", actionHandler: { self.resetDisplay() })
    }
}

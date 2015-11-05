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
    }

    
    
    //MARK: - Display
    
    private func resetDisplay() {
        
        self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)

        textField.text = ""
        textField.placeholder = "Enter Code"
        textField.enabled = true
        textField.becomeFirstResponder()
        activityIndicator.stopAnimating()
    }
    
    
    
    //MARK: - Main
    
    override func willShow() {
        
        super.willShow()
        resetDisplay()
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
    
    
    override func didTapNextButton() {
        
        collectionController?.enableNextButton(false)
        verifyPhoneNumber(textField.text!)
    }
    
    
    private func signUpWithPassword(password: String) {
        
        print("phone = \(Globals.sharedInstance.phoneNumberUsedToLogin)")
        print("handle = \(Globals.sharedInstance.handleUsedToLogin)")
        print("name = \(Globals.sharedInstance.nameUsedToLogin)")
        print("password = \(password)")
        
        
        let signupOperation = SignUpOperation(phoneNumber: Globals.sharedInstance.phoneNumberUsedToLogin, handle: Globals.sharedInstance.handleUsedToLogin, nickname: Globals.sharedInstance.nameUsedToLogin, password: password)
        MaintenanceQueue.sharedInstance.addOperation(signupOperation)
    }
    
    
    private func loginWithPassword(password: String) {
        
        let logInOperation = LogInOperation(handle: Globals.sharedInstance.handleUsedToLogin, password: password)
        MaintenanceQueue.sharedInstance.addOperation(logInOperation)
    }
    
    
    private func verifyPhoneNumber(verificationCode: String) {
        
        self.collectionController?.enableNextButton(false)
        
        let params: [String: String] = ["phoneNumber": Globals.sharedInstance.phoneNumberUsedToLogin, "verificationCode": verificationCode]
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
                            self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Creating Account...")
                            self.signUpWithPassword(password)
                            
                        case .LogIn:
                            self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Logging In...")
                            self.loginWithPassword(password)
                        }
                    }
                    else {
                        
                        self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
                        self.presentOKAlert(title: "Error", message: "There was an error signing in.  Please try again", actionHandler: {
                            
                            self.resetDisplay()
                            self.textField.becomeFirstResponder()
                        })
                    }
                    
                }
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard textField.text!.length > 0 else {
            return false
        }
        
        activityIndicator.startAnimating()
        verifyPhoneNumber(textField.text!)
        return true
    }
    
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        
//        func presentErrorAlert() {
//            
//            let alertViewController = UIAlertController(title: "Validation Error", message: "The code you entered does not match the one we sent.", preferredStyle: .Alert)
//            
//            let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { action in print("try again") })
//            
//            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in print("cancel") })
//            
//            alertViewController.addAction(tryAgainAction)
//            alertViewController.addAction(cancelAction)
//            
//            presentViewController(alertViewController, animated: true, completion: nil)
//        }
//        
//    }

    
    
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
        
        collectionController?.enableNextButton(textField.text!.length > 0)
    }

    
    func handleDidSignUpNotification(notification: NSNotification) {
        
        collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
        self.activityIndicator.stopAnimating()
        collectionController?.presentNextView()
    }
    
    
    func handleSignUpDidFailNotification(notification: NSNotification) {
        
        collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
        let userinfo: [NSObject: AnyObject] = notification.userInfo!
        let error = userinfo[SignUpOperation.Notifications.ErrorKey] as! NSError
        
        presentOKAlertWithError(error, messagePreamble: "Error signing up.  Please try again. ", actionHandler: { self.resetDisplay() })
    }
    
    
    func handleDidLogInNotification(notification: NSNotification) {
        
        collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
        self.activityIndicator.stopAnimating()
        collectionController?.presentNextView()
    }
    
    
    func handleLoginDidFailNotification(notification: NSNotification) {
        
        collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
        let userinfo: [NSObject: AnyObject] = notification.userInfo!
        let error = userinfo[LogInOperation.Notifications.ErrorKey] as! NSError
        
        presentOKAlertWithError(error, messagePreamble: "Error logging in.  Please try again. ", actionHandler: { self.resetDisplay() })
    }
}

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
    @IBOutlet weak var handleEntryStatusImageView: UIImageView?
    @IBOutlet weak var handleExistsLabel: UILabel?

    
    var usedForHandleCreation = true
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textField.delegate = self
        handleEntryStatusImageView?.image = nil  // need to start off with nil to get the tint to behave correctly when the images are set
    }
    
    
    private func resetDisplay() {
        
        textField.text = "@"
        textField.enabled = true
        handleExistsLabel?.hidden = true
        collectionController?.enableNextButton(false)
    }
    

    override func willShow() {
        
        super.willShow()
        resetDisplay()
    }

    
    override func didShow() {
        
        super.didShow()
        textField.becomeFirstResponder()
        startObservations()
    }
    
    
    override func willHide() {
        
        super.willHide()
        endObservations()
    }
    
    
    override func didTapNextButton() {
        
        super.didTapNextButton()
        if usedForHandleCreation {
            collectionController?.presentNextView()
        }
        else {
            fetchDataForExistingHandle()
        }
    }
    
    
    private var handleIsUnique = false {
        
        didSet {
            handleExistsLabel?.hidden = handleIsUnique
            handleEntryStatusImageView?.indicateOK(handleIsUnique)
            collectionController?.enableNextButton(handleIsUnique)
        }
    }
    
    
    
    //MARK: - Actions
    
    func fetchDataForExistingHandle() {
        
        guard usedForHandleCreation == false else {
            return
        }
        
        func confirmHandleExists(handle: String) {
            
            func handleFetchCompletion(user: User?, error: NSError?) {
                
            }
            
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, caseInsensitive: false) {
               
                (fetchResults, error) in
                
                self.validatingHandleActivityIndicator.stopAnimating()
                self.collectionController?.pageViewControllerStatusMessageDidChange(self, message: nil)
                
                if let error = error {
                    self.presentOKAlertWithError(error, messagePreamble: "Error fetching data from server.", actionHandler: { self.resetDisplay() })
                }
                else {
                    
                    if let _ = fetchResults?.first as? User {
                        
                        self.collectionController?.presentNextView()
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
        
        collectionController?.pageViewControllerStatusMessageDidChange(self, message: "Fetching data...")
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
        
        Globals.sharedInstance.handleUsedToLogin = textField.text!
        
        guard usedForHandleCreation else {
            return
        }
        
        func handleIsLongEnough(text: String) -> Bool {
            
            let trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return trimmedText.length >= User.minimumHandleLength
        }
        
        func confirmUniqueHandle(handle: String) {
            
            handleEntryStatusImageView?.hidden = true
            validatingHandleActivityIndicator.startAnimating()
            
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, caseInsensitive: true) {
                
                (fetchResults, error) in
                
                if let error = error {
                    self.presentOKAlertWithError(error, messagePreamble: "Error validating handle: ")
                }
                else {
                    
                    if let _ = fetchResults?.first as? User {
                        self.handleIsUnique = false
                    }
                    else {
                        self.handleIsUnique = true
                    }
                    
                    self.validatingHandleActivityIndicator.stopAnimating()
                    self.handleEntryStatusImageView?.hidden = false
                }
            }
            
            FetchQueue.sharedInstance.addOperation(fetchUserOperation)
        }
        
        if handleIsLongEnough(textField.text!) {
            confirmUniqueHandle(textField.text!)
        }
        else {
            collectionController?.enableNextButton(false)
            handleEntryStatusImageView?.indicateOK(false)
            handleExistsLabel?.hidden = true
        }
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // @ sign
        if range.location == 0 {
            return false
        }
        
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if usedForHandleCreation {
            if handleIsUnique {
                collectionController?.presentNextView()
            }
        }
        else {
            fetchDataForExistingHandle()
        }

        return true
    }
    
}

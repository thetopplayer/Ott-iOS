//
//  UsernameEntryViewController.swift
//  Ott
//
//  Created by Max on 7/27/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UsernameEntryViewController: PageViewController, UITextFieldDelegate {

    @IBOutlet weak var nameEntryStatusImageView: UIImageView!
  
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textField.delegate = self
        nameEntryStatusImageView.image = nil // need to start off with nil to get the tint to behave correctly when the images are set
    }
    
    
    private func resetDisplay() {
        
        textField.text = ""
        collectionController?.enableNextButton(false)
    }
    
    
    
    //MARK: - Main
    
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
        textField.resignFirstResponder()
        endObservations()
    }

    
    override func didTapNextButton() {
        
        super.didTapNextButton()
        collectionController?.presentNextView()
    }

    
    
    //MARK: - Data and Display
    
    private var nameIsValid = false {
        
        didSet {
            
            if nameIsValid {
                Globals.sharedInstance.nameUsedToLogin = textField.text!
            }
            
            nameEntryStatusImageView.indicateOK(nameIsValid)
            collectionController?.enableNextButton(nameIsValid)
        }
    }
    
    

    //MARK: - Observations and TextField Delegate
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return string.isSuitableForUserName()
    }
    

    func handleTextFieldDidChange(notification: NSNotification) {
        
        func nameIsLongEnough() -> Bool {
            let name = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return name.length >= User.minimumUserNameLength
        }
        
        if (notification.object as! UITextField) == textField {
            nameIsValid = nameIsLongEnough()
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if nameIsValid {
            collectionController?.presentNextView()
        }
        return true
    }
    
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        
//        if nameIsValid {
//            collectionController?.next(self)
//        }
//    }
}

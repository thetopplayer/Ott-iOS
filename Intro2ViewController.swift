//
//  Intro2ViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit

class Intro2ViewController: PageViewController, UITextFieldDelegate {


    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Disabled)
        enableButton(button, value: false)
        
        startObservations()
    }

    
    deinit {
        
        endObservations()
    }

    
    //MARK: - Main
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return range.location > 1;
    }
    
    
    override func didShow() {
        
        super.didShow()
        tasksCompleted = false
        textField.becomeFirstResponder()
    }
    
    
    @IBAction func handleButtonClick(sender: AnyObject) {
        
        textField.resignFirstResponder()
        currentUser().phoneNumber = textField.text
        
        tasksCompleted = true
        let parent = parentViewController as! PageCollectionViewController
        parent.next(self)
    }
    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)
    }
    
    
    func endObservations () {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleTextFieldDidChange (notification: NSNotification) {
        
        enableButton(button, value: textField.text!.stringWithDigits().length > 6)
    }
    

}

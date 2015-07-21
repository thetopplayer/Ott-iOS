//
//  TopicCreationTitleTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


protocol TopicCreationTitleTableViewCellDelegate {
    
    func titleViewTitleFieldDidChange(text: String?) -> Void
}


class TopicCreationTitleTableViewCell: TableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!

    var delegate: TopicCreationTitleTableViewCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        innerContentContainer?.addBorder()
        textField.addRoundedBorder()
        textField.delegate = self
        textView.addRoundedBorder()
        textView.delegate = self
        
        startObservations()
    }
    
    
    deinit {
        endObservations()
    }

    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    override func becomeFirstResponder() -> Bool {
        
        let ok = super.becomeFirstResponder()
        if ok {
            textField.becomeFirstResponder()
         }
        
        return ok
    }
    
    
    override func resignFirstResponder() -> Bool {
        
        textField.resignFirstResponder()
        textView.resignFirstResponder()
        return true
    }
    
    
    
    
    //MARK: - Data Entry
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string.containsCharacter(inCharacterSet: NSCharacterSet.newlineCharacterSet()) {
            textView.becomeFirstResponder()
            return false
        }
        
        if string.containsCharacter(inCharacterSet: NSCharacterSet.whitespaceCharacterSet()) {
            return false
        }
        
        return true
    }
    
    private var isDisplayingTextViewPlaceholder = true
    private func displayTextViewPlaceholder() {
        
        textView.textColor = UIColor.lightGrayColor()
        textView.text = "Comment"
        textView.selectedRange = NSRange(location: 0, length: 0)
        isDisplayingTextViewPlaceholder = true
    }
    
    
    private func hideTextViewPlaceholder() {
        
        textView.textColor = UIColor.darkGrayColor()
        textView.text = ""
        isDisplayingTextViewPlaceholder = false
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if isDisplayingTextViewPlaceholder {
            hideTextViewPlaceholder()
        }
    }
    
    
    var title: String? {
        get {
            return textField.text
        }
        
        set {
            textField.text = newValue
        }
    }
    
    
    var comment: String? {
        get {
            if isDisplayingTextViewPlaceholder {
                return nil
            }
            return textView.text
        }
        
        set {
            if newValue != nil {
                hideTextViewPlaceholder()
                textView.text = newValue
            }
            else {
                displayTextViewPlaceholder()
            }
        }
    }
    
    

    //MARK: - Observations
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: textField)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    
    //MARK: - TopicCreationTitleTableViewCellDelegate
    
    func handleTextFieldDidChange(notification: NSNotification) {
  
        if let delegate = delegate {
            delegate.titleViewTitleFieldDidChange(textField!.text)
        }
    }
    
}

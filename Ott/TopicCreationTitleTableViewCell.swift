//
//  TopicCreationTitleTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


protocol TopicCreationTitleTableViewCellDelegate {
    
    func validNameWasEntered(isValid: Bool) -> Void
}


class TopicCreationTitleTableViewCell: TableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var warningLabel: UILabel!

    var delegate: TopicCreationTitleTableViewCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        warningLabel.hidden = true
        warningLabel.text = "\u{26A0}  You already authored this topic"
        
        textField.delegate = self
        textField.placeholder = "#name"
        
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
            if let length = title?.length {
                if length > 0 {
                    textView.becomeFirstResponder()
                }
                else {
                    textField.becomeFirstResponder()
                }
            }
            else {
                textField.becomeFirstResponder()
            }
         }
        
        return ok
    }
    
    
    override func resignFirstResponder() -> Bool {
        
        textField.resignFirstResponder()
        textView.resignFirstResponder()
        return true
    }
    
    
    
    
    //MARK: - Data Entry
    
    lazy var authoredTopicNames: [String] = {
        
        return currentUser().authoredTopicNames()
    }()
    
    
    func didAuthorTopicNamed(name: String?) -> Bool {
        
        if let name = name {
            return authoredTopicNames.contains(name)
        }
        else {
            return false
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if textField.text!.length == 0 {
            textField.text = "#"
        }
        
        return true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 {
            return false
        }
        
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
            let text = textField.text?.stringByReplacingOccurrencesOfString("#", withString: "")
            return text
        }
        
        set {
            if let text = newValue?.stringByReplacingOccurrencesOfString("#", withString: "") {
                textField.text = "#" + text
            }
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
  
        let didAuthor = didAuthorTopicNamed(title)
        warningLabel.hidden = didAuthor == false
        
        if let nameLength = title?.length {
            
            if let delegate = delegate {
                delegate.validNameWasEntered(didAuthor == false && nameLength > 0)
            }
        }
    }
    
}

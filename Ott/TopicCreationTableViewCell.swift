//
//  TopicCreationTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


protocol TopicCreationTableViewCellDelegate {
    
    func validNameWasEntered(isValid: Bool) -> Void
}


class TopicCreationTableViewCell: TableViewCell, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var topicImageView: ParseImageView?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!

    var delegate: TopicCreationTableViewCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        contentView.addBorder()
        
        nameTextField.delegate = self
        nameTextField.placeholder = "topic name"
        
        commentTextView.addRoundedBorder()
        commentTextView.delegate = self
        
        if let topicImageView = topicImageView {
            
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
            
            let tapGR: UIGestureRecognizer = {
                
                let gr = UITapGestureRecognizer()
                gr.addTarget(self, action: "displayImageDetail:")
                return gr
            }()
            
            topicImageView.addGestureRecognizer(tapGR)
            topicImageView.userInteractionEnabled = true
        }
        
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
                    commentTextView.becomeFirstResponder()
                }
                else {
                    nameTextField.becomeFirstResponder()
                }
            }
            else {
                nameTextField.becomeFirstResponder()
            }
         }
        
        return ok
    }
    
    
    override func resignFirstResponder() -> Bool {
        
        nameTextField.resignFirstResponder()
        commentTextView.resignFirstResponder()
        return true
    }
    
    
    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        if superview != nil {
            becomeFirstResponder()
        }
    }
    
    
    //MARK: - Data Entry
    
//    lazy var authoredTopicNames: [String] = {
//        
//        return currentUser().authoredTopicNames()
//    }()
//    
//    
//    func didAuthorTopicNamed(name: String?) -> Bool {
//        
//        if let name = name {
//            return authoredTopicNames.contains(name)
//        }
//        else {
//            return false
//        }
//    }
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        title = topic.name
        comment = topic.comment
        topicImageView?.displayImageInFile(topic.imageFile)
    }
    
    
    @IBAction func displayImageDetail(sender: AnyObject?) {
        
        guard let imageView = topicImageView else {
            return
        }
        
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = self
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode:JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.None)
        
        //        imageViewer.optionsDelegate = self
        
        imageViewer.showFromViewController(topmostViewController(), transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    
    //MARK: - JTSImageViewControllerOptionsDelegate
    
    //    func alphaForBackgroundDimmingOverlayInImageViewer(viewer: JTSImageViewController) -> CGFloat {
    //        return CGFloat(0.5)
    //    }
    //
    //
    //    func backgroundBlurRadiusForImageViewer(viewer: JTSImageViewController) -> CGFloat {
    //        return CGFloat(4.0)
    //    }

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
//        if textField.text!.length == 0 {
//            textField.text = "#"
//        }
        
        return true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
//        if range.location == 0 {
//            return false
//        }
//        
        if range.location > Topic.maximumNameLength {
            return false
        }
        
        if string.containsCharacter(inCharacterSet: NSCharacterSet.newlineCharacterSet()) {
            commentTextView.becomeFirstResponder()
            return false
        }
        
//        if string.containsCharacter(inCharacterSet: NSCharacterSet.whitespaceCharacterSet()) {
//            return false
//        }
        
        return true
    }
    
    private var isDisplayingTextViewPlaceholder = true
    private func displayTextViewPlaceholder() {
        
        commentTextView.textColor = UIColor.lightGrayColor()
        commentTextView.text = "Comment"
        commentTextView.selectedRange = NSRange(location: 0, length: 0)
        isDisplayingTextViewPlaceholder = true
    }
    
    
    private func hideTextViewPlaceholder() {
        
        commentTextView.textColor = UIColor.darkGrayColor()
        commentTextView.text = ""
        isDisplayingTextViewPlaceholder = false
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if isDisplayingTextViewPlaceholder {
            hideTextViewPlaceholder()
        }
    }
    
    
    var title: String? {
        
        get {
            return nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        set {
            nameTextField.text = newValue
        }
    }
    
    
    var comment: String? {
        
        get {
            if isDisplayingTextViewPlaceholder {
                return nil
            }
            let text = commentTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if text.length == 0 {
                return nil
            }
            return text
        }
        
        set {
            if newValue != nil {
                hideTextViewPlaceholder()
                commentTextView.text = newValue!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            else {
                displayTextViewPlaceholder()
            }
        }
    }
    
    

    //MARK: - Observations
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    //MARK: - TopicCreationTitleTableViewCellDelegate
    
    func handleTextFieldDidChange(notification: NSNotification) {
  
        func notifyDelegate(validName: Bool) {
            
            if let delegate = self.delegate {
                delegate.validNameWasEntered(validName)
            }
        }
        
        if let topicName = nameTextField.text {
            
            if topicName.length == 0 {
                notifyDelegate(false)
            }
            else {
                
                currentUser().verifyNewTopicTitle(topicName) {
                    
                    (isNew) in
                    
//                    self.warningLabel.hidden = isNew
                    notifyDelegate(isNew)
                }
            }
        }
        else {
            notifyDelegate(false)
        }
    }
    
}

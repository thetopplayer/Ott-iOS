//
//  PostInputView.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


protocol PostInputViewDelegate {
    
    func postInputViewPostActionDidOccur() -> Void
}



class PostInputView: UIView, UITextViewDelegate {

    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: TextView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var postButton: UIButton!
    
    var delegate: PostInputViewDelegate?
    
    var minimumViewHeight: CGFloat = 0
    var maximumViewHeight: CGFloat?
    var currentTextViewContentHeight: CGFloat = 0
    var defaultViewHeightWithoutText: CGFloat = 0
    
    
    private let commentFont = UIFont.systemFontOfSize(18)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        containerView.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        containerView.addBorder()
        
        textView.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        textView.textContainerInset = UIEdgeInsetsMake(6, 4, 2, 4)
        textView.addRoundedBorder()
        textView.font = commentFont
        textView.scrollEnabled = true
        textView.bounces = false
        textView.showsHorizontalScrollIndicator = false
        textView.delegate = self
        
        ratingLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        ratingLabel.addRoundedBorder()
        
        slider.addTarget(self, action: "handleSliderAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        postButton.addTarget(self, action: "handlePostAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: "handleSwipeDown")
        swipeGR.direction = .Down
        self.addGestureRecognizer(swipeGR)
        
        minimumViewHeight = heightLayoutConstraint.constant
        
        reset()
    }
    
    
    //MARK: - Display
    
    private func reset() {
        
        slider.setValue(0, animated: false)
        rating = nil
        displayTextViewPlaceholder()
        postButton.enabled = false
        updateDisplay(withValue: rating)
        
        textView.displayScrolling = false
        
        heightLayoutConstraint.constant = minimumViewHeight
        layoutIfNeeded()
        currentTextViewContentHeight = desiredTextHeight()
        defaultViewHeightWithoutText = minimumViewHeight - currentTextViewContentHeight
    }
    
    
    private func updateDisplay(withValue value: Float?) {
        
        let text = Post.ratingToText(value)
        let color = Post.ratingToColor(value)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.ratingLabel.text = text
            self.ratingLabel.textColor = color
        })
    }
    
    
    
    //MARK: - Data
    
    var rating: Float? {
        didSet {
            postButton.enabled = rating != nil
        }
    }
    
    
    var comment: String? {
        return textView.text
    }
    
    
    
    //MARK: - Input
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    
    func handleSliderAction(sender: UISlider) {
        
        rating = sender.value
        updateDisplay(withValue: rating)
    }
    
    
    func handlePostAction(sender: UISlider) {
        
        resignFirstResponder()
        delegate?.postInputViewPostActionDidOccur()
    }
    
    
    func handleSwipeDown() {
        
        resignFirstResponder()
    }
    
    
    //MARK: - TextView
    
    private var _isDisplayingTextViewPlaceholder = true
    private func displayTextViewPlaceholder() {
        
        textView.textColor = UIColor.lightGrayColor()
        textView.font = UIFont.systemFontOfSize(16)
        textView.text = "Comment"
        textView.selectedRange = NSRange(location: 0, length: 0)
        _isDisplayingTextViewPlaceholder = true
    }
    
    
    private func hideTextViewPlaceholder() {
        
        if _isDisplayingTextViewPlaceholder {
            
            textView.textColor = UIColor.blackColor()
            textView.font = commentFont
            textView.text = ""
            _isDisplayingTextViewPlaceholder = false
        }
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        hideTextViewPlaceholder()
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    
    private func desiredTextHeight() -> CGFloat {
        
        let fixedWidth = textView.frame.size.width
        let fitSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        return fitSize.height
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        func adjustViewToHeight(height: CGFloat) {
            
            layoutIfNeeded()
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.heightLayoutConstraint.constant = height
                self.layoutIfNeeded()
            })
        }
        
        let textHeight = desiredTextHeight()
        if textHeight != currentTextViewContentHeight {
            
            let adjustedViewHeight = defaultViewHeightWithoutText + textHeight
            if let maximumViewHeight = maximumViewHeight {
                
                if adjustedViewHeight > maximumViewHeight {
                    (textView as! TextView).displayScrolling = true
                }
                else {
                    (textView as! TextView).displayScrolling = false
                    adjustViewToHeight(adjustedViewHeight)
                }
            }
            else {
                adjustViewToHeight(adjustedViewHeight)
            }
            
            currentTextViewContentHeight = textHeight
        }
    }
    
}

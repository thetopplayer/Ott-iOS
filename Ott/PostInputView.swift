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
    
    var delegate: PostInputViewDelegate?
    
    var minimumViewHeight: CGFloat = 0
    var maximumViewHeight: CGFloat?
    var currentTextViewContentHeight: CGFloat = 0
    var defaultViewHeightWithoutText: CGFloat = 0
    
    
    private let commentFont = UIFont.systemFontOfSize(18)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addBorder()
        containerView.addUpShadow()
        
        textView.backgroundColor = UIColor.whiteColor()
        textView.textContainerInset = UIEdgeInsetsMake(6, 4, 2, 4)
        textView.addRoundedBorder()
        textView.font = commentFont
        textView.scrollEnabled = true
        textView.bounces = false
        textView.showsHorizontalScrollIndicator = false
        textView.delegate = self
        
        slider.tintColor = UIColor.tint()
        slider.addTarget(self, action: "handleSliderAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        let tapGR = UITapGestureRecognizer(target: self, action: "handlePostAction")
        ratingLabel.addGestureRecognizer(tapGR)
        ratingLabel.userInteractionEnabled = true
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: "handleSwipeDown")
        swipeGR.direction = .Down
        self.addGestureRecognizer(swipeGR)
        
        minimumViewHeight = heightLayoutConstraint.constant
        
        reset()
    }
    
    
    //MARK: - Display
    
    func reset() {
        
        slider.setValue(0, animated: false)
        rating = nil
        displayTextViewPlaceholder()
        
        updateDisplay(withRating: rating)
        
        textView.displayScrolling = false
        
        heightLayoutConstraint.constant = minimumViewHeight
        layoutIfNeeded()
        currentTextViewContentHeight = desiredTextHeight()
        defaultViewHeightWithoutText = minimumViewHeight - currentTextViewContentHeight
    }
    
    private var didDrawActiveLabel = false
    private func updateDisplay(withRating rating: Rating?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let rating = rating {
                
                if self.didDrawActiveLabel == false {
                    
                    self.ratingLabel.addRoundedBorder(withColor: UIColor.tint())
                    self.ratingLabel.backgroundColor = UIColor.tint()
                    self.ratingLabel.textColor = UIColor.whiteColor()
                    self.ratingLabel.font = UIFont.boldSystemFontOfSize(20)
                    self.didDrawActiveLabel = true
                }
                
                self.ratingLabel.text = rating.text()
            }
            else {
                
                self.ratingLabel.addRoundedBorder(withColor: UIColor.lightGrayColor())
                self.ratingLabel.backgroundColor = UIColor.whiteColor()
                self.ratingLabel.textColor = UIColor.lightGrayColor()
                self.ratingLabel.font = UIFont.systemFontOfSize(15)
                self.ratingLabel.text = "Post"
                self.didDrawActiveLabel = false
            }
        })
    }
    
    
    
    //MARK: - Data
    
    var rating: Rating?
    
    var comment: String? {
        
        if _isDisplayingTextViewPlaceholder {
            return nil
        }
        
        return textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    
    
    //MARK: - Input
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    
    func handleSliderAction(sender: UISlider) {
        
        rating = Rating(withFloat: sender.value)
        updateDisplay(withRating: rating)
    }
    
    
    func handlePostAction() {
        
        if rating != nil {
            resignFirstResponder()
            delegate?.postInputViewPostActionDidOccur()
        }
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

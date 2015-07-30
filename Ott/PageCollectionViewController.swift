//
//  PageCollectionViewController.swift
//  mailr
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit

let PagingViewControllerDidViewLastPageNotification = "PagingViewControllerDidViewLastPageNotification"


class PageCollectionViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl?
    
    
    
    var currentPage = 0
    
    var pageViewControllers : [PageViewController] = [] {
        
        didSet {
            
            var pageViews : [UIView] = []
            for controller in pageViewControllers {
                
                addChildViewController(controller)
                pageViews.append(controller.view)
            }
            
            setSubviews(pageViews)
            currentPage = 0
            pageViewControllers[currentPage].didShow()
        }
    }
    
    var numberOfPages : Int {
        
        return pageViewControllers.count
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.scrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let leftGR = UISwipeGestureRecognizer()
        leftGR.direction = UISwipeGestureRecognizerDirection.Left
        leftGR.addTarget(self, action: "next:")
        self.view.addGestureRecognizer(leftGR)
        
        let rightGR = UISwipeGestureRecognizer()
        rightGR.direction = UISwipeGestureRecognizerDirection.Right
        rightGR.addTarget(self, action: "previous:")
        self.view.addGestureRecognizer(rightGR)
    }
    
    
    //MARK: - Main
    
    func setSubviews (subviews: Array<UIView>) {
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        scrollView.contentSize = CGSize(width: width * CGFloat(numberOfPages), height: height)
        
        var frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        for var index = 0; index < numberOfPages; index++ {
            
            let view = subviews[index]
            
            frame.origin.x = CGFloat(index) * width
            view.frame = frame
            scrollView.addSubview(view)
        }
        
        if pageControl != nil {
            pageControl!.numberOfPages = numberOfPages
        }
    }
    
    
    @IBAction func next (sender: AnyObject) {
        
        if (numberOfPages == 0) {
            return
        }
        
        if pageViewControllers[currentPage].tasksCompleted {
        
            if currentPage == numberOfPages - 1 {
                
                handleCompletion()
            }
            else {
                
                var offset = self.scrollView.contentOffset
                offset.x += self.scrollView.bounds.size.width
                self.scrollView.setContentOffset(offset, animated: true)
                
                currentPage++
                pageViewPreferredSizeDidChange(pageViewControllers[currentPage])
            }
        }
    }
    
    
    @IBAction func previous (sender: AnyObject) {
        
        if (currentPage == 0) {
            return
        }
        
        pageViewControllers[currentPage].willHide()
        
        var offset = self.scrollView.contentOffset
        offset.x -= self.scrollView.bounds.size.width
        self.scrollView.setContentOffset(offset, animated: true)
        
        currentPage--
        pageViewPreferredSizeDidChange(pageViewControllers[currentPage])
    }
    
    
    func handleCompletion() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(PagingViewControllerDidViewLastPageNotification, object: self)
    }
    
    
    
    //MARK: - Scroll View Sizing
    
    var scrollViewHeight: CGFloat {
        
        get {
            
            return scrollView.frame.size.height
        }
        
        set {
            
            if let superViewHeight = scrollView.superview?.frame.size.height {
                
                let allowedHeight = superViewHeight - scrollView.frame.origin.y - scrollViewBottomSpacing
                
                scrollViewHeightConstraint.constant = min(allowedHeight, newValue)
            }
            else {
                
                scrollViewHeightConstraint.constant = newValue
            }
        }
    }
    
    static let minimumScrollViewBottomSpacing: CGFloat = 20.0
    
    private var _scrollViewBottomSpacing: CGFloat = minimumScrollViewBottomSpacing
    var scrollViewBottomSpacing: CGFloat {

        set {
            _scrollViewBottomSpacing = newValue + 20.0
            pageViewPreferredSizeDidChange(pageViewControllers[currentPage])
        }
        
        get {
            return _scrollViewBottomSpacing
        }
    }
    

    func pageViewPreferredSizeDidChange(controller: PageViewController) {
        
        if pageViewControllers[currentPage] == controller {
            
            if let height = controller.preferredSize?.height {
                scrollViewHeight = height
            }
        }
    }
    
    
    
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        if let pc = pageControl {
            pc.currentPage = currentPage
        }
        
        pageViewControllers[currentPage].didShow()
    }
}
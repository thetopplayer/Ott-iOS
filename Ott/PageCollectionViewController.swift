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
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var nextButton: UIBarButtonItem?
    
    var allowDismissalOnFirstPage = true
    var currentPage = 0
    
    
    var titleView: UIView?
    func displayTitleView() -> Bool {
        
        guard let titleView = titleView else {
            return false
        }
        navigationItem.titleView = titleView
        return true
    }
    
    var navigationTitle: String?
    func displayStatus(message: String?) {
        
        guard let message = message else {
            
            if displayTitleView() == false {
                navigationItem.title = navigationTitle
            }
            return
        }
        
        navigationItem.titleView = nil
        navigationItem.title = message
    }
    
    
    var pageViewControllers : [PageViewController] = [] {
        
        didSet {
            
            var pageViews : [UIView] = []
            for controller in pageViewControllers {
                
                controller.collectionController = self
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
    
    
    func enableNextButton(enable: Bool = true) {
        
        nextButton?.enabled = enable
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
        leftGR.addTarget(self, action: "handleLeftSwipe:")
        view.addGestureRecognizer(leftGR)
        
        let rightGR = UISwipeGestureRecognizer()
        rightGR.direction = UISwipeGestureRecognizerDirection.Right
        rightGR.addTarget(self, action: "previous:")
        view.addGestureRecognizer(rightGR)
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
        
        if let pageControl = pageControl {
            pageControl.numberOfPages = numberOfPages
        }
    }
    
    
    func handleLeftSwipe(sender: AnyObject) {
    
        guard let nextButton = nextButton else {
            return
        }
        
        if nextButton.enabled {
            next(self)
        }
    }
    
 
    @IBAction func next(sender: AnyObject) {
        
        pageViewControllers[currentPage].didTapNextButton()
    }
    
    
    func presentNextView() {
        
        guard currentPage < numberOfPages - 1 else {
            handleCompletion()
            return
        }
        
        pageViewControllers[currentPage].willHide()
        pageViewControllers[currentPage + 1].willShow()
        
        var offset = self.scrollView.contentOffset
        offset.x += self.scrollView.bounds.size.width
        self.scrollView.setContentOffset(offset, animated: true)
        
        currentPage++
        pageViewPControllerPreferredSizeDidChange(pageViewControllers[currentPage])
    }
    
    
    @IBAction func previous (sender: AnyObject) {
        
        guard currentPage > 0 else {
            if allowDismissalOnFirstPage {
                navigationController?.popViewControllerAnimated(true)
            }
            return
        }
        
        pageViewControllers[currentPage].willHide()
        pageViewControllers[currentPage - 1].willShow()
        
        var offset = self.scrollView.contentOffset
        offset.x -= self.scrollView.bounds.size.width
        self.scrollView.setContentOffset(offset, animated: true)
        
        currentPage--
        pageViewPControllerPreferredSizeDidChange(pageViewControllers[currentPage])
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
            pageViewPControllerPreferredSizeDidChange(pageViewControllers[currentPage])
        }
        
        get {
            return _scrollViewBottomSpacing
        }
    }
    
    
    
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        pageViewControllers[currentPage].didShow()
        pageControl?.currentPage = currentPage
    }
    
    
    
    
    func pageViewPControllerPreferredSizeDidChange(controller: PageViewController) {
        
        if pageViewControllers[currentPage] == controller {
            
            if let height = controller.preferredSize?.height {
                scrollViewHeight = height
            }
        }
    }
    
    
    func pageViewControllerDidClickNext(controller: PageViewController) {
        
        next(controller)
    }
    
    
    func pageViewControllerStatusMessageDidChange(controller: PageViewController, message: String?) {
        
        displayStatus(message)
    }

}
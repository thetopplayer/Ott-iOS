//
//  LoginViewController.swift
//  Ott
//
//  Created by Max on 7/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class LoginViewController: PageCollectionViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        backButton!.tintColor = UIColor.tint()
        scrollView.addRoundedBorder()
        
        pageViewControllers = {
            
            let vc0 = HandleEntryViewController(nibName: "HandleEntryView", bundle: nil)
            vc0.usedForHandleCreation = false
            let vc1 = PhoneNumberEntryViewController(nibName: "PhoneNumberEntryView", bundle: nil)
            vc1.verificationType = .PhoneAndHandle
            let vc2 = ConfirmCodeEntryViewController(nibName: "ConfirmCodeEntryView", bundle: nil)
            vc2.successAction = .LogIn
            return [vc0, vc1, vc2]
            }()
        
        pageControl = {
            
            let pc = UIPageControl(frame: CGRectZero)
            pc.numberOfPages = pageViewControllers.count
            pc.currentPage = 0
            pc.pageIndicatorTintColor = UIColor.lightGrayColor()
            pc.currentPageIndicatorTintColor = UIColor.darkGrayColor()
            pc.sizeToFit()
            return pc
            }()
        
        titleView = pageControl
        displayTitleView()
    }
    
    
    override func handleCompletion() {
        
        presentViewController(mainViewController(), animated: true, completion: nil)
    }
}

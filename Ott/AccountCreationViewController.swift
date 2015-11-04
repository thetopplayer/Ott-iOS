//
//  AccountCreationViewController.swift
//  Ott
//
//  Created by Max on 4/24/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class AccountCreationViewController: PageCollectionViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.background()
        backButton!.tintColor = UIColor.tint()
        scrollView.addRoundedBorder()
        
        pageViewControllers = {
            
            let vc0 = IntroductionView0ViewController(nibName: "IntroductionView0", bundle: nil)
            let vc1 = UsernameEntryViewController(nibName: "UsernameEntryView", bundle: nil)
            let vc2 = HandleEntryViewController(nibName: "HandleCreationView", bundle: nil)
            let vc3 = IntroductionView1ViewController(nibName: "IntroductionView1", bundle: nil)
            let vc4 = PhoneNumberEntryViewController(nibName: "PhoneNumberEntryView", bundle: nil)
            let vc5 = ConfirmCodeEntryViewController(nibName: "ConfirmCodeEntryView", bundle: nil)
            return [vc0, vc1, vc2, vc3, vc4, vc5]
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
        
        performSegueWithIdentifier("segueToAvatarCreation", sender: self)
    }
}

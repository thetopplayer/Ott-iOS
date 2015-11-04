//
//  PageViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit


class PageViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    var collectionController: PageCollectionViewController?
        
    var preferredSize : CGSize? {
        
        didSet {
            collectionController?.pageViewPControllerPreferredSizeDidChange(self)
        }
    }
    
    
    // stubs of functions called by PagingViewController
    
    func willShow() {
    }
    
    
    func didShow () {
    }
    
    
    func willHide () {
    }
    
    
    func didTapNextButton() {
    }
    
}
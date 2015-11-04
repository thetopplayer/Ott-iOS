//
//  IntroductionView0ViewController.swift
//  Ott
//
//  Created by Max on 4/26/15.
//  Copyright (c) 2015 Senisa. All rights reserved.
//

import UIKit

class IntroductionView0ViewController: PageViewController {

    override func willShow() {
        
        super.willShow()
        collectionController?.enableNextButton(true)
    }
    
    
    override func didTapNextButton() {
        
        super.didTapNextButton()
        collectionController?.presentNextView()
    }
}

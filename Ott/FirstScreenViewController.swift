//
//  FirstScreenViewController.swift
//  Ott
//
//  Created by Max on 9/22/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FirstScreenViewController: ViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.addRoundedBorder(withColor: UIColor.tint())
    }

}

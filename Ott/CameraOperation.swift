//
//  CameraOperation.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class CameraOperation: Operation {

    private let presentationController: UIViewController
    private let sourceType: UIImagePickerControllerSourceType
    
    init<T:UIViewController where T:UIImagePickerControllerDelegate, T:UINavigationControllerDelegate> (presentationController: T, sourceType: UIImagePickerControllerSourceType) {
        
        self.presentationController = presentationController
        self.sourceType = sourceType
        
        super.init()
        
        addCondition(PhotosCondition())
        
        /*
        This operation modifies the view controller hierarchy.
        Doing this while other such operations are executing can lead to
        inconsistencies in UIKit. So, let's make them mutally exclusive.
        */
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    override func execute() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = presentationController as? protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
        imagePicker.sourceType = self.sourceType
        
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.presentationController.presentViewController(imagePicker, animated: true, completion: { weakSelf!.finish() } )
        }
    }
    
}

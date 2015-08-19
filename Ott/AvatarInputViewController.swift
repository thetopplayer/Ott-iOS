//
//  AvatarInputViewController.swift
//  Ott
//
//  Created by Max on 7/31/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class AvatarInputViewController: ViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "One To Ten"
        navigationItem.hidesBackButton = true
        
        contentContainer.addRoundedBorder()
        imageView.addRoundedBorder()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        
        let tapGR = UITapGestureRecognizer()
        tapGR.addTarget(self, action: "addAvatar:")
        imageView.addGestureRecognizer(tapGR)
        imageView.userInteractionEnabled = true
    }
    
   
    private func clearAvatar() {
        
        currentUser().setImage(nil)
        self.imageView.image = UIImage(named: "addAvatar")
    }
    
    
    
    
    
    //MARK: - Actions
    
    @IBAction func addAvatar(sender: AnyObject) {
    
        func presentOptionsSheet() {
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { action in
                
                self.operationQueue().addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
            })
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { action in
                
                self.operationQueue().addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            
                self.clearAvatar()
                self.doneButton.setTitle("Skip", forState: .Normal)
            })
            
            alertViewController.addAction(libraryAction)
            alertViewController.addAction(cameraAction)
            alertViewController.addAction(cancelAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        presentOptionsSheet()
    }
    
    
    @IBAction func doneAction(sender: AnyObject) {
        
        doneButton.enabled = false
        currentUser().saveInBackground()
        self.presentViewController(mainViewController(), animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let resizedImage = image.resized(toSize: CGSizeMake(200, 200))
        currentUser().setImage(resizedImage)
        
        // setting avatar will shrink and compress the image, so use for what is displayed
        // rather than the raw image itself
        currentUser().getImage() { (success: Bool, image: UIImage?) -> Void in
            
            self.imageView.image = image
            self.doneButton.setTitle("Next", forState: .Normal)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        if currentUser().hasImage {
            doneButton.setTitle("Next", forState: .Normal)
        }
        else {
            doneButton.setTitle("Skip", forState: .Normal)
        }
 
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}

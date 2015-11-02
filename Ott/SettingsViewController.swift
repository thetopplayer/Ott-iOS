//
//  SettingsViewController.swift
//  Ott
//
//  Created by Max on 9/11/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


// note that a lot of this is copied from AccountSetupViewController


class SettingsViewController: TableViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var captionImageView: ParseImageView!
    @IBOutlet weak var avatarImageView: ParseImageView!
    @IBOutlet weak var handleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var handleEntryStatusImageView: UIImageView!
    @IBOutlet weak var nameEntryStatusImageView: UIImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var validatingHandleActivityIndicator: UIActivityIndicatorView!

    
    enum SelectedImageType {
        case None, Avatar, Background
    }
    var selectedImage: SelectedImageType = .None
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.background()
        
        let avatarGR: UITapGestureRecognizer = {
            let tapGR = UITapGestureRecognizer()
            tapGR.addTarget(self, action: "changeAvatar:")
            return tapGR
        }()
        avatarImageView.addGestureRecognizer(avatarGR)
        avatarImageView.userInteractionEnabled = true
        avatarImageView.addBorder(withColor: UIColor.whiteColor(), width: 2.0)
        
        let backgroundGR: UITapGestureRecognizer = {
            let tapGR = UITapGestureRecognizer()
            tapGR.addTarget(self, action: "changeBackground:")
            return tapGR
        }()
        captionImageView.addGestureRecognizer(backgroundGR)
        captionImageView.userInteractionEnabled = true
        captionImageView.layer.masksToBounds = true
        
        bioTextView.backgroundColor = UIColor.clearColor()
        bioTextView.addRoundedBorder()
        
        handleTextField.delegate = self
        nameTextField.delegate = self
        bioTextView.delegate = self
        saveButton.enabled = false
        
        // need to start off with nil to get the tint to behave correctly when the images are set
        handleEntryStatusImageView.image = nil
        nameEntryStatusImageView.image = nil

        isDirty = false
        startObservations()
        
        updateDisplayForUser(currentUser())
    }

    
    func updateDisplayForUser(user: User) {
        
        avatarImageView.displayImageInFile(currentUser().avatarFile, defaultImage: User.defaultAvatarImage)
        captionImageView.displayImageInFile(currentUser().backgroundImageFile, defaultImage: User.defaultBackgroundImage)
        
        nameTextField.text = currentUser().name
        handleTextField.text = currentUser().handle
        bioTextView.text = currentUser().bio
    }
    
    
    deinit {
        
        endObservations()
    }
    
    
    
    //MARK: - Display

    var saveButton: UIBarButtonItem {
        return navigationItem.rightBarButtonItem!
    }
    
    
    private func indicateHandleOK(ok: Bool) {
        handleEntryStatusImageView.indicateOK(ok)
    }
    
    
    private func indicateNameOK(ok: Bool) {
        nameEntryStatusImageView.indicateOK(ok)
    }
    
    
    
    //MARK: - Data

    private var isDirty: Bool = false {
        
        didSet {
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    
    private var handleIsUnique = true {
        
        didSet {
            indicateHandleOK(handleIsUnique)
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }
    
    private var nameIsValid = true {
        
        didSet {
            indicateNameOK(nameIsValid)
            saveButton.enabled = isDirty && handleIsUnique && nameIsValid
        }
    }

    
    private func saveChanges() {
        
        guard handleIsUnique && nameIsValid else {
            return
        }
        
        currentUser().name = nameTextField.text
        currentUser().handle = handleTextField.text
        currentUser().bio = bioTextView.text
        
        MaintenanceQueue.sharedInstance.addOperation(UpdateUserOperation(completion: nil))
    }
    
    
    
    //MARK: - Actions

    
    private func presentImageOptions() {
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { action in
            
            self.operationQueue.addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
        })
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { action in
            
            self.operationQueue.addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            
        })
        
        alertViewController.addAction(libraryAction)
        alertViewController.addAction(cameraAction)
        alertViewController.addAction(cancelAction)
        
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func changeAvatar(sender: AnyObject) {
        
        selectedImage = .Avatar
        presentImageOptions()
    }
    
    
    @IBAction func changeBackground(sender: AnyObject) {
        
        selectedImage = .Background
        presentImageOptions()
    }
    
    
    @IBAction func handleSaveAction(sender: AnyObject) {
        
        saveChanges()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func logout() {

        let alertViewController: UIAlertController = {
            
            let controller = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in
                MaintenanceQueue.sharedInstance.addOperation(LogoutOperation())
                self.presentViewController(introViewController(), animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            
            return controller
        }()
        
        presentViewController(alertViewController, animated: true, completion: {
            
        })
    }
    
    
    
    //MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
        
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        logout()
    }
    
    
    
    //MARK: - Observations and Delegate Methods
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: handleTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: nameTextField)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == handleTextField {
            
            // @ sign
            if range.location == 0 {
                return false
            }
            
            if string.containsCharacter(inCharacterSet: NSCharacterSet.newlineCharacterSet()) {
                nameTextField.becomeFirstResponder()
                return false
            }
            
            return string.isSuitableForHandle()
        }
        else if textField == nameTextField {
            
            return string.isSuitableForUserName()
        }
        
        return true
    }
    
    
    func handleTextFieldDidChange(notification: NSNotification) {
        
        func handleIsLongEnough() -> Bool {
            return handleTextField.text!.length >= User.minimumHandleLength
        }
        
        
        func nameIsLongEnough() -> Bool {
            return nameTextField.text!.length >= User.minimumUserNameLength
        }
        
        func confirmUniqueHandle(handle: String) {
            
            let fetchUserOperation = FetchUserByHandleOperation(handle: handle, caseInsensitive: true) {
                
                (fetchResults, error) in
                
                if let _ = fetchResults?.first {
                    self.handleIsUnique = false
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                
                    self.validatingHandleActivityIndicator.stopAnimating()
                    self.handleEntryStatusImageView.hidden = false
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error validating handle: ")
                    }
                }
            }
            
            FetchQueue.sharedInstance.addOperation(fetchUserOperation)
        }

        
        if (notification.object as! UITextField) == handleTextField {
            
            if handleIsLongEnough() {
                confirmUniqueHandle(handleTextField.text!)
            }
            else {
                indicateHandleOK(false)
            }
        }
        else if (notification.object as! UITextField) == nameTextField {
            nameIsValid = nameIsLongEnough()
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == handleTextField {
            nameTextField.becomeFirstResponder()
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        isDirty = true
    }

    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if self.selectedImage == .Avatar {
                
                let resizedImage = image.resized(toSize: CGSizeMake(200, 200))
                currentUser().setAvatar(resizedImage)
                self.avatarImageView.image = image
            }
            else if self.selectedImage == .Background {
                
                let resizedImage = image.resized(toSize: CGSizeMake(800, 800))
                currentUser().setBackgroundImage(resizedImage)
                self.captionImageView.image = image
            }
            
            self.isDirty = true
            self.selectedImage = .None
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        selectedImage = .None
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    

}

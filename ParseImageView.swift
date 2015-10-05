//
//  ParseImageView.swift
//  Ott
//
//  Created by Max on 10/2/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ParseImageView: UIImageView {

    private var _imageFile: PFFile?
    
    private func setImageFile(file: PFFile?) {
        
        _imageFile = file
        if _imageFile == nil {
            
            self.image = nil
        }
        else {
            
            _imageFile!.getDataInBackgroundWithBlock {
                
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let imageData = imageData {
                        self.image = UIImage(data: imageData)
                    }
                    else {
                        self.image = nil
                    }
                }
                else {
                    self.image = nil
                }
            }
        }
    }
    
    
    func displayImageInFile(file: PFFile?) {
        
        guard let file = file else {
            
            setImageFile(nil)
            return
        }
        
        if let existingFile = _imageFile {
            
            if existingFile.url == file.url {
                return
            }
            else {
                setImageFile(file)
            }
        }
        else {
            setImageFile(file)
        }
    }
    
}

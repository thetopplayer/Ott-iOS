//
//  ParseImageView.swift
//  Ott
//
//  Created by Max on 10/2/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ParseImageView: UIImageView {
    
    var currentFile: PFFile?
    
    func displayImageInFile(file: PFFile?, defaultImage: UIImage? = nil) {
     
        displayImageInFile(file, withFade: false, defaultImage: defaultImage)
    }
    
    
    func displayImageInFile(file: PFFile?, withFade: Bool, defaultImage: UIImage? = nil) {
        
        guard let file = file else {
            image = defaultImage
            currentFile = nil
            return
        }
        
        if let currentFile = currentFile {
            
            if currentFile.url == file.url {
                return
            }
            currentFile.cancel()
        }
        
        currentFile = file
        currentFile!.getDataInBackgroundWithBlock {
            
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                
                if let imageData = imageData {
                    
                    let image = UIImage(data: imageData)
                    if withFade {
                        self.setImageWithFade(image)
                    }
                    else {
                        self.image = image
                    }
                }
                else {
                    self.image = defaultImage
                }
            }
            else {
                self.image = defaultImage
            }
        }
    }
    
    
    override var image: UIImage? {

        didSet {
            currentFile?.cancel()
        }
    }
    
    
    func clear() {
        
        image = nil
        currentFile = nil
    }
}

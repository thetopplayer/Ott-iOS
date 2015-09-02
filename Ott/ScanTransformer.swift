//
//  ScanTransformer.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/*
    Used to encode and decode PFObject objectIds from AztecCodes

    objectId -> code encoding a prefix and identifier for class type -> AztecCode
    AztecCode -> code -> PFQuery for appropriate class and objectID

*/



import UIKit

/* 
adapted from 
https://github.com/aschuch/AztecCode/blob/master/AztecCode/AztecCode.swift
*/
class AztecCode {
    
    /// CIAztecCodeGenerator generates 15x15 images with padding by default
    let DefaultAztecCodeSize = CGSize(width: 19, height: 19)
    
    /// Data contained in the generated AztecCode
    let data: NSData
    
    /// Foreground color of the output
    /// Defaults to black
    var color = CIColor(red: 0, green: 0, blue: 0)
    
    /// Background color of the output
    /// Defaults to white
    var backgroundColor = CIColor(red: 1, green: 1, blue: 1)
    
    /// Size of the output
    var size = CGSize(width: 200, height: 200)
    
    
    // MARK: Init
    
    init(_ data: NSData) {
        self.data = data
    }
    
    init(_ string: String) {
        data = string.dataUsingEncoding(NSISOLatin1StringEncoding)!
    }
    
    
    // MARK: Generate AztecCode
    
    /// The AztecCode's UIImage representation
    var image: UIImage? {
        
        if let ciImage = ciImage {
            return UIImage(CIImage: ciImage)
        }
        return nil
    }
    
    /// The AztecCode's CIImage representation
    var ciImage: CIImage? {
        
        // Generate AztecCode
        guard let azFilter = CIFilter(name: "CIAztecCodeGenerator") else {
            return nil
        }

        azFilter.setDefaults()
        azFilter.setValue(data, forKey: "inputMessage")
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }
        
        colorFilter.setDefaults()
        colorFilter.setValue(azFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        
        // Size
        let sizeRatioX = size.width / DefaultAztecCodeSize.width
        let sizeRatioY = size.height / DefaultAztecCodeSize.height
        let transform = CGAffineTransformMakeScale(sizeRatioX, sizeRatioY)
        let transformedImage = colorFilter.outputImage!.imageByApplyingTransform(transform)
        
        return transformedImage
    }
}



class ScanTransformer {
    
    static var sharedInstance: ScanTransformer = {
        return ScanTransformer()
        }()
    
    
    private let codePrefixLength = 4
    private let queryCodePosition = 3
    private let codePrefix = "ott"
    
    enum QueryType: Character {
        case User = "0"
        case Topic = "1"
        
        func allCodes() -> [Character] {
            return [User.rawValue, Topic.rawValue]
        }
        
    }
    

    private func queryTypeForCode(text: String) -> QueryType? {
        
        if let char = text.characterAtIndex(queryCodePosition) {
            return QueryType(rawValue: char)
        }
        return nil
    }
    
    
    private func queryTypeForObject(object: PFObject) -> QueryType? {
        
        var theType: QueryType?
        switch object {
            
        case is User:
            theType = .User
            
        case is Topic:
            theType = .Topic
            
        default:
            print("Error:  invalid type")
        }
        
        return theType
    }

    
    func codeAppearsValid(code: String) -> Bool {
        
        if code.hasPrefix(codePrefix) {
            return queryTypeForCode(code) != nil
        }
        return false
    }
    
    
    
    //MARK: - Object From Code
    
    private func objectID(fromCode code: String) -> String? {
        
        return code.substringToEnd(startingAt: codePrefixLength)
    }
    
    
    func queryForCode(code: String) -> PFQuery? {
        
        var query: PFQuery?
        switch queryTypeForCode(code)! {
            
        case .User:
            query = User.query()
            
        case .Topic:
            query = Topic.query()
            
        }
        
        if let objectID = objectID(fromCode: code) {
            
            query?.whereKey("objectId", equalTo: objectID)
            return query
        }
        
        return nil
    }

    
    
    //MARK: - Code and Image Generation
    
    private func codeForObject(object: PFObject) -> String? {
        
        guard let objectID = object.objectId else {
            print ("Error:  object has no Id")
            return nil
        }
        
        if let theType = queryTypeForObject(object) {
            var result = String(codePrefix)
            result.append(theType.rawValue)
            return result + objectID
        }
        
        return nil
    }
    
    
    private func image(fromCode code: String?, size: CGSize = CGSizeMake(100, 100)) -> UIImage? {
        
        if code == nil {
            return nil
        }
        
        let azCode = AztecCode(code!)
        azCode.size = size
        
        return azCode.image
    }
    
    
    func imageForObject(object: PFObject) -> UIImage? {
        
        return image(fromCode: codeForObject(object))
    }
}
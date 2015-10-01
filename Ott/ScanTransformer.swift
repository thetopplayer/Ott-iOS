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


class AztecCode {
    
    /// CIAztecCodeGenerator generates 15x15 images with padding by default
    static let defaultCodeSize = CGSize(width: 19, height: 19)
    static let defaultPadding = CGFloat(2)
    
    let data: NSData
    
    init(_ data: NSData) {
        self.data = data
    }
    
    init(_ string: String) {
        data = string.dataUsingEncoding(NSISOLatin1StringEncoding)!
    }
    
    
    func image(backgroundColor backgroundColor: UIColor, color: UIColor, scale: CGFloat) -> UIImage? {
        
        if let ciimage = ciImage(backgroundColor: backgroundColor, color: color, scale: scale) {
            return UIImage(CIImage: ciimage)
        }
        return nil
    }
    
    
    func ciImage(backgroundColor backgroundColor: UIColor, color: UIColor, scale: CGFloat = 1) -> CIImage? {
        
        guard let azFilter = CIFilter(name: "CIAztecCodeGenerator") else {
            return nil
        }
        
        azFilter.setDefaults()
        azFilter.setValue(data, forKey: "inputMessage")
        
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }
        
        // convert colors
        var red = CGFloat(0), green = CGFloat(0), blue = CGFloat(0), alpha = CGFloat(0)
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let backgroundCIColor = CIColor(red: red, green: green, blue: blue)
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let foregroundCIColor = CIColor(red: red, green: green, blue: blue)
        
        colorFilter.setDefaults()
        colorFilter.setValue(azFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(foregroundCIColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundCIColor, forKey: "inputColor1")
        
        let transform = CGAffineTransformMakeScale(scale, scale)
        let transformedImage = colorFilter.outputImage!.imageByApplyingTransform(transform)
        
        return transformedImage
    }
}


class ScanTransformer {
    
    static let sharedInstance = ScanTransformer()
    
    
    static let codePrefix = "ott://"
    private let fullPrefixLength: Int = {
        return codePrefix.length + 1  // prefix plus query code
    }()
    
    private let queryCodePosition: Int = {
        return codePrefix.length
    }()
    
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
        
        if code.hasPrefix(ScanTransformer.codePrefix) {
            return queryTypeForCode(code) != nil
        }
        return false
    }
    
    
    
    //MARK: - Object From Code
    
    private func objectID(fromCode code: String) -> String? {
        
        return code.substringToEnd(startingAt: fullPrefixLength)
    }
    
    
    func queryForCode(code: String) -> PFQuery? {
        
        let query: PFQuery = {
            
            switch queryTypeForCode(code)! {
                
            case .User:
                return User.query()!
                
            case .Topic:
                return Topic.query()!
             }
        }()
        
        query.limit = 1
        
        if let objectID = objectID(fromCode: code) {
            query.whereKey("objectId", equalTo: objectID)
            return query
        }
        
        return nil
    }

    
    
    //MARK: - Code and Image Generation
    
    func codeForObject(object: PFObject) -> String? {
        
        guard let objectID = object.objectId else {
            print ("Error:  object has no Id")
            return nil
        }
        
        if let theType = queryTypeForObject(object) {
            var result = ScanTransformer.codePrefix
            result.append(theType.rawValue)
            return result + objectID
        }
        
        return nil
    }
    
    
    enum ImageSize: Int {
        
        case Small = 0
        case Medium = 1
        case Large = 2
        case XLarge = 3
        
        func imageScale() -> CGFloat {
            
            var value: CGFloat
            
            switch self {
                
            case .Small:
                value = 2
                
            case .Medium:
                value = 4
                
            case .Large:
                value = 6
                
            case .XLarge:
                value = 8
                
            }
            return value
        }
    }
    
    
    private func image(fromCode code: String?, backgroundColor: UIColor, color: UIColor, size: ImageSize, withCaption text: String?) -> UIImage? {
        
        if code == nil {
            return nil
        }
        
        let azCode = AztecCode(code!)
        let scale = size.imageScale()
        guard let codeImage = azCode.image(backgroundColor: backgroundColor, color: color, scale: scale) else {
            print("ERROR - unable to generate code image")
            return nil
        }

        let captionFont: UIFont = {
            
            var captionFontSize: CGFloat
            switch size {
                
            case .Small:
                captionFontSize = 11
                
            case .Medium:
                captionFontSize = 14
                
            case .Large:
                captionFontSize = 17
                
            case .XLarge:
                captionFontSize = 20
            }
            
            return UIFont.systemFontOfSize(captionFontSize)
        }()
        
        // mask edges (corners) of code image
        let codePadding = (AztecCode.defaultPadding * scale) + 4
        let codeImageHeight = codeImage.size.height
        let maskPath = UIBezierPath(ovalInRect: CGRectMake(-codePadding, -codePadding, codeImageHeight + 2 * codePadding, codeImageHeight + 2 * codePadding))
        let maskedCodeImage = codeImage.maskToPath(maskPath)
        
        let dotBorderWidth = CGFloat(1)
        let innerDotBorder: CGFloat = {
           
            let diameter = codeImageHeight / 0.7
            let padding = 0.5 * (diameter - codeImageHeight)
            return CGFloat(ceilf(Float(padding)))
        }()
        
        let imageFrame = CGRectMake(0, 0, maskedCodeImage.size.width + 2 * innerDotBorder, maskedCodeImage.size.height + 2 * innerDotBorder)
        
        let textFrame: CGRect = {
            
            let vertOffset = CGFloat(8)
            let height = CGFloat(ceilf(Float(captionFont.lineHeight)))
            return CGRectMake(0,
                imageFrame.size.height + vertOffset,
                imageFrame.size.width,
                height)
        }()
        
        let totalOutputFrame: CGRect = {
            
            if text != nil {
                return CGRectUnion(imageFrame, textFrame)
            }
            else {
                return imageFrame
            }
        }()
        
        let dotView = DotView(frame: imageFrame, fillColor: backgroundColor, borderColor: color, borderWidth: dotBorderWidth)
        let dotImage = dotView.image()
        
        UIGraphicsBeginImageContextWithOptions(totalOutputFrame.size, false, 0.0)
        dotImage.drawInRect(imageFrame)
        let codeImageRect = CGRectMake(innerDotBorder, innerDotBorder, maskedCodeImage.size.width, maskedCodeImage.size.height)
        maskedCodeImage.drawInRect(codeImageRect)
        
        if let text = text {

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Center
            let attributes : [String : AnyObject] = [NSForegroundColorAttributeName : color, NSFontAttributeName: captionFont, NSParagraphStyleAttributeName: paragraphStyle]
            
            let string = NSAttributedString(string: text, attributes: attributes)
            let drawingOptions = NSStringDrawingOptions(rawValue: NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.TruncatesLastVisibleLine.rawValue)
            string.drawWithRect(textFrame, options: drawingOptions, context: nil)
        }
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return combinedImage
    }
    
    
    func imageForObject(object: PFObject, backgroundColor: UIColor, color: UIColor, size: ImageSize, withCaption text: String?) -> UIImage? {
        
        let code = codeForObject(object)
        return image(fromCode: code, backgroundColor: backgroundColor, color: color, size: size, withCaption: text)
    }
}
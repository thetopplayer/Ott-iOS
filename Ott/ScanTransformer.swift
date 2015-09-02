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


class DotView: UIView {
    
    var fillColor = UIColor.whiteColor()
    var borderColor = UIColor.blueColor()
    var borderWidth = CGFloat(1)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    
    convenience init(frame: CGRect, fillColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) {
        
        self.init(frame: frame)
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let rect = CGRectMake(borderWidth, borderWidth, bounds.size.width - 2 * borderWidth, bounds.size.height - 2 * borderWidth)
        let path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
        
        path.lineWidth = borderWidth
        borderColor.setStroke()
        path.stroke()
    }
}


class ScanTransformer {
    
    static var sharedInstance: ScanTransformer = {
        return ScanTransformer()
        }()
    
    
    private let codePrefixLength = 4
    private let queryCodePosition = 3
    let codePrefix = "ott"
    
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
            var result = codePrefix
            result.append(theType.rawValue)
            return result + objectID
        }
        
        return nil
    }
    
    
    private func image(fromCode code: String?, backgroundColor: UIColor, color: UIColor, scale: CGFloat) -> UIImage? {
        
        if code == nil {
            return nil
        }
        
        let azCode = AztecCode(code!)
        guard let codeImage = azCode.image(backgroundColor: backgroundColor, color: color, scale: scale) else {
            print("ERROR - unable to generate code image")
            return nil
        }
        
        // mask edges (corners) of code image
        let codePadding = (AztecCode.defaultPadding * scale) + 4
        let codeImageHeight = codeImage.size.height
        let maskPath = UIBezierPath(ovalInRect: CGRectMake(-codePadding, -codePadding, codeImageHeight + 2 * codePadding, codeImageHeight + 2 * codePadding))
        let maskedCodeImage = codeImage.maskToPath(maskPath)
        
        let dotBorderWidth = CGFloat(1)
        let innerDotBorder: CGFloat = {
           
            let diameter = codeImageHeight / 0.7
            let padding = 0.5 * (diameter - codeImageHeight)
            return CGFloat(ceilf(Float(padding) + 1))
        }()
        
        let imageFrame = CGRectMake(0, 0, maskedCodeImage.size.width + 2 * innerDotBorder, maskedCodeImage.size.height + 2 * innerDotBorder)
        let dotView = DotView(frame: imageFrame, fillColor: backgroundColor, borderColor: color, borderWidth: dotBorderWidth)
        let dotImage = dotView.image()
        
        UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, 0.0)
        dotImage.drawInRect(imageFrame)
        maskedCodeImage.drawInRect(CGRectMake(innerDotBorder, innerDotBorder, maskedCodeImage.size.width, maskedCodeImage.size.height))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return combinedImage
    }
    
    
    func imageForObject(object: PFObject, backgroundColor: UIColor, color: UIColor, scale: CGFloat) -> UIImage? {
        
        let code = codeForObject(object)
        return image(fromCode: code, backgroundColor: backgroundColor, color: color, scale: scale)
    }
}
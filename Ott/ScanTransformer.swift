//
//  ScanTransformer.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/*
    Used to encode and decode PFObject objectIds from QRCodes

    objectId -> code encoding a prefix and identifier for class type -> QRCode
    QRCode -> code -> PFQuery for appropriate class and objectID

*/



import UIKit

/* 
adapted from 
https://github.com/aschuch/QRCode/blob/master/QRCode/QRCode.swift
*/
class QRCode {
    
    /**
    The level of error correction.
    
    - Low:      7%
    - Medium:   15%
    - Quartile: 25%
    - High:     30%
    */
    enum ErrorCorrection: String {
        case Low = "L"
        case Medium = "M"
        case Quartile = "Q"
        case High = "H"
    }
    
    /// CIQRCodeGenerator generates 27x27px images per default
    let DefaultQRCodeSize = CGSize(width: 27, height: 27)
    
    /// Data contained in the generated QRCode
    let data: NSData
    
    /// Foreground color of the output
    /// Defaults to black
    var color = CIColor(red: 0, green: 0, blue: 0)
    
    /// Background color of the output
    /// Defaults to white
    var backgroundColor = CIColor(red: 1, green: 1, blue: 1)
    
    /// Size of the output
    var size = CGSize(width: 200, height: 200)
    
    /// The error correction. The default value is `.Low`.
    var errorCorrection = ErrorCorrection.Low
    
    
    // MARK: Init
    
    init(_ data: NSData) {
        self.data = data
    }
    
    init(_ string: String) {
        data = string.dataUsingEncoding(NSISOLatin1StringEncoding)!
    }
    
    
    // MARK: Generate QRCode
    
    /// The QRCode's UIImage representation
    var image: UIImage {
        return UIImage(CIImage: ciImage)
    }
    
    /// The QRCode's CIImage representation
    var ciImage: CIImage {
        // Generate QRCode
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter!.setDefaults()
        qrFilter!.setValue(data, forKey: "inputMessage")
        qrFilter!.setValue(self.errorCorrection.rawValue, forKey: "inputCorrectionLevel")
        
        // Color code and background
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter!.setDefaults()
        colorFilter!.setValue(qrFilter!.outputImage, forKey: "inputImage")
        colorFilter!.setValue(color, forKey: "inputColor0")
        colorFilter!.setValue(backgroundColor, forKey: "inputColor1")
        
        // Size
        let sizeRatioX = size.width / DefaultQRCodeSize.width
        let sizeRatioY = size.height / DefaultQRCodeSize.height
        let transform = CGAffineTransformMakeScale(sizeRatioX, sizeRatioY)
        let transformedImage = colorFilter!.outputImage!.imageByApplyingTransform(transform)
        
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
        
        let qrCode = QRCode(code!)
        qrCode.size = size
        
        return qrCode.image
    }
    
    
    func imageForObject(object: PFObject) -> UIImage? {
        
        return image(fromCode: codeForObject(object))
    }
    
    
    
//    //MARK: - Export Alert
//    
//    private var exportAlert: TKAlert?
//    func presentExportAlertForObject(object: PFObject) {
//        
//        if exportAlert == nil {
//            
//            let alert = TKAlert()
//            alert.title = "Export"
//            alert.style.backgroundStyle = TKAlertBackgroundStyle.Blur
//            alert.actionsLayout = TKAlertActionsLayout.Vertical
//            
//            alert.addActionWithTitle("Print") { (TKAlert, TKAlertAction) -> Bool in
//                
//                return true
//            }
//
//            alert.addActionWithTitle("Email") { (TKAlert, TKAlertAction) -> Bool in
//                
//                return true
//            }
//            
//            alert.addActionWithTitle("Save to Photos") { (TKAlert, TKAlertAction) -> Bool in
//                
//                // todo :  test for photo access first
//                
//                return true
//            }
//            
//            exportAlert = alert
//        }
//        
//        exportAlert!.show(true)
//    }
//    
}
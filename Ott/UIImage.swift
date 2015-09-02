//
//  UIImage.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics

extension UIImage {
    
    func resized(toSize size: CGSize, unlessSmaller: Bool = true) -> UIImage? {
        
        let scale = scaleForProportionalResize(self.size, intoSize: size, onlyScaleDown: unlessSmaller)
        let imageRef = createCGImageFromUIImageScaled(self, scale: scale)
        if imageRef != nil {
            return UIImage(CGImage: imageRef!)
        }
        
        return nil
    }
    
    
    private func scaleForProportionalResize(theSize: CGSize, intoSize: CGSize, onlyScaleDown: Bool) -> CGFloat {
        
        let sx = theSize.width
        let sy = theSize.height
        var dx = intoSize.width
        var dy = intoSize.height
        
        var scale = CGFloat(1.0)
        
        if sx != 0 && sy != 0 {
            dx = dx / sx
            dy = dy / sy
            scale = dx < dy ? dx : dy
            
            if scale > 1 && onlyScaleDown {
                scale = 1
            }
        }
        else {
            scale = 0
        }
        
        return scale
    }
    
    
    private func createCGImageFromUIImageScaled(image: UIImage, scale: CGFloat) -> CGImageRef? {
        
        func createCGBitmapContext(width width: Int, height: Int) -> CGContextRef? {
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
            return CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, bitmapInfo)
        }
        
        
        func transformForOrientation(orientation: UIImageOrientation, width: CGFloat, height: CGFloat) -> CGAffineTransform {
            
            var transform: CGAffineTransform
            
            switch orientation {
                
            case .Down:
                // 0th row is at the bottom, and 0th column is on the right - Rotate 180 degrees
                transform = CGAffineTransformMake(-1.0, 0.0, 0.0, -1.0, width, height)
                
            case .Left:
                // 0th row is on the left, and 0th column is the bottom - Rotate -90 degrees
                transform = CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, height, 0.0)
                
            case .Right:
                // 0th row is on the right, and 0th column is the top - Rotate 90 degrees
                transform	= CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, width)
                
            case .UpMirrored:
                // 0th row is at the top, and 0th column is on the right - Flip Horizontal
                transform	= CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, width, 0.0)
                
            case .DownMirrored:
                // 0th row is at the bottom, and 0th column is on the left - Flip Vertical
                transform	= CGAffineTransformMake(1.0, 0.0, 0, -1.0, 0.0, height)
                
            case .LeftMirrored:
                // 0th row is on the left, and 0th column is the top - Rotate -90 degrees and Flip Vertical
                transform	= CGAffineTransformMake(0.0, -1.0, -1.0, 0.0, height, width)
                
            case .RightMirrored:
                // 0th row is on the right, and 0th column is the bottom - Rotate 90 degrees and Flip Vertical
                transform	= CGAffineTransformMake(0.0, 1.0, 1.0, 0.0, 0.0, 0.0)
                
            default:
                transform = CGAffineTransformIdentity
            }
            
            return transform
        }
        
        let imageRef = image.CGImage
        let width = Int(round(CGFloat(CGImageGetWidth(imageRef)) * scale))
        let height = Int(round(CGFloat(CGImageGetHeight(imageRef)) * scale))
        
        var imageContext: CGContextRef?
        let orientation = image.imageOrientation
        switch orientation {
        case .Up:
            imageContext = createCGBitmapContext(width: width, height: height)
            
        case .Down:
            imageContext = createCGBitmapContext(width: width, height: height)
            
        case .UpMirrored:
            imageContext = createCGBitmapContext(width: width, height: height)
            
        case .DownMirrored:
            imageContext = createCGBitmapContext(width: width, height: height)
            
        default:
            // other orientations are rotated ±90 degrees, so they swap width & height
            imageContext = createCGBitmapContext(width: height, height: width)
        }
        
        if let imageContext = imageContext {
            
            CGContextSetBlendMode(imageContext, CGBlendMode.Copy)
            let transform = transformForOrientation(orientation, width: CGFloat(width), height: CGFloat(height))
            CGContextConcatCTM(imageContext, transform)
            
            CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
            return CGBitmapContextCreateImage(imageContext)
        }
        
        return nil
    }
    
    
    func maskToPath(path: UIBezierPath) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0);
        path.addClip()
        drawAtPoint(CGPointZero)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        return maskedImage
    }
}

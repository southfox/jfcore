//
//  UIImage+JFCore.swift
//  Pods
//
//  Created by Javier Fuchs on 9/26/16.
//
//

import Foundation
#if os(macOS)
import Cocoa
public typealias UIImage = NSImage
#else
import UIKit
#endif

extension UIImage {

    public func resized(to: CGSize) -> UIImage? {
#if os(macOS)
        let img = NSImage(size: to)
        img.lockFocus()
        defer {
            img.unlockFocus()
        }
        if let ctx = NSGraphicsContext.current {
            ctx.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: to),
                 from: NSRect(origin: .zero, size: size),
                 operation: .copy,
                 fraction: 1)
        }
#else
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
#endif
        return img
    }

#if !os(macOS)
    public func patternColor(customSize: CGSize) -> UIColor
    {
        var size = customSize
        let hw = max(size.width, size.height)
        size.width = hw
        size.height = hw
        if let bg = resized(to: size) {
            let pattern = UIColor.init(patternImage: bg)
            return pattern
        }
        return UIColor.black
    }
    public func convertToGrayScale() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = self.size.width
        let height = self.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(self.cgImage!, in: rect)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    public func convertColor(color: UIColor) -> UIImage {
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.size.width, height: self.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        let c:CGContext = UIGraphicsGetCurrentContext()!
        self.draw(in: rect)
        c.setFillColor(color.cgColor)
        c.setBlendMode(.sourceAtop)
        c.fill(rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    public func mergeImages(topImage: UIImage) -> UIImage {
        let bottomImage = self
        
        let size = CGSize(width: topImage.size.width, height: topImage.size.height + bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        topImage.draw(in: CGRect(x: 0,y: 0, width: size.width, height: topImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: topImage.size.height, width: size.width, height: bottomImage.size.height))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        return newImage
    }

#if !os(watchOS)
    public func combineImages(topImage: UIImage) -> UIImage? {
        let ci = CIImage(image: self)
        let topImage = CIImage(image: topImage)
        let compositeFilter = CIFilter(name: "CIOverlayBlendMode")!

        compositeFilter.setValue(ci,
                                 forKey: kCIInputImageKey)
        compositeFilter.setValue(topImage,
                                 forKey: kCIInputBackgroundImageKey)
        
        if let compositeImage = compositeFilter.outputImage{
            let image = UIImage(ciImage: compositeImage)
            return image
        }
        return nil
    }
#endif
#endif

}

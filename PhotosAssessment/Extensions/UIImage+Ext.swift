//
//  UIImage+Ext.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 4.10.22.
//

import UIKit

extension UIImage {
    func cropImage(toRect rect: CGRect) -> UIImage? {
        guard let imageRef = cgImage?.cropping(to: rect) else {
            return nil
        }
        let cropped: UIImage = UIImage(cgImage: imageRef)
        return cropped
    }
    
    func cropTo(view: UIView) -> UIImage? {
        let viewRect: CGRect = view.bounds
        
        let imageSize: CGSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let viewRatio: CGFloat = viewRect.width / viewRect.height
        let imageRatio: CGFloat = imageSize.width / imageSize.height
        
        var newRect: CGRect = .zero
        
        // calculate the rect that needs to be clipped from the full image
        if viewRatio > imageRatio {
            // image has a wider aspect ratio than the image view
            //  so top and bottom will be clipped
            let f: CGFloat = imageSize.width / viewRect.width
            let h: CGFloat = viewRect.height * f
            newRect.origin.y = (imageSize.height - h) * 0.5
            newRect.size.width = imageSize.width
            newRect.size.height = h
        } else {
            // image has a narrower aspect ratio than the image view
            //  so left and right will be clipped
            let f: CGFloat = imageSize.height / viewRect.height
            let w: CGFloat = viewRect.width * f
            newRect.origin.x = (imageSize.width - w) * 0.5
            newRect.size.width = w
            newRect.size.height = imageSize.height
        }
        
        return cropImage(toRect: newRect)
    }
}

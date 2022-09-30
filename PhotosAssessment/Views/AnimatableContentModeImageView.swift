//
//  AnimatableContentModeImageView.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit

class AnimatableContentModeImageView: UIView {
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            layoutImageView()
        }
    }

    private let imageView: UIImageView
    
    init(image: UIImage? = nil) {
        imageView = UIImageView(image: image)
        super.init(frame: .zero)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(image: nil)
        super.init(coder: aDecoder)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageView()
    }
    
    override var contentMode: UIView.ContentMode {
        didSet { layoutImageView() }
    }
    
    private func layoutImageView() {
        
        guard let image = imageView.image else { return }
        
        // MARK: - Layout Helpers
        
        func imageToBoundsWidthRatio(image: UIImage) -> CGFloat {
            image.size.width / bounds.size.width
        }
        
        func imageToBoundsHeightRatio(image: UIImage) -> CGFloat {
            image.size.height / bounds.size.height
        }
        
        func centerImageViewToPoint(point: CGPoint) {
            imageView.center = point
        }
        
        func imageViewBoundsToImageSize() {
            imageViewBoundsToSize(size: image.size)
        }
        
        func imageViewBoundsToSize(size: CGSize) {
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        func centerImageView() {
            imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        }
        
        // MARK: - Layouts
        
        func layoutAspectFit() {
            let widthRatio = imageToBoundsWidthRatio(image: image)
            let heightRatio = imageToBoundsHeightRatio(image: image)
            imageViewBoundsToSize(size: CGSize(width: image.size.width / max(widthRatio, heightRatio), height: image.size.height / max(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutAspectFill() {
            let widthRatio = imageToBoundsWidthRatio(image: image)
            let heightRatio = imageToBoundsHeightRatio(image: image)
            imageViewBoundsToSize(size: CGSize(width: image.size.width /  min(widthRatio, heightRatio), height: image.size.height / min(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutFill() {
            imageViewBoundsToSize(size: CGSize(width: bounds.size.width, height: bounds.size.height))
        }
        
        func layoutCenter() {
            imageViewBoundsToImageSize()
            centerImageView()
        }
        
        func layoutTop() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottom() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutTopLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutTopRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottomLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutBottomRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        switch contentMode {
        case .scaleAspectFit:  layoutAspectFit()
        case .scaleAspectFill: layoutAspectFill()
        case .scaleToFill:     layoutFill()
        case .redraw:          break;
        case .center:          layoutCenter()
        case .top:             layoutTop()
        case .bottom:          layoutBottom()
        case .left:            layoutLeft()
        case .right:           layoutRight()
        case .topLeft:         layoutTopLeft()
        case .topRight:        layoutTopRight()
        case .bottomLeft:      layoutBottomLeft()
        case .bottomRight:     layoutBottomRight()
        @unknown default:
            layoutAspectFit()
        }
    }
}

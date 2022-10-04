//
//  SaliencyService.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit
import Vision

enum SaliencyServiceError: Error {
    case imageConverting
    case requestPerform
    case noSaliencyResults
}

protocol SaliencyServiceProtocol: AnyObject {
    func getSaliencyRectangle(
        for image: UIImage,
        saliencyType: SaliencyType
    ) throws -> CGRect?
}

final class SaliencyService: SaliencyServiceProtocol {
    func getSaliencyRectangle(
        for image: UIImage,
        saliencyType: SaliencyType
    ) throws -> CGRect?  {
        guard let cgImage = image.cgImage else {
            throw SaliencyServiceError.imageConverting
        }
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: mapOrientation(image.imageOrientation)
        )
        
        let request: VNImageBasedRequest
                
        switch saliencyType {
        case .attentionBased:
            request = VNGenerateAttentionBasedSaliencyImageRequest()
        }
        
        request.usesCPUOnly = true
        
        // TODO: The region of the image in which the request will be performed
//        request.regionOfInterest = CGRect(x: 0.1, y: 0, width: 0.8, height: 1)
        
        do {
            try handler.perform([request])
        } catch {
            throw SaliencyServiceError.requestPerform
        }
        
        guard
            let results = request.results as? [VNSaliencyImageObservation],
            let result = results.first,
            let salientObjects = result.salientObjects,
            let object = salientObjects.first
        else {
            throw SaliencyServiceError.noSaliencyResults
        }
        
        let imageSize = CGSize(
            width: image.size.width,
            height: image.size.height
        )
        
        let boundingBox = object.boundingBox

        let origin = CGPoint(
            x: boundingBox.origin.x * imageSize.width,
            y: imageSize.height - boundingBox.origin.y * imageSize.height
        )
        let size = CGSize(
            width: boundingBox.width * imageSize.width,
            height: -(boundingBox.height * imageSize.height)
        )

        let salientRect = CGRect(
            origin: origin,
            size: size
        )
        
        return salientRect
    }
    
    private func mapOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}

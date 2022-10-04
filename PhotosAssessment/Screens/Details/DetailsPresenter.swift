//
//  DetailsPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit
import Photos

protocol DetailsPresenterProtocol {
    var assetID: PHAssetLocalIdentifier? { get }
    var delegate: DetailsPresenterDelegate? { get set }
    
    func viewIsReady()
    func drawSaliencyRectangle(for image: UIImage?)
}

protocol DetailsPresenterDelegate: AnyObject {
    @MainActor func setupInitialState(image: UIImage?)
    @MainActor func drawRectangle(_ rect: CGRect)
}

class DetailsPresenter: DetailsPresenterProtocol {
    private var photosService: PhotosServiceProtocol
    private var saliencyService: SaliencyServiceProtocol
    
    init(
        photosService: PhotosServiceProtocol,
        saliencyService: SaliencyServiceProtocol
    ) {
        self.photosService = photosService
        self.saliencyService = saliencyService
    }
    
    private enum ImageQuality {
        case low
        case full
    }
    
    weak var delegate: DetailsPresenterDelegate?
    
    var assetID: PHAssetLocalIdentifier?
    
    func viewIsReady() {
        loadImage()
    }
    
    func drawSaliencyRectangle(for image: UIImage?) {
        guard let image = image else { return }
        
        Task.detached(priority: .userInitiated) {
            if let rect = try? self.saliencyService.getSaliencyRectangle(
                for: image,
                saliencyType: .attentionBased
            ) {
                await self.delegate?.drawRectangle(rect)
            }
        }
    }
        
    private func loadImage() {
        guard let assetID = assetID else { return }

        Task {
            let lowQualityImage = await loadImage(assetID: assetID, imageQuality: .low)
            await delegate?.setupInitialState(image: lowQualityImage)
            
            let fullQualityImage = await loadImage(assetID: assetID, imageQuality: .full)
            await delegate?.setupInitialState(image: fullQualityImage)
            
            drawSaliencyRectangle(for: fullQualityImage)
        }
    }
    
    private func loadImage(assetID: PHAssetLocalIdentifier, imageQuality: ImageQuality) async -> UIImage? {
        let lowQualityTargetSize = CGSize(width: 200, height: 200)
        let targetSize = imageQuality == .full ? PHImageManagerMaximumSize : lowQualityTargetSize
        
        let image = try? await photosService.fetchImage(
            byLocalIdentifier: assetID,
            targetSize: targetSize,
            contentMode: .aspectFit
        )
        
        return image
    }
}

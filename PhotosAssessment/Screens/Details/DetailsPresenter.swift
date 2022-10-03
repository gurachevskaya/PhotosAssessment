//
//  DetailsPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit
import Photos

protocol DetailsPresenterProtocol {
    var asset: PhotoAsset? { get }
    var delegate: DetailsPresenterDelegate? { get set }
    
    func viewIsReady()
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
    
    weak var delegate: DetailsPresenterDelegate?
    
    var asset: PhotoAsset?
    
    func viewIsReady() {
        loadImage()
    }
        
    private func loadImage() {
        guard let asset = asset else { return }

        Task {
            let image = try? await photosService.fetchImage(
                byLocalIdentifier: asset.name,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit
            )
            await delegate?.setupInitialState(image: image)
            
            drawSaliencyRectangle(for: image)
        }
    }
    
    private func drawSaliencyRectangle(for image: UIImage?) {
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
}

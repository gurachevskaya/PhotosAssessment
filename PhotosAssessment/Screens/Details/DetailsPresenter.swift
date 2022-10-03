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
        guard let asset = asset else { return }
        
        Task {
            let image = try? await photosService.fetchImage(
                byLocalIdentifier: asset.name,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit)
            await delegate?.setupInitialState(image: image)
            
            do {
                if let rect = try saliencyService.getSaliencyRectangle(for: image ?? UIImage(), saliencyType: .attentionBased) {
                    await delegate?.drawRectangle(rect)
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    func drawSaliencyRectangle() {
        
    }
}

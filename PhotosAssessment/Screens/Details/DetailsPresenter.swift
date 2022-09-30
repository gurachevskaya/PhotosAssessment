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
    func setupInitialState(image: UIImage?)
}

class DetailsPresenter: DetailsPresenterProtocol {
    private var photosService: PhotosServiceProtocol

    init(photosService: PhotosServiceProtocol) {
        self.photosService = photosService
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
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.setupInitialState(image: image)
            }
        }
    }
}

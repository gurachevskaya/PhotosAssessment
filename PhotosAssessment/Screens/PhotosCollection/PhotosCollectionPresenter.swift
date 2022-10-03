//
//  PhotosCollectionPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import Photos

protocol PhotosCollectionPresenterProtocol {
    var model: [PhotoAsset]? { get }
    var delegate: PhotosCollectionPresenterDelegate? { get set }
    var dataSource: UICollectionViewDiffableDataSource<PhotosCollectionSection, PhotoAsset>! { get set }
    
    func viewIsReady()
    func fetchImage(id: PHAssetLocalIdentifier) async throws -> UIImage?
    func startCachingAssets(indexPaths: [IndexPath])
    func obtainDetailsViewController(asset: PhotoAsset) -> UIViewController
}

protocol PhotosCollectionPresenterDelegate: AnyObject {
    @MainActor func didLoadPhotos()
    @MainActor func didFailWithError(_ error: String)
}

class PhotosCollectionPresenter: PhotosCollectionPresenterProtocol {
    
    private var photosService: PhotosServiceProtocol
    
    init(photosService: PhotosServiceProtocol) {
        self.photosService = photosService
    }
    
    weak var delegate: PhotosCollectionPresenterDelegate?
    
    var model: [PhotoAsset]?
    
    var dataSource: UICollectionViewDiffableDataSource<PhotosCollectionSection, PhotoAsset>!
    var snapshot = NSDiffableDataSourceSnapshot<PhotosCollectionSection, PhotoAsset>()
    
    func viewIsReady() {
        photosService.delegate = self
        loadPhotos()
    }
    
    func startCachingAssets(indexPaths: [IndexPath]) {
        guard let model = model else { return }
        let assets = model.map { $0.asset }
        photosService.startCachingAssets(assets: assets)
    }
    
    func fetchImage(id: PHAssetLocalIdentifier) async throws -> UIImage? {
        try await photosService.fetchImage(
            byLocalIdentifier: id,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill
        )
    }
    
    func obtainDetailsViewController(asset: PhotoAsset) -> UIViewController {
        let destinationController = DetailsViewController()
        let destinationPresenter = DetailsPresenter(photosService: PhotosService(
            imageCachingManager: PHCachingImageManager()
        ), saliencyService: SaliencyService())
        destinationController.presenter = destinationPresenter
        destinationPresenter.asset = asset
        destinationPresenter.delegate = destinationController
        
        return destinationController
    }
    
    private func loadPhotos() {
        Task {
            do {
                let photos = try await photosService.fetchPhotos()
                let mapped = photos?.map { PhotoAsset(asset: $0, name: $0.localIdentifier) }
                guard let mapped = mapped else { return }
                await updateData(on: mapped)
            } catch let error as PhotosServiceError {
                await delegate?.didFailWithError(error.errorDescription)
            }
        }
    }

    @MainActor
    private func updateData(on model: [PhotoAsset]) {
        self.model = model
        var snapshot = NSDiffableDataSourceSnapshot<PhotosCollectionSection, PhotoAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - PhotosServiceDelegate

extension PhotosCollectionPresenter: PhotosServiceDelegate {
    func photoLibraryDidChange(results: PHFetchResultCollection) {
        let mapped = results.map { PhotoAsset(asset: $0, name: $0.localIdentifier) }
        DispatchQueue.main.async { [weak self] in
            self?.updateData(on: mapped)
        }
    }
}

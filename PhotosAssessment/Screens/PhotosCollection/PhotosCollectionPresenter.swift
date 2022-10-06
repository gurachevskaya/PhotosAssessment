//
//  PhotosCollectionPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import Photos

protocol PhotosCollectionPresenterProtocol {
    var model: PHFetchResult<PHAsset>? { get }
    var delegate: PhotosCollectionPresenterDelegate? { get set }
    var dataSource: UICollectionViewDiffableDataSource<PhotosCollectionSection, PHAsset>! { get set }
    
    func viewIsReady()
    func fetchImage(id: PHAssetLocalIdentifier) async throws -> UIImage?
    func startCachingAssets(indexPaths: [IndexPath])
    func obtainDetailsViewController(asset: PHAsset) -> UIViewController
}

protocol PhotosCollectionPresenterDelegate: AnyObject {
    @MainActor func didFailWithError(_ error: String)
}

class PhotosCollectionPresenter: PhotosCollectionPresenterProtocol {
    
    private var photosService: PhotosServiceProtocol
    
    init(
        photosService: PhotosServiceProtocol
    ) {
        self.photosService = photosService
    }
    
    weak var delegate: PhotosCollectionPresenterDelegate?
    
    var model: PHFetchResult<PHAsset>?
    
    var dataSource: UICollectionViewDiffableDataSource<PhotosCollectionSection, PHAsset>!
    var snapshot = NSDiffableDataSourceSnapshot<PhotosCollectionSection, PHAsset>()
    
    func viewIsReady() {
        loadPhotos()
        observeLibraryEvents()
    }

    func startCachingAssets(indexPaths: [IndexPath]) {
        guard let model = model else { return }
        let assets = indexPaths.map { indexPath in
            model[indexPath.item]
        }
        photosService.startCachingAssets(assets: assets)
    }
    
    func fetchImage(id: PHAssetLocalIdentifier) async throws -> UIImage? {
        try await photosService.fetchImage(
            byLocalIdentifier: id,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill
        )
    }
    
    func obtainDetailsViewController(asset: PHAsset) -> UIViewController {
        let destinationController = DetailsViewController()
        guard
            let photosService = DIContainer.shared.resolve(type: PhotosServiceProtocol.self),
            let saliencyService = DIContainer.shared.resolve(type: SaliencyServiceProtocol.self)
        else {
            fatalError("Failed to resolve services")
        }
        let destinationPresenter = DetailsPresenter(
            photosService: photosService,
            saliencyService: saliencyService
        )
        destinationController.presenter = destinationPresenter
        destinationPresenter.assetID = asset.localIdentifier
        destinationPresenter.delegate = destinationController
        
        return destinationController
    }
    
    private func observeLibraryEvents() {
        Task {
            for await assets in photosService.libraryEvents() {
                await updateData(on: assets)
            }
        }
    }
    
    private func loadPhotos() {
        Task {
            do {
                guard let photos = try await photosService.fetchPhotos() else {
                    return
                }
                await updateData(on: photos)
            } catch let error as PhotosServiceError {
                await delegate?.didFailWithError(error.errorDescription)
            }
        }
    }

    @MainActor
    private func updateData(on model: PHFetchResult<PHAsset>) {
        self.model = model
        var snapshot = NSDiffableDataSourceSnapshot<PhotosCollectionSection, PHAsset>()
        snapshot.appendSections([.main])
        
        var assets: [PHAsset] = []
        model.enumerateObjects { (collection, _, _) in
            assets.append(collection)
        }
        
        snapshot.appendItems(assets)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

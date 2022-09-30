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
}

protocol PhotosCollectionPresenterDelegate: AnyObject {
    func didLoadPhotos()
    func didFailWithError(_ error: String)
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
    
    private func loadPhotos() {
        Task {
            do {
                let photos = try await photosService.requestAuthorization()
                let mapped = photos?.map { PhotoAsset(name: $0.localIdentifier) }
                guard let mapped = mapped else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.updateData(on: mapped)
                }
            } catch let error as PhotosServiceError {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let mappedError = self.mapError(error: error)
                    self.delegate?.didFailWithError(mappedError)
                }
            }
        }
    }
    
    func startCachingAssets(indexPaths: [IndexPath]) {
        photosService.startCachingAssets(indexPaths: indexPaths)
    }
    
    func fetchImage(id: PHAssetLocalIdentifier) async throws -> UIImage? {
        try await photosService.fetchImage(
            byLocalIdentifier: id,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill
        )
    }
    
    private func mapError(error: PhotosServiceError) -> String {
        switch error {
        case .restrictedAccess:
            return "Access restricted"
        case .phAssetNotFound:
            return "Asset not found"
        }
    }
        
    private func updateData(on model: [PhotoAsset]) {
        var snapshot = NSDiffableDataSourceSnapshot<PhotosCollectionSection, PhotoAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PhotosCollectionPresenter: PhotosServiceDelegate {
    func photoLibraryDidChange(results: PHFetchResultCollection) {
        let mapped = results.map { PhotoAsset(name: $0.localIdentifier) }
        DispatchQueue.main.async { [weak self] in
            self?.updateData(on: mapped)
        }
    }
}

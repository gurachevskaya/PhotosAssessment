//
//  PhotosService.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 29.09.22.
//

import UIKit
import Photos

enum PhotosServiceError: LocalizedError {
    case restrictedAccess
    case phAssetNotFound
    
    var errorDescription: String {
        switch self {
        case .restrictedAccess:
            return "Access restricted"
        case .phAssetNotFound:
            return "Asset not found"
        }
    }
}

protocol PhotosServiceProtocol: AnyObject {
    var delegate: PhotosServiceDelegate? { get set }
    
    func fetchPhotos() async throws -> PHFetchResultCollection?
    
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize,
        contentMode: PHImageContentMode
    ) async throws -> UIImage?
    
    func startCachingAssets(assets: [PHAsset])
}

protocol PhotosServiceDelegate: AnyObject {
    func photoLibraryDidChange(results: PHFetchResultCollection)
}

typealias PHAssetLocalIdentifier = String

final class PhotosService: NSObject, PhotosServiceProtocol {
    
    private var imageCachingManager: PHCachingImageManager
    
    init(imageCachingManager: PHCachingImageManager) {
        self.imageCachingManager = imageCachingManager
        super.init()
        
        registerObserver()
    }
    
    weak var delegate: PhotosServiceDelegate?
    
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var results = PHFetchResultCollection(fetchResult: .init())
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func registerObserver() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func fetchPhotos() async throws -> PHFetchResultCollection? {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.authorizationStatus = status
                switch status {
                case .authorized, .limited:
                    if let results = self?.fetchAllPhotos() {
                        continuation.resume(returning: results)
                    }
                    
                case .denied, .notDetermined, .restricted:
                    continuation.resume(throwing: PhotosServiceError.restrictedAccess)
                    
                @unknown default:
                    break
                }
            }
        }
    }
   
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize,
        contentMode: PHImageContentMode
    ) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(
            withLocalIdentifiers: [localId],
            options: nil
        )
        guard let asset = results.firstObject else {
            throw PhotosServiceError.phAssetNotFound
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options,
                resultHandler: { image, info in
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
    
    func startCachingAssets(assets: [PHAsset]) {
        imageCachingManager.startCachingImages(
            for: assets,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: nil
        )
    }
    
    func resetCachedAssets() {
        imageCachingManager.stopCachingImagesForAllAssets()
    }
    
    private func fetchAllPhotos() -> PHFetchResultCollection {
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: Constants.Keys.creationDate, ascending: false)
        ]
        fetchOptions.fetchLimit = Constants.maxNumberOfPhotos
        
        results.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        return results
    }
}

extension PhotosService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let change = changeInstance.changeDetails(for: results.fetchResult) {
            results.fetchResult = change.fetchResultAfterChanges
            delegate?.photoLibraryDidChange(results: results)
        }
    }
}

//
//  PhotosService.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 29.09.22.
//

import UIKit
import Photos

enum PhotosServiceError: Error {
    case restrictedAccess
    case phAssetNotFound
}

protocol PhotosServiceProtocol: AnyObject {
    var delegate: PhotosServiceDelegate? { get set }
    
    func requestAuthorization() async throws -> PHFetchResultCollection?
    
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize,
        contentMode: PHImageContentMode
    ) async throws -> UIImage?
    
    func startCachingAssets(indexPaths: [IndexPath])
}

protocol PhotosServiceDelegate: AnyObject {
    func photoLibraryDidChange(results: PHFetchResultCollection)
}

typealias PHAssetLocalIdentifier = String

class PhotosService: NSObject, PhotosServiceProtocol {
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
    
    func requestAuthorization() async throws -> PHFetchResultCollection? {
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
    
    private func fetchAllPhotos() -> PHFetchResultCollection {
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        results.fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        return results
    }
    
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default
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
        options.resizeMode = .fast
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
    
    func startCachingAssets(indexPaths: [IndexPath]) {
        var assets: [PHAsset] = []
        for indexPath in indexPaths {
            let asset = results.fetchResult[indexPath.item]
            assets.append(asset)
        }
        
        imageCachingManager.startCachingImages(for: assets, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil)
    }
    
    func resetCachedAssets() {
        imageCachingManager.stopCachingImagesForAllAssets()
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

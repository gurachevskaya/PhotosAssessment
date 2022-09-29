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
    func requestAuthorization() async throws -> PHFetchResultCollection?
    
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize,
        contentMode: PHImageContentMode
    ) async throws -> UIImage?
}

typealias PHAssetLocalIdentifier = String

class PhotosService: NSObject, PhotosServiceProtocol {
    private var imageCachingManager: PHCachingImageManager
    
    init(imageCachingManager: PHCachingImageManager) {
        self.imageCachingManager = imageCachingManager
        super.init()
        
        registerObserver()
    }
    
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
            NSSortDescriptor(key: "creationDate", ascending: false)
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
    
    func resetCachedAssets() {
        imageCachingManager.stopCachingImagesForAllAssets()
    }
}

extension PhotosService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photo library did change")
    }
}

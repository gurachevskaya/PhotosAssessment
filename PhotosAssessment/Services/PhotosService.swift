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
            return NSLocalizedString("ERROR_ACCESS_RESTRICTED", comment: "")
        case .phAssetNotFound:
            return NSLocalizedString("ERROR_ASSET_NOT_FOUND", comment: "")
        }
    }
}

protocol PhotosServiceProtocol: AnyObject {
    var delegate: PhotosServiceDelegate? { get set }
    
    func fetchPhotos() async throws -> PHFetchResult<PHAsset>?
    
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize,
        contentMode: PHImageContentMode
    ) async throws -> UIImage?
    
    func startCachingAssets(assets: [PHAsset])
}

protocol PhotosServiceDelegate: AnyObject {
    func photoLibraryDidChange(results: PHFetchResult<PHAsset>)
}

typealias PHAssetLocalIdentifier = String

final class PhotosService: NSObject, PhotosServiceProtocol {
    
    private var imageCachingManager: PHCachingImageManager
    private let eventsActionHandler: EventsActionHandler

    init(imageCachingManager: PHCachingImageManager, eventsActionHandler: EventsActionHandler) {
        self.imageCachingManager = imageCachingManager
        self.eventsActionHandler = eventsActionHandler
        super.init()
        
        registerObserver()
    }
    
    weak var delegate: PhotosServiceDelegate?
    
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var results = PHFetchResult<PHAsset>()
    
//    var task: Task<((), Error>?
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func registerObserver() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func fetchPhotos() async throws -> PHFetchResult<PHAsset>? {
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
    
    private func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        imageCachingManager.allowsCachingHighQualityImages = false
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: Constants.Keys.creationDate, ascending: false)
        ]
        fetchOptions.fetchLimit = Constants.maxNumberOfPhotos
                
        results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
        return results
    }
}

extension PhotosService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let change = changeInstance.changeDetails(for: results) {
            results = change.fetchResultAfterChanges
            eventsActionHandler.actionChangeGallery(results: results)
        }
    }
}

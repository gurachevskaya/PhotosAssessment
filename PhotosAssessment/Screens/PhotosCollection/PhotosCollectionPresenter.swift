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
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoAsset>! { get set }
    
    func viewIsReady()
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
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoAsset>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoAsset>()
    
    func viewIsReady() {
        loadPhotos()
    }
    
    private func loadPhotos() {
        Task {
            do {
                let photos = try await photosService.requestAuthorization()
                let mapped = photos?.map {
                    PhotoAsset(name: $0.localIdentifier)
                }
                if let mapped = mapped {
                    updateData(on: mapped)
                }
            } catch let error {
                print(error)
            }
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            self?.delegate?.didLoadPhotos()
//            self?.updateData(on: MockData.photosModel)
//        }
    }
    
    private func updateData(on model: [PhotoAsset]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

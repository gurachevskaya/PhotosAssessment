//
//  PhotosCollectionPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit

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
    
    init() {
    }
    
    weak var delegate: PhotosCollectionPresenterDelegate?
        
    var model: [PhotoAsset]?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoAsset>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoAsset>()
    
    func viewIsReady() {
        loadPhotos()
    }
    
    private func loadPhotos() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.delegate?.didLoadPhotos()
            self?.updateData(on: MockData.photosModel)
        }
    }
    
    private func updateData(on model: [PhotoAsset]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoAsset>()
        snapshot.appendSections([.main])
        snapshot.appendItems(model)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

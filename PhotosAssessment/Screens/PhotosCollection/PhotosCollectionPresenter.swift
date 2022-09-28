//
//  PhotosCollectionPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import Combine
import UIKit

protocol PhotosCollectionViewModelProtocol {
    var model: [PhotoAsset]? { get }
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoAsset>! { get set }
    
    func loadPhotos()
}

class PhotosCollectionViewModel: PhotosCollectionViewModelProtocol {
    
    init() {
    }
        
    var model: [PhotoAsset]?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoAsset>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoAsset>()
    
    private var cancellables: Set<AnyCancellable> = []

    func loadPhotos() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
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

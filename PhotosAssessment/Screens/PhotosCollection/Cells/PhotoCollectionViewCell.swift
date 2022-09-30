//
//  PhotoCollectionViewCell.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    static let reuseID = "PhotoCollectionViewCell"
    
    struct ViewModel {
        let image: UIImage?
    }

    private var cellModel: ViewModel = ViewModel(image: nil)
    private let imageView = UIImageView()
        
    var onReuse: () -> Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        onReuse()
    }

    func setupWith(cellModel: ViewModel) {
        self.cellModel = cellModel
        updateUI()
    }

    private func updateUI() {
        imageView.image = cellModel.image
    }

    private func setupUI() {
        setupBackground()
        addImageView()
    }
    
    private func setupBackground() {
        contentView.backgroundColor = .systemGray5
    }

    private func addImageView() {
        contentView.addSubview(imageView)
        imageView.prepareForAutoLayout()
        imageView.pinEdgesTo(view: contentView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
       
    }
}

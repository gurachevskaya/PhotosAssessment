//
//  PhotoCollectionViewCell.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import SnapKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    static let reuseID = "PhotoCollectionViewCell"

    struct ViewModel {
        let image: UIImage
        let title: String
    }

    private var cellModel: ViewModel = ViewModel(image: .init(), title: "")
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWith(cellModel: ViewModel) {
        self.cellModel = cellModel
        updateUI()
    }

    private func updateUI() {
        imageView.image = cellModel.image
        titleLabel.text = cellModel.title
    }

    private func setupUI() {
        setupBackground()
        addImageView()
        addTitle()
    }
    
    private func setupBackground() {
        contentView.backgroundColor = .systemGray5
    }

    private func addImageView() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addTitle() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}

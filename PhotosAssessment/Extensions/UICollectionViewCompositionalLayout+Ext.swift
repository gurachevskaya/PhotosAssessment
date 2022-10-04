//
//  FourColumnsLayout.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 4.10.22.
//

import UIKit

extension UICollectionViewLayout {
    static func createSquaredLayout(
        numberOfColumns: Int,
        spacing: CGFloat
    ) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1 / CGFloat(numberOfColumns))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: numberOfColumns
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

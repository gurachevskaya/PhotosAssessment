//
//  Constants.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 3.10.22.
//

import UIKit

enum SFSymbols {
    static let magnifyingGlass = UIImage(systemName: "arrow.up.left.and.down.right.magnifyingglass")
}

enum Constants {
    static let maxNumberOfPhotos = 1_000
    
    enum Keys {
        static let creationDate = "creationDate"
    }
    
}

enum AnimationDuration {
    case shortDuration
    case mediumDuration
    case longDuration
    
    var seconds: CGFloat {
        switch self {
        case .shortDuration:
            return 0.2
        case .mediumDuration:
            return 0.6
        case .longDuration:
            return 1.0
        }
    }
}

//
//  UIView+Ext.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit

extension UIView {
    func prepareForAutoLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func pinEdgesTo(view: UIView, padding: CGFloat = 0) {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
    }
}

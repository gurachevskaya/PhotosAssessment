//
//  UIViewController+Ext.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 29.09.22.
//

import UIKit

extension UIViewController {
    @MainActor func showAlert(text: String) {
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
}

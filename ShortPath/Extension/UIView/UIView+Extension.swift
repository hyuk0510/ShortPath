//
//  UIView+Extension.swift
//  ShortPath
//
//  Created by 선상혁 on 12/7/25.
//

import UIKit

extension UIView {
    func asImage() -> UIImage {
        UIGraphicsImageRenderer(bounds: self.bounds).image {
            self.layer.render(in: $0.cgContext)
        }
    }
    
    func setShadow() {
        layer.shadowOpacity = 0.15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
    }
}


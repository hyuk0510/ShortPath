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
    
    func setShadow(_ offsetY: Double = 2.0) {
        layer.shadowOpacity = 0.15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: offsetY)
        layer.shadowRadius = 3
    }
}


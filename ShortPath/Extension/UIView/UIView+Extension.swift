//
//  UIView+Extension.swift
//  ShortPath
//
//  Created by 선상혁 on 12/7/25.
//

import UIKit
import Toast

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
    
    func showToast(
        _ message: String,
        duration: TimeInterval = 1.2,
        bottomOffset: CGFloat = 120
    ) {
        let label = PaddingLabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(bottomOffset)
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
        }
        
        UIView.animate(withDuration: 0.25) {
            label.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.25, animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
    
    func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }
}


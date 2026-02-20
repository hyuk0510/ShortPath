//
//  CustomClearButton.swift
//  ShortPath
//
//  Created by 선상혁 on 2/13/26.
//

import UIKit

final class CustomClearButton: UIButton {
    
    var isTouched: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        self.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        self.contentMode = .scaleAspectFit
        self.tintColor = .gray
        self.backgroundColor = .white
        self.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    @objc
    func buttonTouched(_ sender: UIButton) {
        isTouched?()
    }
}

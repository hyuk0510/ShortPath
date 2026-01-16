//
//  CustomLeftViewContainer.swift
//  ShortPath
//
//  Created by 선상혁 on 1/16/26.
//

import UIKit

final class CustomLeftViewContainer: UIView {
    
    private let customLeftView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "magnifyingglass")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
//        view.backgroundColor = .brown
        return view
    }()
    
    let padding: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(customLeftView)
        frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        customLeftView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(padding)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
}

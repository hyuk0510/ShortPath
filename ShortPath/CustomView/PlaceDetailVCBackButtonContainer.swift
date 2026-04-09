//
//  PlaceDeatilVCBackButton.swift
//  ShortPath
//
//  Created by 선상혁 on 4/5/26.
//

import UIKit

final class PlaceDetailVCBackButtonContainer: UIView {
    
    var backButton: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "chevron.backward")
        config.baseForegroundColor = .black
        
        view.configuration = config
        
        return view
    }()
    
    var onTapBackButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 22
        
        addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        backButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(44)
        }
    }
    
    @objc
    private func backButtonPressed() {
        onTapBackButton?()
    }
}

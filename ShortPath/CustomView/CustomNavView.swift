//
//  CustomNavView.swift
//  ShortPath
//
//  Created by 선상혁 on 1/12/26.
//

import UIKit

final class CustomNavView: UIView {
    
    let backButton = UIButton(type: .system)
    let textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width - 16, height: 44)
    }
    
    private func configure() {
        backButton.tintColor = .black
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        
        textField.placeholder = "장소 ･ 주소 검색"
        textField.tintColor = .systemBlue
        textField.textColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [backButton, textField])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.backgroundColor = .white
        stackView.layer.borderColor = UIColor.black.cgColor
        stackView.layer.borderWidth = 1
        stackView.layer.cornerRadius = 15
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }
    }
}

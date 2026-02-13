//
//  CustomNavView.swift
//  ShortPath
//
//  Created by 선상혁 on 1/12/26.
//

import UIKit

final class CustomNavView: UIView {
    
    let backButton = UIButton(type: .system)
    let searchTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: 48)
    }
    
    private func configure() {
        backButton.tintColor = .black
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "장소 ･ 주소 검색", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        searchTextField.tintColor = .systemBlue
        searchTextField.textColor = .black
        searchTextField.delegate = self
        
        let stackView = UIStackView(arrangedSubviews: [backButton, searchTextField])
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.backgroundColor = .white
        stackView.layer.borderColor = UIColor.black.cgColor
        stackView.layer.borderWidth = 1
        stackView.layer.cornerRadius = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
    }
}

extension CustomNavView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

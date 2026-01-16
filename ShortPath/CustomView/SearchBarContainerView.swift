//
//  SearchBarContainerView.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit

final class SearchBarContainerView: UIView {
    
    private let searchBar = {
        let view = UISearchBar()
        view.backgroundColor = .white
        view.barTintColor = .black
        view.searchBarStyle = .minimal
        view.searchTextField.attributedPlaceholder = NSAttributedString(string: "장소 ･ 주소 검색", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        view.searchTextField.leftView?.tintColor = .black
        view.searchTextField.borderStyle = .none
        return view
    }()
    
    var onTap: (() -> Void)?
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width - 16, height: 44)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(searchBar)
        
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 12
        
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        
        searchBar.isUserInteractionEnabled = false
    }
    
    @objc
    private func didTap() {
        onTap?()
    }
}

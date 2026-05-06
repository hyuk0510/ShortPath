//
//  RecentPlaceHeaderView.swift
//  ShortPath
//
//  Created by 선상혁 on 4/15/26.
//

import UIKit

final class RecentPlaceHeaderView: UIView {
    
    private let headerLabel: UILabel = {
        let view = UILabel()
        
        view.text = "최근 검색 장소"
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        return view
    }()
    
    private let pushSearchVCButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        view.tintColor = .gray
        
        return view
    }()
    
    var onTapSearchVCButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: .zero, left: .zero, bottom: 8, right: .zero)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        addSubview(stackView)
        
        [headerLabel, makeSpacer(), pushSearchVCButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        pushSearchVCButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pushSearchVCButton.addTarget(self, action: #selector(pushSearchVCButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func pushSearchVCButtonPressed() {
        onTapSearchVCButton?()
    }
}

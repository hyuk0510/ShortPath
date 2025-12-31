//
//  CustomTabBar.swift
//  ShortPath
//
//  Created by 선상혁 on 12/29/25.
//

import UIKit

final class CustomTabBar: UIView {
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.alignment = .center
        view.backgroundColor = .white
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return view
    }()
    
    private let homeButton = CustomTabButton(systemName: "pencil.circle", title: "홈", selectedImage: "pencil.circle.fill")
    private let favoriteButton = CustomTabButton(systemName: "star", title: "즐겨찾기", selectedImage: "star.fill")
    private let settingButton = CustomTabButton(systemName: "square.and.pencil.circle", title: "설정", selectedImage: "square.and.pencil.circle.fill")
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
        setShadow()
        buttonTapped(homeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(stackView)
        [homeButton, favoriteButton, settingButton].forEach {
            stackView.addArrangedSubview($0)
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        homeButton.tag = 0
        favoriteButton.tag = 1
        settingButton.tag = 2
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.verticalEdges.equalToSuperview()
        }
    }
    
    @objc
    private func buttonTapped(_ sender: CustomTabButton) {
        select(sender.tag)
    }
    
    private func select(_ index: Int) {
        for (i, button) in [homeButton, favoriteButton, settingButton].enumerated() {
            button.isSelected = (i == index)
            button.setNeedsUpdateConfiguration()
        }
    }
    
    private func setShadow() {
        layer.shadowOpacity = 0.08
        layer.shadowColor = UIColor.black.cgColor
    }
}

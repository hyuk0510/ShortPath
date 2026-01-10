//
//  CustomTabBar.swift
//  ShortPath
//
//  Created by 선상혁 on 12/29/25.
//

import UIKit

enum Buttons: CaseIterable {
    case home
    case favorite
    case setting
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .favorite: return "즐겨찾기"
        case .setting: return "설정"
        }
    }
    
    var defaultImage: String {
        switch self {
        case .home: return "pencil.circle"
        case .favorite: return "star"
        case .setting: return "square.and.pencil.circle"
        }
    }
    
    var selectedImage: String {
        switch self {
        case .home: return "pencil.circle.fill"
        case .favorite: return "star.fill"
        case .setting: return "square.and.pencil.circle.fill"
        }
    }
}

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
    
    private var buttons: [Buttons: CustomTabButton] = [:]
    private var selectedTab: Buttons?
    
    weak var tabButtonDelegate: CustomTabBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
        setShadow()
        buttonTapped(buttons[Buttons.home] ?? CustomTabButton())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(stackView)
        translatesAutoresizingMaskIntoConstraints = false
        
        Buttons.allCases.forEach { tab in
            let button = CustomTabButton(defaultImage: tab.defaultImage, title: tab.title, selectedImage: tab.selectedImage)
            
            buttons[tab] = button
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.verticalEdges.equalToSuperview()
        }
    }
    
    @objc
    private func buttonTapped(_ sender: CustomTabButton) {
        guard let tab = buttons.first(where: { $0.value == sender })?.key else { return }
        
        select(tab)
        
        tabButtonDelegate?.didSelectTab(tab)
    }
    
    private func select(_ tab: Buttons) {
        selectedTab = tab
        
        for (type, button) in buttons {
            button.isSelected = (type == tab)
            button.setNeedsUpdateConfiguration()
        }
    }
    
    func deselectAll() {
        selectedTab = nil
        
        for button in buttons.values {
            button.isSelected = false
            button.setNeedsUpdateConfiguration()
        }
    }
}

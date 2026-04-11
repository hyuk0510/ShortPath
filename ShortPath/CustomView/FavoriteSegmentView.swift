//
//  FavoriteSegmentView.swift
//  ShortPath
//
//  Created by 선상혁 on 4/11/26.
//

import UIKit
import SnapKit

enum FavoriteTab {
    case place
    case route
}

final class FavoriteSegmentView: UIView {
    
    private var containerView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "0xF5F5F5")
        
        return view
    }()
    
    private var selectionView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        return view
    }()
    
    private var placeButton: UIButton = {
        let view = UIButton()
    
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var routeButton: UIButton = {
        let view = UIButton()
        
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private var selectionLeadingConstraint: Constraint!
    
    var onTabChanged: ((FavoriteTab) -> Void)?
    
    private(set) var selectedTab: FavoriteTab = .place
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(56)
        }
        
        [selectionView, placeButton, routeButton].forEach { view in
            containerView.addSubview(view)
        }
        
        selectionView.snp.makeConstraints { make in
            selectionLeadingConstraint = make.leading.equalToSuperview().offset(6).constraint
            make.verticalEdges.equalToSuperview().inset(6)
            make.width.equalToSuperview().offset(-12).multipliedBy(0.5)
        }
        
        placeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        routeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        placeButton.addTarget(self, action: #selector(placeButtonPressed), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func placeButtonPressed() {
        selectedTab = .place
        updateUI()
        onTabChanged?(.place)
    }
    
    @objc
    private func routeButtonPressed() {
        selectedTab = .route
        updateUI()
        onTabChanged?(.route)
    }
    
    private func updateUI() {
        let updateBlock = {
            switch self.selectedTab {
            case .place:
                self.selectionLeadingConstraint.update(offset: 6)
                
                self.placeButtonTab()
                
            case .route:
                self.selectionLeadingConstraint.update(offset: self.containerView.bounds.width / 2)
                
                self.routeButtonTab()
            }
            
            self.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            updateBlock()
        }
    }
    
    private func placeButtonTab() {
        var placeButtonConfigure = UIButton.Configuration.plain()
        var placeButtonContainer = AttributeContainer()
        
        var routeButtonConfigure = UIButton.Configuration.plain()
        var routeButtonContainer = AttributeContainer()
        
        placeButtonConfigure.image = UIImage(named: "PlaceTabButton")
        placeButtonConfigure.imagePadding = 8
        placeButtonContainer.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        placeButtonConfigure.attributedTitle = AttributedString("장소", attributes: placeButtonContainer)
        placeButtonConfigure.baseForegroundColor = .black
        
        routeButtonConfigure.image = UIImage(named: "RouteTabButton.unSelected")
        routeButtonConfigure.imagePadding = 8
        routeButtonContainer.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        routeButtonConfigure.attributedTitle = AttributedString("경로", attributes: routeButtonContainer)
        routeButtonConfigure.baseForegroundColor = .black
        
        placeButton.configuration = placeButtonConfigure
        routeButton.configuration = routeButtonConfigure
    }
    
    private func routeButtonTab() {
        var placeButtonConfigure = UIButton.Configuration.plain()
        var placeButtonContainer = AttributeContainer()
        
        var routeButtonConfigure = UIButton.Configuration.plain()
        var routeButtonContainer = AttributeContainer()
        
        placeButtonConfigure.image = UIImage(named: "PlaceTabButton.unSelected")
        placeButtonConfigure.imagePadding = 8
        placeButtonContainer.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        placeButtonConfigure.attributedTitle = AttributedString("장소", attributes: placeButtonContainer)
        placeButtonConfigure.baseForegroundColor = .black
        
        routeButtonConfigure.image = UIImage(named: "RouteTabButton")
        routeButtonConfigure.imagePadding = 8
        routeButtonContainer.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        routeButtonConfigure.attributedTitle = AttributedString("경로", attributes: routeButtonContainer)
        routeButtonConfigure.baseForegroundColor = .black
        
        placeButton.configuration = placeButtonConfigure
        routeButton.configuration = routeButtonConfigure
    }
}

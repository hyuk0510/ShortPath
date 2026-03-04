//
//  Root+LifeCycle.swift
//  ShortPath
//
//  Created by 선상혁 on 2/17/26.
//

import UIKit

extension RootContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMap()
        setUpSearchBar()
        setUpBottomSheet()
        setUpTabBar()
        
        DispatchQueue.main.async {
            self.setUpCurrentLocationButton()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            _ = self.searchVC.view
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        guard let nav = navigationController?.navigationBar else { return }
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        nav.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        searchBarContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
}

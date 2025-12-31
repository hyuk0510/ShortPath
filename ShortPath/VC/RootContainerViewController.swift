//
//  RootContainerViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

final class RootContainerViewController: UIViewController {
    private let mapVC = MapViewController()
    private let customTabBar = CustomTabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        presentTabBar()
    }
    
    private func setupMap() {
        addChild(mapVC)
        view.addSubview(mapVC.view)
        mapVC.view.frame = view.bounds
        mapVC.didMove(toParent: self)
    }
    
    private func presentTabBar() {
        let height: CGFloat = 49 + view.safeAreaInsets.bottom
        
        view.addSubview(customTabBar)
        view.bringSubviewToFront(customTabBar)
        
        customTabBar.frame = CGRect(
            x: 0,
            y: view.bounds.height - height,
            width: view.bounds.width,
            height: height
        )
    }
}

//
//  SearchViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit

final class SearchViewController: UIViewController {
    
    private let navView = CustomNavView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        guard let nav = navigationController?.navigationBar else { return }
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        
        self.navigationItem.titleView = navView
    }
    
    private func setNavBar() {
        navigationItem.hidesBackButton = true
        
        navView.backButton.addTarget(self, action: #selector(popVC), for: .touchUpInside)
    }
    
    @objc
    private func popVC() {
        navigationController?.popViewController(animated: false)
    }
}

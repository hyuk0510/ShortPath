//
//  SearchViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit

final class SearchViewController: UIViewController {
    
    private let navView = CustomNavView()
    private let recentSearchTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setNavBar()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        guard let nav = navigationController?.navigationBar else { return }
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        nav.isHidden = false
        
        self.navigationItem.titleView = navView
    }
    
    private func setNavBar() {
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        navView.backButton.addTarget(self, action: #selector(popVC), for: .touchUpInside)
    }
    
    @objc
    private func popVC() {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func setTableView() {
        view.addSubview(recentSearchTableView)
        
        recentSearchTableView.delegate = self
        recentSearchTableView.dataSource = self
        
        recentSearchTableView.backgroundColor = .white
        recentSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchTableView.keyboardDismissMode = .onDrag
        recentSearchTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        recentSearchTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else { return CustomTableViewCell() }
        
        cell.bind()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select", indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

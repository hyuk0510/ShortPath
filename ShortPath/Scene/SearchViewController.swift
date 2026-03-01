//
//  SearchViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit
import CoreLocation

final class SearchViewController: UIViewController {
    
    var navView = CustomNavView()
    private let recentSearchTableView = UITableView()
    
    var documents: [Document]?
    private var searchTask: Task<Void, Never>?
    
    weak var delegate: SearchViewControllerDelegate?
    var coordinate: CLLocation?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.navView.searchTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navView.searchTextField.text = ""
    }
    
    private func setNavBar() {
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        navView.textFieldDelegate = self
        navView.backButton.addTarget(self, action: #selector(popVC), for: .touchUpInside)
    }
    
    @objc
    private func popVC() {
        delegate?.didDisappear()
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func debounceSearch(text: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300000000)
            guard !Task.isCancelled else { return }
            guard let coord = coordinate else { return }
            
            do {
                let result = try await KakaoLocalManager.shared.fetchData(text: text, coordinate: coord.coordinate)
                
                await MainActor.run {
                    documents = result.documents
                    recentSearchTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func focusOnSearchTextField() {
        navView.searchTextField.becomeFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let documents = documents else { return 0 }
        
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else { return CustomTableViewCell() }
        
        guard let documents = documents, let coord = coordinate else { return CustomTableViewCell() }
        
        cell.bind(data: documents[indexPath.row], currentLocation: coord)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let documents = documents else { return }
                
        delegate?.didSelectedPlace(place: documents[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

extension SearchViewController: CustomNavViewDelegate {
    func didChangeSearchText(text: String) {
        debounceSearch(text: text)
    }
}

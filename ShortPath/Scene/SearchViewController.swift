//
//  SearchViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit
import CoreLocation

enum SearchMode {
    case main
    case routing(targetID: UUID, role: RouteSection)
    
    var navigationTitle: String {
        switch self {
        case .main:
            return "장소 ･ 주소 검색"
        case .routing(_, let role):
            switch role {
            case .start:
                return "출발지 검색"
            case .wayPoint:
                return "경유지 검색"
            case .destination:
                return "도착지 검색"
            }
        }
    }
}

final class SearchViewController: UIViewController {
    
    let mode: SearchMode
    
    init(mode: SearchMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var navView = CustomNavView()
    private let searchResultTableView = UITableView()
    var currentLocationButton = UIButton()
    
    var places: [Place] = []
    
    private var searchTask: Task<Void, Never>?
    
    weak var delegate: SearchViewControllerDelegate?
    var coordinate: CLLocation?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureNavView()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navView.searchTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !places.isEmpty {
            places.removeAll()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navView.searchTextField.text = ""
    }
    
    private func configureNavView() {
        navView.setNavTitle(mode: mode)
        navView.textFieldDelegate = self
        navView.backButton.addTarget(self, action: #selector(popVC), for: .touchUpInside)
    }
    
    private func setNavBar() {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        guard let nav = navigationController?.navigationBar else { return }
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        
        navigationItem.titleView = navView
    }
    
    @objc
    private func popVC() {
        delegate?.didDisappear(mode: mode)
    }
    
    private func setTableView() {
        view.addSubview(searchResultTableView)
        
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        
        searchResultTableView.backgroundColor = .white
        searchResultTableView.translatesAutoresizingMaskIntoConstraints = false
        searchResultTableView.keyboardDismissMode = .onDrag
        searchResultTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        
        searchResultTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func debounceSearch(text: String) {
        searchTask?.cancel()
        
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        guard !query.isEmpty else {
            places = []
            searchResultTableView.reloadData()
            searchResultTableView.isHidden = true
            
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300000000)
            guard !Task.isCancelled else { return }
            guard let coord = coordinate else { return }
            
            do {
                let result = try await KakaoLocalManager.shared.fetchKeywordSearch(text: query, coordinate: coord.coordinate)
                
                guard !Task.isCancelled else { return }
                            
                let mappedPlaces = result.documents.map { $0.toPlace() }
                let sortedPlaces = self.sortPlaces(mappedPlaces, query: query)
                
                await MainActor.run {
                    self.places = sortedPlaces
                    searchResultTableView.isHidden = false
                    searchResultTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func sortPlaces(_ places: [Place], query: String) -> [Place] {
        let normalizedQuery = normalize(query)
        
        return places.sorted { lhs, rhs in
            score(for: lhs, query: normalizedQuery) > score(for: rhs, query: normalizedQuery)
        }
    }

    private func score(for place: Place, query: String) -> Int {
        let name = normalize(place.name)
        let roadAddress = normalize(place.roadAddress ?? "")
        let address = normalize(place.address)
        
        if name.hasPrefix(query) { return 300 }
        if name.contains(query) { return 200 }
        if roadAddress.contains(query) { return 100 }
        if address.contains(query) { return 80 }
        
        return 0
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return SearchTableViewCell() }
        
        let place = places[indexPath.row]
                
        cell.bind(place: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectedPlace(place: places[indexPath.row], mode: mode)
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

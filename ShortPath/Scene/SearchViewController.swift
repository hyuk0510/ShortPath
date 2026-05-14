//
//  SearchViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 1/11/26.
//

import UIKit
import CoreLocation
import SnapKit

enum SearchMode: Equatable {
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
    
    var targetID: UUID? {
        switch self {
        case .main:
            return nil
        case .routing(let targetID, _):
            return targetID
        }
    }
}


enum SearchListMode {
    case recent
    case result
}

extension Notification.Name {
    static let recentPlaceItemsDidChange = Notification.Name("recentPlaceItemsDidChange")
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
    
    var currentLocationButton: UIButton = {
        let view = UIButton(type: .custom)
        var configure = UIButton.Configuration.filled()
        var container = AttributeContainer()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold, scale: .medium)
        let backgroundColor = UIColor(hex: "F2F7FF")
        let foregroundColor = UIColor(hex: "0A84FF")

        container.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        configure.image = UIImage(systemName: "location.fill", withConfiguration: symbolConfig)
        configure.attributedTitle = AttributedString("내 위치로 설정", attributes: container)
        configure.baseBackgroundColor = backgroundColor
        configure.baseForegroundColor = foregroundColor
        configure.cornerStyle = .capsule
        configure.imagePadding = 6
        configure.imagePlacement = .leading
        configure.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 14)

        view.configuration = configure
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor(hex: "0A84FF").cgColor
        view.layer.shadowOpacity = 0.10
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
//        view.adjustsImageWhenHighlighted = false

        return view
    }()
    
    private var places: [Place] = []
    
    private var searchTask: Task<Void, Never>?
    
    weak var delegate: SearchViewControllerDelegate?
    var coordinate: CLLocation?
    
    private var searchResultTableViewTopToSafeArea: Constraint?
    private var searchResultTableViewTopToButton: Constraint?
    
    private let recentSearchTableView = UITableView(frame: .zero, style: .plain)
    
    private let recentPlaceEmptyLabel: UILabel = {
        let label = UILabel()
        
        label.text = "최근 검색한 장소가 없습니다"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.isHidden = true
        
        return label
    }()
    
    private let recentPlaceSectionView = UIView()
    
    private var searchListMode: SearchListMode = .recent {
        didSet {
            updateUI()
        }
    }
    
    private let recentPlaceViewModel = RecentPlaceViewModel()
    
    private var recentPlaces: [RecentPlaceItem] = []

    private let favoritePlaceRepo = FavoriteRepository.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureNavView()
        setCurrentLocationButton()
        setTableView()
        fetchRecentPlaces()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavBar()
        fetchRecentPlaces()
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
    
    private func setCurrentLocationButton() {
        view.addSubview(currentLocationButton)

        currentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.height.equalTo(34)
        }

        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func currentLocationButtonPressed() {
        guard let targetID = mode.targetID else { return }
        
        delegate?.sendCurrentLocation(targetID)
        popVC()
    }
    
    private func setTableView() {
        view.addSubview(searchResultTableView)
        
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        
        searchResultTableView.backgroundColor = .white
        searchResultTableView.translatesAutoresizingMaskIntoConstraints = false
        searchResultTableView.keyboardDismissMode = .onDrag
        searchResultTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        
        view.addSubview(recentPlaceSectionView)
        
        [recentSearchTableView, recentPlaceEmptyLabel].forEach { view in
            recentPlaceSectionView.addSubview(view)
        }
        
        recentSearchTableView.delegate = self
        recentSearchTableView.dataSource = self
        
        recentSearchTableView.backgroundColor = .white
        recentSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchTableView.keyboardDismissMode = .onDrag
        recentSearchTableView.register(SearchVCRecentTableViewCell.self, forCellReuseIdentifier: SearchVCRecentTableViewCell.identifier)

    }
    
    func debounceSearch(text: String) {
        searchTask?.cancel()
        
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        guard !query.isEmpty else {
            Task { @MainActor in
                self.places = []
                self.searchListMode = .recent
                self.searchResultTableView.reloadData()
                self.recentSearchTableView.reloadData()
            }
            
            return
        }
        
        searchListMode = .result
        
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
    
    private func updateUI() {
        let shouldShowCurrentLocationButton = (mode != .main)
        
        currentLocationButton.isHidden = !shouldShowCurrentLocationButton
        
        switch searchListMode {
        case .recent:
            recentPlaceSectionView.isHidden = false
            searchResultTableView.isHidden = true
            
            if recentPlaces.isEmpty {
                recentSearchTableView.isHidden = true
                recentPlaceEmptyLabel.isHidden = false
            } else {
                recentSearchTableView.isHidden = false
                recentPlaceEmptyLabel.isHidden = true
            }
            
        case .result:
            recentPlaceSectionView.isHidden = true
            searchResultTableView.isHidden = false
        }
        
        let topAnchorView = shouldShowCurrentLocationButton ? currentLocationButton.snp.bottom : view.safeAreaLayoutGuide.snp.top
        let topOffset: CGFloat = shouldShowCurrentLocationButton ? 16 : 0
        
        recentPlaceSectionView.snp.remakeConstraints { make in
            make.top.equalTo(topAnchorView).offset(topOffset)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        recentSearchTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recentPlaceEmptyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        searchResultTableView.snp.remakeConstraints { make in
            make.top.equalTo(topAnchorView).offset(topOffset)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func fetchRecentPlaces() {
        do {
            recentPlaces = try recentPlaceViewModel.fetchRecentPlaceItems()
        } catch {
            print(error)
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView == recentSearchTableView else { return nil }
        
        let view = UIView()
        
        view.backgroundColor = .white
        
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 16 ,weight: .bold)
        label.text = "최근 검색"
        label.textColor = .black
        
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == recentSearchTableView {
            return 28
        } else {
            return .leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recentSearchTableView {
            return recentPlaces.count
        } else if tableView == searchResultTableView {
            return places.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == recentSearchTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchVCRecentTableViewCell.identifier, for: indexPath) as? SearchVCRecentTableViewCell else { return SearchVCRecentTableViewCell() }
            
            let item = recentPlaces[indexPath.row]
            
            cell.onTapDeletebutton = { [weak self, weak tableView] in
                guard let self, let tableView else { return }
                
                do {
                    try recentPlaceViewModel.deleteItem(id: item.id)
                    
                    if let currentIndex = recentPlaces.firstIndex(where: { $0.id == item.id }) {
                        recentPlaces.remove(at: currentIndex)
                    }
                    
                    tableView.reloadData()
                    updateUI()
                    
                    NotificationCenter.default.post(name: .recentPlaceItemsDidChange, object: nil)
                } catch {
                    print(error)
                }
            }
            
            cell.bind(item)
            
            return cell
        } else if tableView == searchResultTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return SearchTableViewCell() }
            
            let place = places[indexPath.row]
            let isFavorite = favoritePlaceRepo.isFavorite(placeID: place.id)
            
            cell.bind(place: place, isFavorite: isFavorite)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == recentSearchTableView {
            delegate?.didSelectedPlace(place: recentPlaces[indexPath.row].place, mode: mode)
        } else if tableView == searchResultTableView {
            delegate?.didSelectedPlace(place: places[indexPath.row], mode: mode)
            NotificationCenter.default.post(name: .recentPlaceItemsDidChange, object: nil)
        }
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

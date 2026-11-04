//
//  FavoriteTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

enum FavoritePlaceListMode {
    case folderList
    case folderDetail(String)
}

final class FavoriteTabViewController: UIViewController, BottomSheetInteractable {
    
    var scrollView: UIScrollView {
            favoriteTableView
    }
    
    private var contentStackView = UIStackView()

    var trackingScrollView: UIScrollView? {
        return scrollView
    }
    
    private let segmentView = FavoriteSegmentView()
    
    var favoriteTableView = UITableView()
    
    weak var delegate: FavoriteViewControllerDelegate?
    
    var places: [FavoritePlace] = []
    var routes: [FavoriteRouteObject] = []
    
    private var placeListMode: FavoritePlaceListMode = .folderList
    private let repository: FavoriteRepositoryProtocol = FavoriteRepository.shared
    
    var isBottomSheetInteracting = false
    var lastBottomSheetInteractionDate: Date?

    private var shouldIgnoreSelection: Bool {
        if isBottomSheetInteracting { return true }
        
        guard let lastDate = lastBottomSheetInteractionDate else { return false }
        
        return Date().timeIntervalSince(lastDate) < 0.15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        [segmentView, favoriteTableView].forEach { subView in
            view.addSubview(subView)
        }
        
        segmentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        favoriteTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        favoriteTableView.backgroundColor = .white
        favoriteTableView.contentInset.bottom = 100
        favoriteTableView.verticalScrollIndicatorInsets.bottom = 100
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.translatesAutoresizingMaskIntoConstraints = false
        favoriteTableView.rowHeight = UITableView.automaticDimension
        favoriteTableView.estimatedRowHeight = 76
        favoriteTableView.register(FavoritePlaceCell.self, forCellReuseIdentifier: FavoritePlaceCell.identifier)
        favoriteTableView.register(FolderCell.self, forCellReuseIdentifier: FolderCell.identifier)

        segmentView.onTabChanged = { [weak self] tab in
            guard let self else { return }
            
            switch tab {
            case .place:
                placeListMode = .folderList
                favoriteTableView.register(FavoritePlaceCell.self, forCellReuseIdentifier: FavoritePlaceCell.identifier)
            case .route:
                favoriteTableView.register(FavoriteRouteCell.self, forCellReuseIdentifier: FavoriteRouteCell.identifier)
            }
            
            favoriteTableView.reloadData()
        }
    }
    
    func showActionSheet(from sourceView: UIView, _ place: Place?, _ objectID: String, _ row: Int) {
        let alert = UIAlertController(title: nil, message: "삭제하시겠습니까?", preferredStyle: .alert)
        
        switch segmentView.selectedTab {
        case .place:
            let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                guard let self else { return }
                guard let place = place else { return }
                
                places.removeAll{ $0.id == place.id }
                delegate?.removePlace(place)
                view.showToast("즐겨찾기에서 삭제됨")
                
                favoriteTableView.reloadData()
            }
            
            alert.addAction(deleteAction)

        case .route:
            let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
                guard let self else { return }
                
                routes.remove(at: row)
                delegate?.removeRoute(objectID)
                view.showToast("경로가 삭제되었습니다.")
                favoriteTableView.reloadData()
            }
            
            alert.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        present(alert, animated: true)
    }
    
    func updateData(places: [FavoritePlace], routes: [FavoriteRouteObject]) {
        self.places = places
        self.routes = routes
        placeListMode = .folderList
        favoriteTableView.reloadData()
    }
    
    private var folderNames: [String] {
        repository.fetchAllFolderNames()
    }

    private func places(inFolder folderName: String) -> [FavoritePlace] {
        places.filter { $0.folderName == folderName }
    }

    @objc
    private func folderBackButtonPressed() {
        placeListMode = .folderList
        favoriteTableView.reloadData()
    }
}

extension FavoriteTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        let titleLabel = UILabel()
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.textColor = .black
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        switch segmentView.selectedTab {
        case .place:
            switch placeListMode {
            case .folderList:
                titleLabel.text = "폴더 \(folderNames.count)개"
                
                titleLabel.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(16)
                    make.top.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(8)
                }
                
            case .folderDetail(let folderName):
                let backButton = UIButton(type: .system)
                backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
                backButton.tintColor = .black
                backButton.addTarget(self, action: #selector(folderBackButtonPressed), for: .touchUpInside)
                
                containerView.addSubview(backButton)
                
                titleLabel.text = "\(folderName) \(places(inFolder: folderName).count)개"
                
                backButton.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(12)
                    make.centerY.equalTo(titleLabel)
                    make.width.height.equalTo(24)
                }
                
                titleLabel.snp.makeConstraints { make in
                    make.leading.equalTo(backButton.snp.trailing).offset(4)
                    make.top.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(8)
                }
            }
        case .route:
            titleLabel.text = "저장된 경로 \(routes.count)개"
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.top.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(8)
            }
        }
        
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentView.selectedTab {
        case .place:
            switch placeListMode {
            case .folderList:
                return folderNames.count
            case .folderDetail(let folderName):
                return places(inFolder: folderName).count
            }
        case .route:
            return routes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentView.selectedTab {
        case .place:
            switch placeListMode {
            case .folderList:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FolderCell.identifier, for: indexPath) as? FolderCell else { return FolderCell() }
                let folderName = folderNames[indexPath.row]
                let count = places(inFolder: folderName).count
                
                cell.bind(name: folderName, count: count, showDeleteButton: folderName != "기본")
                cell.accessoryType = .disclosureIndicator
                cell.onTapDelete = { [weak self] in
                    guard let self else { return }
                    
                    repository.deleteFolder(name: folderName)
                    favoriteTableView.reloadData()
                }
                
                return cell
                
            case .folderDetail(let folderName):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlaceCell.identifier, for: indexPath) as? FavoritePlaceCell else { return FavoritePlaceCell() }
                
                let place = places(inFolder: folderName)[indexPath.row]
                let distance = delegate?.calculatedDistance((place.longitude, place.latitude))
                
                cell.selectionStyle = .none
                cell.bind(place, distance)
                cell.onTapMenuButton = { [weak self] in
                    guard let self else { return }
                    
                    showActionSheet(from: cell, place.toPlace(), "", indexPath.row)
                }
                
                return cell
            }
        
            
        case .route:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteRouteCell.identifier, for: indexPath) as? FavoriteRouteCell else { return FavoriteRouteCell() }
            
            let route = routes[indexPath.row]
            
            cell.selectionStyle = .none
            cell.bind(route)
            cell.onTapMenuButton = { [weak self] in
                guard let self else { return }
                
                showActionSheet(from: cell, nil, route.id, indexPath.row)
            }
                        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !shouldIgnoreSelection else { return }
        
        switch segmentView.selectedTab {
        case .place:
            switch placeListMode {
            case .folderList:
                let folderName = folderNames[indexPath.row]
                placeListMode = .folderDetail(folderName)
                favoriteTableView.reloadData()
                
            case .folderDetail(let folderName):
                delegate?.didTabPlaceCell(places(inFolder: folderName)[indexPath.row])
            }
        case .route:
            delegate?.didTabRouteCell(routes[indexPath.row])
        }
    }
}

extension FavoriteTabViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === favoriteTableView else { return }
        
        favoriteTableView.allowsSelection = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === favoriteTableView else { return }
        
        if !decelerate {
            favoriteTableView.allowsSelection = true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === favoriteTableView else { return }
        
        favoriteTableView.allowsSelection = true
    }
}

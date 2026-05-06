//
//  FavoriteTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

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
            make.bottom.equalToSuperview().inset(100)
        }
        
        favoriteTableView.backgroundColor = .white
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.translatesAutoresizingMaskIntoConstraints = false
        favoriteTableView.rowHeight = UITableView.automaticDimension
        favoriteTableView.estimatedRowHeight = 76
        favoriteTableView.register(FavoritePlaceCell.self, forCellReuseIdentifier: FavoritePlaceCell.identifier)

        segmentView.onTabChanged = { [weak self] tab in
            guard let self else { return }
            
            switch tab {
            case .place:
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
                
                places.remove(at: row)
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
            titleLabel.text = "저장된 장소 \(places.count)개"
        case .route:
            titleLabel.text = "저장된 경로 \(routes.count)개"
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentView.selectedTab {
        case .place:
            return places.count
        case .route:
            return routes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentView.selectedTab {
        case .place:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlaceCell.identifier, for: indexPath) as? FavoritePlaceCell else { return FavoritePlaceCell() }
            
            let place = places[indexPath.row]
            let distance = delegate?.calculatedDistance((place.longitude, place.latitude))
            
            cell.selectionStyle = .none
            cell.bind(place, distance)
            cell.onTapMenuButton = { [weak self] in
                guard let self else { return }
                
                showActionSheet(from: cell, place.toPlace(), "", indexPath.row)
            }
            
            return cell
            
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
            delegate?.didTabPlaceCell(places[indexPath.row])
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

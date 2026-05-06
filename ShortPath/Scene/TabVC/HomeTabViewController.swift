//
//  HomeTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit
import SnapKit

final class HomeTabViewController: UIViewController, BottomSheetInteractable {
    
    var scrollView = UIScrollView()
    private var contentStackView = UIStackView()
    
    var trackingScrollView: UIScrollView? {
        return scrollView
    }
    
    private lazy var recentRouteCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        view.isScrollEnabled = true
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        view.decelerationRate = .fast
        view.clipsToBounds = false
        
        return view
    }()
    
    private let recentRouteTitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "최근 사용 경로"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(hex: "0x1C1C1E")
        
        return label
    }()
    
    private let recentRouteEmptyLabel: UILabel = {
        let label = UILabel()
        
        label.text = "최근 사용한 경로가 없습니다"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "0x8E8E93")
        label.backgroundColor = UIColor(hex: "0xF8F8FA")
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.isHidden = true
        
        return label
    }()
    
    private let recentSearchPlaceTableView = UITableView(frame: .zero, style: .plain)
    
    private let recentPlaceTitleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "최근 검색 장소"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(hex: "0x1C1C1E")
        
        return label
    }()
    
    private let recentPlaceEmptyLabel: UILabel = {
        let label = UILabel()
        
        label.text = "최근 검색한 장소가 없습니다"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "0x8E8E93")
        label.backgroundColor = UIColor(hex: "0xF8F8FA")
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.isHidden = true
        
        return label
    }()
    
    private let tableViewHeaderView = RecentPlaceHeaderView()
    
    private let recentRouteViewModel = RecentRouteViewModel()
    private let recentPlaceViewModel = RecentPlaceViewModel()
    
    private var placeItems: [RecentPlaceItem] = []
    private var routeItems: [RecentRouteItem] = []
    private var recentPlaceTitleHeightConstraint: Constraint?
    
    private let recentRouteSectionView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.clipsToBounds = false
        
        return view
    }()
    private let recentPlaceSectionView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.clipsToBounds = false
        
        return view
    }()
    
    weak var delegate: HomeTabViewControllerDelegate?
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0)
        layout.itemSize = CGSize(width: 220, height: 140)
        layout.estimatedItemSize = .zero
        
        return layout
    }()
    
    private var isBottomSheetInteracting: Bool = false
    var lastBottomSheetInteractionDate: Date?

    private var shouldIgnoreSelection: Bool {
        if isBottomSheetInteracting { return true }
        
        guard let lastDate = lastBottomSheetInteractionDate else { return false }
        
        return Date().timeIntervalSince(lastDate) < 0.15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        configure()
        addNotificationObserver()
        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recentPlaceItemsDidChange),
            name: .recentPlaceItemsDidChange,
            object: nil
        )
    }

    @objc
    private func recentPlaceItemsDidChange() {
        reloadData()
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(48)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        [recentRouteSectionView, recentPlaceSectionView].forEach { view in
            contentStackView.addArrangedSubview(view)
        }
        
        setRecentRouteCollectionView()
        setRecentSearchPlaceTableView()
        setRecentRouteSection()
        setRecentPlaceSection()
    }
    
    private func setRecentRouteSection() {
        recentRouteSectionView.addSubview(recentRouteTitleLabel)
        recentRouteSectionView.addSubview(recentRouteCollectionView)
        recentRouteSectionView.addSubview(recentRouteEmptyLabel)
        
        recentRouteSectionView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        recentRouteTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(24)
        }
        
        recentRouteCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentRouteTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        recentRouteEmptyLabel.snp.makeConstraints { make in
            make.top.equalTo(recentRouteTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setRecentPlaceSection() {
        recentPlaceSectionView.addSubview(recentPlaceTitleLabel)
        recentPlaceSectionView.addSubview(recentSearchPlaceTableView)
        recentPlaceSectionView.addSubview(recentPlaceEmptyLabel)
        
        recentPlaceSectionView.snp.makeConstraints { make in
            make.height.equalTo(530)
        }
        
        recentPlaceTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            recentPlaceTitleHeightConstraint = make.height.equalTo(0).constraint
        }
        
        recentSearchPlaceTableView.snp.makeConstraints { make in
            make.top.equalTo(recentPlaceTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        recentPlaceEmptyLabel.snp.makeConstraints { make in
            make.top.equalTo(recentPlaceTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    private func setRecentRouteCollectionView() {
        recentRouteCollectionView.delegate = self
        recentRouteCollectionView.dataSource = self
        
        recentRouteCollectionView.register(RecentRouteCell.self, forCellWithReuseIdentifier: RecentRouteCell.identifier)
        
        recentRouteCollectionView.snp.makeConstraints { make in
            make.height.equalTo(124)
        }
    }
    
    private func setRecentSearchPlaceTableView() {
        recentSearchPlaceTableView.delegate = self
        recentSearchPlaceTableView.dataSource = self
        
        recentSearchPlaceTableView.register(RecentSearchPlaceCell.self, forCellReuseIdentifier: RecentSearchPlaceCell.identifier)
        recentSearchPlaceTableView.isEditing = false
        recentSearchPlaceTableView.isScrollEnabled = false
        
        recentSearchPlaceTableView.snp.makeConstraints { make in
            make.height.equalTo(500)
        }
        
        recentSearchPlaceTableView.backgroundColor = .white
        
        tableViewHeaderView.onTapSearchVCButton = { [weak self] in
            guard let self else {return }
            guard !self.shouldIgnoreSelection else { return }
            
            self.delegate?.pushSearchVCButtonPressed()
        }
    }
    
    func reloadData() {
        do {
            placeItems = try recentPlaceViewModel.fetchRecentPlaceItems()
            routeItems = try recentRouteViewModel.fetchRecentRouteItems(limit: 10)
            
            recentRouteEmptyLabel.isHidden = !routeItems.isEmpty
            recentRouteCollectionView.isHidden = routeItems.isEmpty
            
            let hasRecentPlaces = !placeItems.isEmpty
            
            recentPlaceTitleLabel.isHidden = hasRecentPlaces
            recentPlaceTitleHeightConstraint?.update(offset: hasRecentPlaces ? 0 : 24)
            
            recentPlaceEmptyLabel.isHidden = hasRecentPlaces
            recentSearchPlaceTableView.isHidden = !hasRecentPlaces
            
            recentRouteCollectionView.reloadData()
            recentSearchPlaceTableView.reloadData()
        } catch {
            print("❌ Home data load failed:", error)
        }
    }
    
    private func menuAlert(_ item: RecentRouteItem, row: Int) {
        switch item {
        case .currentLocationDestination(let currentLocationRecentRoute):
            let alert = UIAlertController(title: currentLocationRecentRoute.destination.name, message: nil, preferredStyle: .actionSheet)

            let moveToPlaceDetail = UIAlertAction(title: "장소 상세로 이동", style: .default) { [weak self] _ in
                guard let self else { return }

                var destination = currentLocationRecentRoute.destination
                let distance = self.delegate?.calculatedDistance(item)
                destination.distance = distance

                self.delegate?.moveToPlaceDetail(destination)
            }

            let deleteItem = UIAlertAction(title: "최근 경로에서 삭제", style: .destructive) { [weak self] _ in
                guard let self else { return }

                do {
                    try self.recentRouteViewModel.delete(item: item)

                    self.routeItems.remove(at: row)

                    self.reloadData()
                } catch {
                    self.view.showToast("\(error) 경로 삭제에 실패했습니다.")
                }
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel)

            alert.addAction(moveToPlaceDetail)
            alert.addAction(deleteItem)
            alert.addAction(cancel)

            present(alert, animated: true)

        case .presetRoute(_):
            let alert = UIAlertController(title: "경로 삭제", message: nil, preferredStyle: .actionSheet)
            
            let deleteItem = UIAlertAction(title: "최근 경로에서 삭제", style: .destructive) { [weak self] _ in
                guard let self else { return }

                do {
                    try self.recentRouteViewModel.delete(item: item)
                    
                    self.routeItems.remove(at: row)
                    
                    self.reloadData()
                } catch {
                    self.view.showToast("\(error) 경로 삭제에 실패했습니다.")
                }
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel)

            
            alert.addAction(deleteItem)
            alert.addAction(cancel)

            present(alert, animated: true)
        }
    
    }
}

extension HomeTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        routeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentRouteCell.identifier, for: indexPath) as? RecentRouteCell else { return UICollectionViewCell() }
        guard indexPath.item < routeItems.count else { return UICollectionViewCell() }
        
        let item = routeItems[indexPath.row]
        let distance: Int?
        
        switch item {
        case .currentLocationDestination:
            distance = delegate?.calculatedDistance(item)
        case .presetRoute(let presetRoute):
            distance = presetRoute.distance
        }
        
        cell.contentView.layer.cornerRadius = 18
        cell.contentView.layer.cornerCurve = .continuous
        cell.contentView.clipsToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.10
        cell.layer.shadowRadius = 8
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.masksToBounds = false
        
        cell.bind(item, distance: distance ?? 0)
        
        cell.onTapMenu = { [weak self] in
            guard let self else { return }
            guard !self.shouldIgnoreSelection else { return }
            
            self.menuAlert(item, row: indexPath.row)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !shouldIgnoreSelection else { return }
        guard indexPath.item < routeItems.count else { return }
        
        let item = routeItems[indexPath.row]
        
        delegate?.didTapRecentRoute(item)
    }
}

extension HomeTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return tableViewHeaderView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(5, placeItems.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchPlaceCell.identifier, for: indexPath) as? RecentSearchPlaceCell else { return UITableViewCell() }
        guard indexPath.item < placeItems.count else { return UITableViewCell() }

        let item = placeItems[indexPath.row]
        
        cell.bind(item)
        
        cell.onTapFavorite = { [weak self] in
            guard let self else { return }
            guard !self.shouldIgnoreSelection else { return }
            
            delegate?.favoriteButtonPressed(item)
            placeItems[indexPath.row].isFavorite.toggle()
            
            recentSearchPlaceTableView.reloadData()
        }
        
        cell.onTapRouting = { [weak self] in
            guard let self else { return }
            guard !self.shouldIgnoreSelection else { return }

            delegate?.moveToRouteEditing(item.place)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !shouldIgnoreSelection else { return }
        guard indexPath.item < placeItems.count else { return }

        let item = placeItems[indexPath.row]
        
        delegate?.moveToPlaceDetail(item.place)
    }
}

extension HomeTabViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        
        isBottomSheetInteracting = true
        
        recentRouteCollectionView.allowsSelection = false
        recentSearchPlaceTableView.allowsSelection = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }
        
        isBottomSheetInteracting = false
        lastBottomSheetInteractionDate = Date()
        
        recentSearchPlaceTableView.allowsSelection = true
        recentRouteCollectionView.allowsSelection = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == self.scrollView else { return }
        
        if !decelerate {
            isBottomSheetInteracting = false
            lastBottomSheetInteractionDate = Date()
            
            recentRouteCollectionView.allowsSelection = true
            recentSearchPlaceTableView.allowsSelection = true
        }
    }
}

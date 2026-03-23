//
//  RoutingPanelView.swift
//  ShortPath
//
//  Created by 선상혁 on 3/23/26.
//

import UIKit
import SnapKit

final class RoutingPanelView: UIView {
    
    private var items: [RouteSectionItem] = []
    
    private var routeTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var buttonView = UIView()
    
    private var swapStartDestinationButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    private var closeButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    var onTapSearch: ((RouteSectionItem) -> Void)?
    var onTapDelete: ((RouteSectionItem) -> Void)?
    var onTapAddWayPoint: (() -> Void)?
    var onMoveItem: ((Int, Int) -> Void)?
    var onTapSwap: (() -> Void)?
    
    private var movingSnapShot: UIView?
    private var movingIndexPath: IndexPath?
    private var movingCell: UITableViewCell?
    private var movingOffsetY: CGFloat = 0
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    weak var delegate: RoutingPanelViewDelegate?

    var onHeightChanged: ((CGFloat) -> Void)?
    private var tableViewHeightConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpTableView()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .gray
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        isHidden = true
        
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        
        [closeButton, swapStartDestinationButton].forEach { view in
            buttonStack.addArrangedSubview(view)
        }
        
        [routeTableView, buttonView].forEach { view in
            addSubview(view)
        }
        
        buttonView.addSubview(buttonStack)

        routeTableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalTo(buttonView.snp.leading)
            tableViewHeightConstraint = make.height.equalTo(112).constraint
        }
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(routeTableView.snp.top)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(routeTableView.snp.bottom)
            make.width.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        swapStartDestinationButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        swapStartDestinationButton.translatesAutoresizingMaskIntoConstraints = false

        swapStartDestinationButton.addTarget(self, action: #selector(swapStartDestinationButtonPressed), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func swapStartDestinationButtonPressed() {
        onTapSwap?()
    }
    
    @objc
    private func closeButtonPressed() {
        delegate?.didCloseRoutingPanelView()
    }
    
    private func setUpTableView() {
        routeTableView.delegate = self
        routeTableView.dataSource = self
        routeTableView.isScrollEnabled = false
        routeTableView.register(RoutingTableViewCell.self, forCellReuseIdentifier: RoutingTableViewCell.identifier)

        routeTableView.allowsSelection = true
        routeTableView.tintColor = .black
        routeTableView.backgroundColor = .white
        routeTableView.contentInsetAdjustmentBehavior = .never
        
        routeTableView.backgroundView = {
            let view = UIView()
            
            view.backgroundColor = .gray
            
            return view
        }()
    }
    
    func update(items: [RouteSectionItem]) {
        self.items = items
        routeTableView.reloadData()
        routeTableView.layoutIfNeeded()
        
        let contentHeight = routeTableView.contentSize.height
        let minimumHeight: CGFloat = 112
        let maximumHeight: CGFloat = 280
        
        print("contentHeight: \(contentHeight)")
        
        let tableHeight = min(max(contentHeight, minimumHeight), maximumHeight)
        
        print("tableHeight: \(tableHeight)")
        
        tableViewHeightConstraint?.update(offset: tableHeight)
                
        onHeightChanged?(tableHeight + safeAreaInsets.top)
    }
    
    private func handleDragGesture(_ gesture: UILongPressGestureRecognizer, from cell: UITableViewCell) {
        let location = gesture.location(in: routeTableView)

        switch gesture.state {
        case .began:
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
            
            guard let indexPath = routeTableView.indexPath(for: cell) else { return }
            
            movingIndexPath = indexPath
            movingCell = cell
            
            let snapshot = cell.snapshotView(afterScreenUpdates: false) ?? UIView()
            snapshot.frame = cell.frame
            snapshot.layer.masksToBounds = false
            snapshot.layer.shadowOpacity = 0.15
            snapshot.layer.shadowRadius = 8
            
            movingOffsetY = location.y - cell.frame.origin.y
            
            movingSnapShot = snapshot
            routeTableView.addSubview(snapshot)
            
            cell.isHidden = true
            
        case .changed:
            guard let snapshot = movingSnapShot, let fromIndexPath = movingIndexPath else { return }
            
            var frame = snapshot.frame
            frame.origin.y = location.y - movingOffsetY
            snapshot.frame = frame
            
            guard let toIndexPath = routeTableView.indexPathForRow(at: location), toIndexPath != fromIndexPath else { return }
            
            items.swapAt(fromIndexPath.row, toIndexPath.row)
            onMoveItem?(fromIndexPath.row, toIndexPath.row)
            routeTableView.moveRow(at: fromIndexPath, to: toIndexPath)
            movingIndexPath = toIndexPath
            
        case .ended, .cancelled, .failed:
            finishDragging()
            
        default:
            break
        }
    }
    
    private func finishDragging() {
        guard let snapshot = movingSnapShot, let indexPath = movingIndexPath else {
            cleanUpDraggingState()
            return
        }
        
        guard let cell = routeTableView.cellForRow(at: indexPath) else {
            snapshot.removeFromSuperview()
            cleanUpDraggingState()
            routeTableView.reloadData()
        
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            snapshot.frame = cell.frame
        }, completion: { _ in
            cell.isHidden = false
            snapshot.removeFromSuperview()
            self.cleanUpDraggingState()
        })
    }
    
    private func cleanUpDraggingState() {
        movingCell?.isHidden = false
        movingSnapShot?.removeFromSuperview()
        
        movingSnapShot = nil
        movingCell = nil
        movingIndexPath = nil
        movingOffsetY = 0
    }
}

extension RoutingPanelView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutingTableViewCell.identifier, for: indexPath) as? RoutingTableViewCell else { return RoutingTableViewCell() }

        let item = items[indexPath.row]
        
        cell.bind(with: item)
        
        cell.onTapSearch = { [weak self] in
            guard let self else { return }
            
            self.onTapSearch?(item)
        }
        
        cell.onTapDelete = { [weak self] in
            guard let self else { return }

            self.onTapDelete?(item)
        }
        
        cell.onTapAddWayPoint = { [weak self] in
            guard let self else { return }

            self.onTapAddWayPoint?()
        }
        
        cell.onLongPressDragHandle = { [weak self, weak cell] gesture in
            guard let self, let cell else { return }
            
            self.handleDragGesture(gesture, from: cell)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

//
//  RoutingTableViewCell.swift
//  ShortPath
//
//  Created by 선상혁 on 3/12/26.
//

import UIKit

final class RoutingTableViewCell: UITableViewCell {
    
    static let identifier = "RoutingTableViewCell"
    
    private var placeContainerView: UIView = {
        let view = UIView()
            
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private var placeLabel: UILabel = {
        let view = UILabel()
        
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private var actionContainerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private var addWayPointButton: UIButton = {
        let view = UIButton()
        
        view.tintColor = .black
        view.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        
        return view
    }()
    
    private var deleteButton: UIButton = {
        let view = UIButton()
        
        view.tintColor = .black
        view.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        
        return view
    }()
    
    private var dragHandleImageView: UIImageView = {
        let view = UIImageView()
    
        view.image = UIImage(named: "DragHandleImageView")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .regular))
        view.tintColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    var onLongPressDragHandle: ((UILongPressGestureRecognizer) -> Void)?
    var onTapSearch: (() -> Void)?
    var onTapDelete: (() -> Void)?
    var onTapAddWayPoint: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        contentView.backgroundColor = .lightGray
        clipsToBounds = false
        selectionStyle = .none
        
        [placeContainerView, dragHandleImageView].forEach { view in
            contentView.addSubview(view)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(placeContainerViewPressed))
        
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        
        placeContainerView.addGestureRecognizer(gesture)
        
        [placeLabel, actionContainerView].forEach { view in
            placeContainerView.addSubview(view)
        }
        
        [deleteButton, addWayPointButton].forEach { view in
            actionContainerView.addSubview(view)
        }
        
        let dragHandleGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragHandleLongPressed))
        dragHandleGesture.minimumPressDuration = 0.15
        
        dragHandleImageView.addGestureRecognizer(dragHandleGesture)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        addWayPointButton.addTarget(self, action: #selector(addWayPointButtonPressed), for: .touchUpInside)
        
        placeContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(dragHandleImageView.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(6)
        }
        
        placeLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.verticalEdges.equalToSuperview().inset(6)
        }
        
        actionContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addWayPointButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dragHandleImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        placeLabel.text = ""
        actionContainerView.isHidden = true
    }
    
    @objc
    private func dragHandleLongPressed(_ gesture: UILongPressGestureRecognizer) {
        onLongPressDragHandle?(gesture)
    }
    
    @objc
    private func placeContainerViewPressed() {
        onTapSearch?()
    }
    
    @objc
    private func deleteButtonPressed() {
        onTapDelete?()
    }
    
    @objc
    private func addWayPointButtonPressed() {
        onTapAddWayPoint?()
    }
    
    func bind(with items: RouteSectionItem) {
        if let name = items.place?.name {
            placeLabel.textColor = .black
            placeLabel.text = name
        } else {
            placeLabel.textColor = .gray
            placeLabel.text = items.role.placeHolder
        }
        
        actionContainerView.isHidden = items.role == .start
        deleteButton.isHidden = items.role != .wayPoints
        addWayPointButton.isHidden = items.role != .destination
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        
        if touchedView.isDescendant(of: addWayPointButton) {
            return false
        }
        
        if touchedView.isDescendant(of: deleteButton) {
            return false
        }
        
        if touchedView.isDescendant(of: actionContainerView) {
            return false
        }
        
        return true
    }
}

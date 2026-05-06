//
//  RoutingTableViewCell.swift
//  ShortPath
//
//  Created by 선상혁 on 3/12/26.
//

import UIKit

final class RoutingTableViewCell: UITableViewCell {
    
    static let identifier = "RoutingTableViewCell"
    
    private var placeContainerStackView: UIStackView = {
        let view = UIStackView()
            
        view.backgroundColor = UIColor(hex: "0xF2F2F7")
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 0
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .center
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = .init(top: 0, leading: 14, bottom: 0, trailing: 0)
        
        return view
    }()
    
    private var separatorView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(hex: "0xE5E5EA")
        
        return view
    }()
    
    private var placeLabel: UILabel = {
        let view = UILabel()
        
        view.isUserInteractionEnabled = false
        view.lineBreakMode = .byTruncatingTail
        view.font = .systemFont(ofSize: 15, weight: .semibold)

        return view
    }()
    
    private var actionContainerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private var addWayPointButton: UIButton = {
        let view = UIButton()
        
        view.tintColor = UIColor(hex: "0x0A84FF")
        view.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        
        return view
    }()
    
    private var deleteButton: UIButton = {
        let view = UIButton()
        
        view.tintColor = UIColor(hex: "0xFF3B30")
        view.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        
        return view
    }()
    
    private var dragHandleImageView: UIImageView = {
        let view = UIImageView()
    
        view.image = UIImage(named: "DragHandleImageView")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .regular))
        view.tintColor = UIColor(hex: "0xC7C7CC")
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
        contentView.backgroundColor = .clear
        clipsToBounds = false
        selectionStyle = .none
        
        [placeContainerStackView, separatorView, dragHandleImageView].forEach { view in
            contentView.addSubview(view)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(placeContainerViewPressed))
        
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        
        placeContainerStackView.addGestureRecognizer(gesture)
        
        [placeLabel, actionContainerView].forEach { view in
            placeContainerStackView.addArrangedSubview(view)
        }
        
        [deleteButton, addWayPointButton].forEach { view in
            actionContainerView.addSubview(view)
        }
        
        let dragHandleGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragHandleLongPressed))
        dragHandleGesture.minimumPressDuration = 0.15
        
        dragHandleImageView.addGestureRecognizer(dragHandleGesture)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        addWayPointButton.addTarget(self, action: #selector(addWayPointButtonPressed), for: .touchUpInside)
        
        placeContainerStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(dragHandleImageView.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(6)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(placeContainerStackView.snp.leading).offset(14)
            make.trailing.equalTo(placeContainerStackView.snp.trailing).offset(-14)
            make.bottom.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        actionContainerView.snp.makeConstraints { make in
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
    
    func bind(with items: RouteSectionItem, _ isLast: Bool, _ isLastRow: Bool) {
        if let name = items.place?.name {
            placeLabel.textColor = UIColor(hex: "0x1C1C1E")
            placeLabel.text = name
        } else {
            placeLabel.textColor = UIColor(hex: "0x8E8E93")
            placeLabel.text = items.role.placeHolder
        }
        
        actionContainerView.isHidden = items.role == .start || isLast
        deleteButton.isHidden = items.role != .wayPoint
        addWayPointButton.isHidden = items.role != .destination
        separatorView.isHidden = isLastRow
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

//
//  RouteSummaryView.swift
//  ShortPath
//
//  Created by 선상혁 on 3/28/26.
//

import UIKit

final class RouteSummaryView: UIControl {
        
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .fill
        
        return view
    }()
    
    private let startRowStackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        
        return view
    }()
    
    private let destinationRowStackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        
        return view
    }()
    
    private let startBadgeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "출발"
        view.font = .systemFont(ofSize: 11, weight: .bold)
        view.textColor = UIColor(hex: "0x6E6E73")
        view.textAlignment = .center
        view.backgroundColor = UIColor(hex: "0xF2F2F7")
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        
        return view
    }()
    
    private let destinationBadgeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "도착"
        view.font = .systemFont(ofSize: 11, weight: .bold)
        view.textColor = UIColor(hex: "0x0A84FF")
        view.textAlignment = .center
        view.backgroundColor = UIColor(hex: "0xEAF3FF")
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        
        return view
    }()
    
    private let startPlaceLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 15, weight: .medium)
        view.textColor = UIColor(hex: "0x6E6E73")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private let destinationPlaceLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .bold)
        view.textColor = UIColor(hex: "0x1C1C1E")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private let routeLabel: UILabel = {
        let view = UILabel()
        
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        
        return view
    }()
    
    private let numberOfWayPointsLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = UIColor(hex: "0x8E8E93")
        view.numberOfLines = 1
        
        return view
    }()
    
    private var closeButton: UIButton = {
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = UIColor(hex: "0x1C1C1E")
        config.background.backgroundColor = UIColor(hex: "0xF2F2F7")
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        view.configuration = config
        view.layer.cornerCurve = .continuous
        
        return view
    }()
    
    private var menuButton: UIButton = {
        let view = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "ellipsis")
        config.baseForegroundColor = UIColor(hex: "0x1C1C1E")
        config.background.backgroundColor = UIColor(hex: "0xF2F2F7")
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        view.configuration = config
        view.layer.cornerCurve = .continuous
        
        return view
    }()
    
    private var shadowView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.setShadow()
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        
        return view
    }()
    
    var onTapCloseButton: (() -> Void)?
    var onTapMenuButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isHidden = true
        backgroundColor = .clear
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .center
        buttonStackView.spacing = 8
        
        let mainStackView = UIStackView()
        mainStackView.axis = .horizontal
        mainStackView.spacing = 12
        mainStackView.alignment = .top
        mainStackView.distribution = .fill

        [closeButton, menuButton].forEach { view in
            buttonStackView.addArrangedSubview(view)
        }

        shadowView.isUserInteractionEnabled = false
        contentStackView.isUserInteractionEnabled = false
        
        addSubview(shadowView)
        
        shadowView.addSubview(contentView)
        
        [startBadgeLabel, startPlaceLabel].forEach { view in
            startRowStackView.addArrangedSubview(view)
        }
        
        [destinationBadgeLabel, destinationPlaceLabel].forEach { view in
            destinationRowStackView.addArrangedSubview(view)
        }
        
        [startRowStackView, destinationRowStackView, numberOfWayPointsLabel].forEach { view in
            contentStackView.addArrangedSubview(view)
        }
        
        contentStackView.setCustomSpacing(8, after: destinationRowStackView)
        
        [contentStackView, makeSpacer(), buttonStackView].forEach { view in
            mainStackView.addArrangedSubview(view)
        }
        
        contentView.addSubview(mainStackView)
                
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(8)
        }
        
        startBadgeLabel.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(22)
        }
        
        destinationBadgeLabel.snp.makeConstraints { make in
            make.width.equalTo(36)
            make.height.equalTo(22)
        }

        startBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        startBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        destinationBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        destinationBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        startPlaceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        destinationPlaceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        startRowStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        startRowStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        destinationRowStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        destinationRowStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        mainStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        mainStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        buttonStackView.setContentHuggingPriority(.required, for: .horizontal)
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        menuButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        let menuItems = [
            UIAction(
                title: "저장",
                image: UIImage(systemName: "star.circle"),
                handler: { [weak self] _ in
                    guard let self else { return }
                    
                    onTapMenuButton?()
                })
        ]
        
        menuButton.menu = UIMenu(title: "메뉴", children: menuItems)
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.isHidden = true
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func closeButtonPressed() {
        onTapCloseButton?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0, isUserInteractionEnabled else {
            return nil
        }
        
        let closeButtonPoint = closeButton.convert(point, from: self)
        
        if closeButton.bounds.contains(closeButtonPoint) {
            return closeButton
        }
        
        let favoriteButtonPoint = menuButton.convert(point, from: self)
        
        if menuButton.bounds.contains(favoriteButtonPoint) {
            return menuButton
        }
        
        return super.hitTest(point, with: event)
    }
    
    func bind(start: String?, destination: String?, wayPointsCount: Int) {
        updateRouteTexts(start: start, destination: destination)
        
        if wayPointsCount > 0 {
            numberOfWayPointsLabel.isHidden = false
            numberOfWayPointsLabel.text = "경유지 \(wayPointsCount)개"
        } else {
            numberOfWayPointsLabel.isHidden = true
            numberOfWayPointsLabel.text = nil
        }
    }
    
    private func updateRouteTexts(start: String?, destination: String?) {
        let startIsSet = start != nil
        let destinationIsSet = destination != nil
        
        startPlaceLabel.text = start ?? "출발지를 선택하세요"
        destinationPlaceLabel.text = destination ?? "도착지를 선택하세요"
        
        startPlaceLabel.font = startIsSet ? .systemFont(ofSize: 15, weight: .medium) : .systemFont(ofSize: 15, weight: .regular)
        startPlaceLabel.textColor = startIsSet ? UIColor(hex: "0x6E6E73") : UIColor(hex: "0xC7C7CC")
        
        destinationPlaceLabel.font = destinationIsSet ? .systemFont(ofSize: 16, weight: .bold) : .systemFont(ofSize: 16, weight: .regular)
        destinationPlaceLabel.textColor = destinationIsSet ? UIColor(hex: "0x1C1C1E") : UIColor(hex: "0xC7C7CC")
    }
    
    private func updateRouteLabel(start: String?, destination: String?) {
        let startText = start ?? "출발지 선택"
        let destinationText = destination ?? "도착지 선택"
        
        let startIsSet = start != nil
        let destinationIsSet = destination != nil
        
        let normalFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let placeholderFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        let normalColor = UIColor.black
        let placeholderColor = UIColor.systemGray2
        
        let attributed = NSMutableAttributedString(string: startText, attributes: [
            .font : startIsSet ? normalFont: placeholderFont,
            .foregroundColor: startIsSet ? normalColor: placeholderColor])
        
        attributed.append(
            NSAttributedString(
                string: " → ",
                attributes: [
                    .font: normalFont,
                    .foregroundColor: placeholderColor
                ]
            )
        )
        
        attributed.append(
            NSAttributedString(
                string: destinationText,
                attributes: [
                    .font: destinationIsSet ? normalFont : placeholderFont,
                    .foregroundColor: destinationIsSet ? normalColor : placeholderColor
                ]
            )
        )
        
        routeLabel.attributedText = attributed
    }
    
    func isReadyToSaveRoute(_ isReady: Bool) {
        menuButton.isHidden = !isReady
    }
}

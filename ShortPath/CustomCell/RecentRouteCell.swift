//
//  RecentRouteCell.swift
//  ShortPath
//
//  Created by 선상혁 on 4/14/26.
//

import UIKit

final class RecentRouteCell: UICollectionViewCell {
    
    static let identifier = "RecentRouteCell"

    private let iconContainerView: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor(hex: "0xEAF3FF")
        view.layer.cornerRadius = 14
        view.clipsToBounds = true

        return view
    }()

    private var routeImageView: UIImageView = {
        let view = UIImageView()

        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(hex: "0x0A84FF")

        return view
    }()
    
    private var startBadgeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "출발"
        view.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        view.textColor = UIColor(hex: "0x6E6E73")
        view.textAlignment = .center
        view.backgroundColor = UIColor(hex: "0xF2F2F7")
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    
    private var destinationBadgeLabel: UILabel = {
        let view = UILabel()
        
        view.text = "도착"
        view.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        view.textColor = UIColor(hex: "0x0A84FF")
        view.textAlignment = .center
        view.backgroundColor = UIColor(hex: "0xEAF3FF")
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    
    private var startLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        view.textColor = UIColor(hex: "0x6E6E73")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private var arrowLabel: UILabel = {
        let view = UILabel()
        
        view.text = "→"
        view.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        view.textColor = UIColor(hex: "0xC7C7CC")
        view.textAlignment = .center
        
        return view
    }()
    
    private var destinationLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        view.textColor = UIColor(hex: "0x1C1C1E")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private var routeTitleLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        view.textColor = UIColor(hex: "0x1C1C1E")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private var routeSubTitleLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor(hex: "0x8E8E93")
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        
        return view
    }()
    
    private let menuButton: UIButton = {
        let view = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "ellipsis")
        configuration.baseForegroundColor = UIColor(hex: "0x8E8E93")
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        view.configuration = configuration
        
        return view
    }()
    
    private var distanceLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        view.textColor = UIColor(hex: "0x0A84FF")
        view.numberOfLines = 1
        
        return view
    }()
    
    var onTapMenu: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let topStackView = UIStackView()
        let routeTextStackView = UIStackView()
        let startRowStackView = UIStackView()
        let destinationRowStackView = UIStackView()
        
        topStackView.axis = .horizontal
        topStackView.spacing = 10
        topStackView.alignment = .top
        
        routeTextStackView.axis = .vertical
        routeTextStackView.spacing = 4
        routeTextStackView.alignment = .fill
        
        startRowStackView.axis = .horizontal
        startRowStackView.spacing = 6
        startRowStackView.alignment = .center
        
        destinationRowStackView.axis = .horizontal
        destinationRowStackView.spacing = 6
        destinationRowStackView.alignment = .center

        iconContainerView.addSubview(routeImageView)
        
        [startBadgeLabel, startLabel].forEach { view in
            startRowStackView.addArrangedSubview(view)
        }
        
        [destinationBadgeLabel, destinationLabel].forEach { view in
            destinationRowStackView.addArrangedSubview(view)
        }
        
        [startRowStackView, destinationRowStackView, routeSubTitleLabel].forEach { view in
            routeTextStackView.addArrangedSubview(view)
        }
        
        routeTextStackView.setCustomSpacing(8, after: destinationRowStackView)
        
        [iconContainerView, routeTextStackView].forEach { view in
            topStackView.addArrangedSubview(view)
        }
        
        [topStackView, distanceLabel, menuButton].forEach { view in
            contentView.addSubview(view)
        }
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().inset(14)
        }

        iconContainerView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        routeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }
        
        startBadgeLabel.snp.makeConstraints { make in
            make.width.equalTo(34)
            make.height.equalTo(20)
        }
        
        destinationBadgeLabel.snp.makeConstraints { make in
            make.width.equalTo(34)
            make.height.equalTo(20)
        }
        
        startBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        startBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        destinationBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        destinationBadgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        startLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        startLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        destinationLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        destinationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(8)
            make.size.equalTo(44)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(routeSubTitleLabel.snp.bottom).offset(6)
            make.leading.equalTo(topStackView.snp.leading)
            make.trailing.lessThanOrEqualTo(menuButton.snp.leading).offset(-8)
            make.centerY.equalTo(menuButton.snp.centerY)
        }

        menuButton.setContentHuggingPriority(.required, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        iconContainerView.setContentHuggingPriority(.required, for: .horizontal)
        iconContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
        
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 0
        contentView.backgroundColor = .white
    }
    
    @objc
    private func menuButtonPressed() {
        onTapMenu?()
    }
    
    private func routeDisplayTexts(from title: String, fallbackSubtitle: String?) -> (start: String, destination: String, waypointText: String?) {
        let normalizedTitle = title.replacingOccurrences(of: " -> ", with: "→")
        let routeNames = normalizedTitle
            .components(separatedBy: "→")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard routeNames.count >= 2,
              let startName = routeNames.first,
              let destinationName = routeNames.last else {
            return ("출발지", title, fallbackSubtitle)
        }
        
        let waypointCount = max(routeNames.count - 2, 0)
        let waypointText = waypointCount > 0 ? "경유지 \(waypointCount)개" : fallbackSubtitle
        
        return (startName, destinationName, waypointText)
    }
    
    func bind(_ item: RecentRouteItem, distance: Int) {
        routeSubTitleLabel.text = nil
        startLabel.text = nil
        destinationLabel.text = nil

        iconContainerView.isHidden = true
        startBadgeLabel.isHidden = false
        startLabel.isHidden = false
        destinationBadgeLabel.isHidden = false
        destinationLabel.isHidden = false

        switch item {
        case .currentLocationDestination(_):
            iconContainerView.isHidden = false
            startBadgeLabel.isHidden = true
            startLabel.isHidden = true
            destinationBadgeLabel.isHidden = true
            destinationLabel.isHidden = false

            iconContainerView.backgroundColor = UIColor(hex: "0xEAF3FF")
            routeImageView.tintColor = UIColor(hex: "0x0A84FF")
            routeImageView.image = UIImage(named: "RecentRoute")?.withRenderingMode(.alwaysTemplate)

            let displayTexts = routeDisplayTexts(from: item.titleText, fallbackSubtitle: nil)
            destinationLabel.text = displayTexts.destination
            routeSubTitleLabel.text = "현재 위치에서 출발"
            routeSubTitleLabel.isHidden = false

            distanceLabel.text = DistanceFormatter.string(from: distance)

        case .presetRoute(let presetRecentRoute):
            let displayTexts = routeDisplayTexts(from: item.titleText, fallbackSubtitle: item.subtitleText)
            startLabel.text = displayTexts.start
            destinationLabel.text = displayTexts.destination
            routeSubTitleLabel.text = displayTexts.waypointText
            routeSubTitleLabel.isHidden = displayTexts.waypointText == nil

            let distance = presetRecentRoute.distance

            distanceLabel.text = DistanceFormatter.string(from: distance)
        }
    }
}

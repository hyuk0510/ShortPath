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
    
    private let routeLabel: UILabel = {
        let view = UILabel()
        
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        
        return view
    }()
    
    private let numberOfWayPointsLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = .gray
        view.numberOfLines = 1
        
        return view
    }()
    
    private var closeButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    private var shadowView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.setShadow()
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private var contentView : UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(hex: "0xF5F5F5")
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    var onTapCloseButton: (() -> Void)?
    
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
        
        shadowView.isUserInteractionEnabled = false
        contentStackView.isUserInteractionEnabled = false
        
        addSubview(shadowView)
        
        shadowView.addSubview(contentView)
        
        [routeLabel, numberOfWayPointsLabel].forEach { view in
            contentStackView.addArrangedSubview(view)
        }
        
        [contentStackView, closeButton].forEach { view in
            contentView.addSubview(view)
        }
                
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 60))
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12)
            make.size.equalTo(44)
        }
        
        contentView.bringSubviewToFront(closeButton)
        
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
        
        return super.hitTest(point, with: event)
    }
    
    func bind(start: String?, destination: String?, wayPointsCount: Int) {
        updateRouteLabel(start: start, destination: destination)
        
        if wayPointsCount > 0 {
            numberOfWayPointsLabel.isHidden = false
            numberOfWayPointsLabel.text = "경유지 \(wayPointsCount)개"
        } else {
            numberOfWayPointsLabel.isHidden = true
            numberOfWayPointsLabel.text = nil
        }
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
}

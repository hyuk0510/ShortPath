//
//  DistanceTimeView.swift
//  ShortPath
//
//  Created by 선상혁 on 6/2/26.
//

import UIKit

final class DistanceTimeView: UIView {
    
    private let iconContainerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(hex: "0xEAF3FF")
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let view = UIImageView(image: UIImage(systemName: "car.fill", withConfiguration: configuration))
        
        view.tintColor = UIColor(hex: "0x0A84FF")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private let timeLabel: UILabel = {
        let view = UILabel()
        
        view.textColor = UIColor(hex: "0x1C1C1E")
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.85
        
        return view
    }()
    
    private let detailLabel: UILabel = {
        let view = UILabel()
        
        view.text = "차량 기준"
        view.textColor = UIColor(hex: "0x8E8E93")
        view.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.85
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isHidden = true
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "0xE5E5EA").cgColor
        clipsToBounds = true
        
        let textStackView = UIStackView(arrangedSubviews: [timeLabel, detailLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 2
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        
        addSubview(iconContainerView)
        addSubview(textStackView)
        iconContainerView.addSubview(iconImageView)
        
        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }
        
        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func bind(distance: Int, duration: Int) {
        let distanceText = DistanceFormatter.string(from: distance)
        let minutes = max(Int(ceil(Double(duration) / 60.0)), 1)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        let timeText = hours > 0 ? "약 \(hours)시간 \(remainingMinutes)분" : "약 \(minutes)분"

        timeLabel.text = timeText
        detailLabel.text = "\(distanceText) ･ 차량 기준"
    }
}

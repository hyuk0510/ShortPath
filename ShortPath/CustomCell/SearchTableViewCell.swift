//
//  CustomTableViewCell.swift
//  ShortPath
//
//  Created by 선상혁 on 2/8/26.
//

import UIKit
import CoreLocation

final class SearchTableViewCell: UITableViewCell {
    
    static let identifier = "CustomTableViewCell"
    
    lazy var leftImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "magnifyingglass")
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        
        view.snp.makeConstraints { make in
            make.width.equalTo(32)
        }
        
        return view
    }()
    
    lazy var placeNameLabel = {
        let view = UILabel()
        
        view.textColor = .black
        view.font = .systemFont(ofSize: 16)
        view.numberOfLines = 1
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.lineBreakMode = .byTruncatingTail
        
        return view
    }()
    
    lazy var categoryLabel = {
        let view = UILabel()
        
        view.textColor = .gray
        view.font = .systemFont(ofSize: 12)
        view.numberOfLines = 1
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return view
    }()
    
    lazy var distanceAddressLabel = {
        let view = UILabel()
        
        view.textColor = .gray
        view.font = .systemFont(ofSize: 14)
        view.numberOfLines = 1
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.backgroundColor = .white
        
        let topStackView = UIStackView(arrangedSubviews: [placeNameLabel, categoryLabel])
        let bottomStackView = UIStackView(arrangedSubviews: [distanceAddressLabel])
        let rightStackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
        let stackView = UIStackView(arrangedSubviews: [leftImageView, rightStackView])
        
        topStackView.axis = .horizontal
        topStackView.alignment = .center
        topStackView.distribution = .fill
        topStackView.isLayoutMarginsRelativeArrangement = true
        topStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        topStackView.spacing = 4
        
        bottomStackView.axis = .horizontal
        
        rightStackView.axis = .vertical
        rightStackView.spacing = 4
        rightStackView.alignment = .leading
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
    }
}

extension SearchTableViewCell {
    func bind(place: Place) {
        let dis = DistanceFormatter.string(from: place.distance ?? 0)
        let add = place.roadAddress ?? ""
        let category = CategoryFormatter.string(from: place.category)
        
        placeNameLabel.text = place.name
        categoryLabel.text = category
        distanceAddressLabel.text = add == "" ? dis: dis + " ･ " + add
    }
}

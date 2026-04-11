//
//  FavoritePlaceCell.swift
//  ShortPath
//
//  Created by 선상혁 on 4/11/26.
//

import UIKit

final class FavoritePlaceCell: UITableViewCell {
        
    static let identifier = "FavoritePlaceCell"
    
    private let placeImageView: UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(named: "FavoritePoiImage")
        
        return view
    }()
    
    private var nameLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .bold)
        view.textColor = .black
        view.numberOfLines = 0
        
        return view
    }()
    
    private var categoryLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = .gray
        
        return view
    }()
    
    private var distanceAddressLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .gray
        
        return view
    }()
    
    private var menuButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    var onTapMenuButton: (() -> Void)?
            
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        
        let horizontalStackView = UIStackView()
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 6
        
        [nameLabel, categoryLabel, makeSpacer() ,menuButton].forEach { view in
            horizontalStackView.addArrangedSubview(view)
        }
        
        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
        menuButton.setContentHuggingPriority(.required, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let verticalStackView = UIStackView()
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 6
        
        [horizontalStackView, distanceAddressLabel].forEach { view in
            verticalStackView.addArrangedSubview(view)
        }
        
        contentView.addSubview(verticalStackView)
        
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    @objc
    private func menuButtonPressed() {
        onTapMenuButton?()
    }
    
    func bind(_ place: FavoritePlace, _ distance: Int?) {
        nameLabel.text = place.name
        categoryLabel.text = CategoryFormatter.string(from: place.category)
        
        guard let distance = distance, distance != 0 else {
            distanceAddressLabel.text = "제공하지 않음" + " ･" + (place.roadAddress ?? "제공하지 않음")
            
            return
        }
        
        distanceAddressLabel.text = DistanceFormatter.string(from: distance) + " ･" + (place.roadAddress ?? "제공하지 않음")
    }
    
    private func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        
        if touchedView.isDescendant(of: menuButton) {
            return false
        }
        
        return true
    }
}

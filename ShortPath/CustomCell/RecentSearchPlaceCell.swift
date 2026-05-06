//
//  RecentSearchPlaceCell.swift
//  ShortPath
//
//  Created by 선상혁 on 4/15/26.
//

import UIKit

final class RecentSearchPlaceCell: UITableViewCell {
    
    private var placeImageView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private var placeNameLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textColor = .black
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        
        return view
    }()
    
    private var favoriteButton: UIButton = {
        let view = UIButton()
        
        return view
    }()
    
    private var routingButton: UIButton = {
        let view = UIButton()
        var configure = UIButton.Configuration.plain()

        configure.image = UIImage(named: "RecentPlaceRoutingButton")?.resized(to: CGSize(width: 40, height: 40))

        view.configuration = configure
    
        return view
    }()
    
    static let identifier = "RecentSearchPlaceCell"
    
    var onTapFavorite: (() -> Void)?
    var onTapRouting: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.backgroundColor = .white

        let containerStackView = UIStackView()
        
        containerStackView.axis = .horizontal
        containerStackView.spacing = 8
        
        let leadingStackView = UIStackView()
        
        leadingStackView.axis = .horizontal
        leadingStackView.spacing = 8
        
        let buttonStackView = UIStackView()

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.alignment = .center
        
        [leadingStackView, makeSpacer(), buttonStackView].forEach { view in
            containerStackView.addArrangedSubview(view)
        }
        
        contentView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        [placeImageView, placeNameLabel].forEach { view in
            leadingStackView.addArrangedSubview(view)
        }
        
        [favoriteButton, routingButton].forEach { view in
            buttonStackView.addArrangedSubview(view)
        }
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        routingButton.addTarget(self, action: #selector(routingButtonPressed), for: .touchUpInside)
        
        placeImageView.setContentHuggingPriority(.required, for: .horizontal)
        placeImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        placeNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        placeNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        routingButton.setContentHuggingPriority(.required, for: .horizontal)
        routingButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        favoriteButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        routingButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        leadingStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    @objc
    private func favoriteButtonPressed() {
        onTapFavorite?()
    }
    
    @objc
    private func routingButtonPressed() {
        onTapRouting?()
    }
    
    func bind(_ item: RecentPlaceItem) {
        placeImageView.image = item.isFavorite ? UIImage(named: "FavoritePoiImage")?.resized(to: CGSize(width: 32, height: 32)) : UIImage(named: "SearchTableViewCellLeftView")
        placeNameLabel.text = item.place.name
        
        updateFavoriteUI(isFavorite: item.isFavorite)
    }
    
    private func updateFavoriteUI(isFavorite: Bool) {
        var configure = UIButton.Configuration.plain()
        
        configure.image = isFavorite ? UIImage(named: "RecentPlaceFavoriteButton") : UIImage(named: "RecentPlaceFavoriteButton.unSelected")
        
        favoriteButton.configuration = configure
    }
}

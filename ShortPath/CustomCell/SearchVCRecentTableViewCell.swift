//
//  SearchVCRecentTableViewCell.swift
//  ShortPath
//
//  Created by 선상혁 on 4/18/26.
//

import UIKit

final class SearchVCRecentTableViewCell: UITableViewCell {
    
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
    
    private let dateLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.textColor = .lightGray
        
        return view
    }()
    
    private var deleteButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        view.tintColor = .black
        
        return view
    }()
    
    var onTapDeletebutton: (() -> Void)?
    
    static let identifier = "SearchVCRecentTableViewCell"
    
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
        
        let trailingStackView = UIStackView()
        
        trailingStackView.axis = .horizontal
        trailingStackView.spacing = 8
        
        [leadingStackView, makeSpacer(), trailingStackView].forEach { view in
            containerStackView.addArrangedSubview(view)
        }
        
        contentView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        [placeImageView, placeNameLabel].forEach { view in
            leadingStackView.addArrangedSubview(view)
        }
        
        [dateLabel, deleteButton].forEach { view in
            trailingStackView.addArrangedSubview(view)
        }
        
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        placeNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        placeNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        deleteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(32)
        }
        
        leadingStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        
        trailingStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
    }
    
    @objc
    private func deleteButtonPressed() {
        onTapDeletebutton?()
    }
    
    func bind(_ item: RecentPlaceItem) {
        placeImageView.image = item.isFavorite ? UIImage(named: "FavoritePoiImage")?.resized(to: CGSize(width: 32, height: 32)) : UIImage(named: "SearchTableViewCellLeftView")
        placeNameLabel.text = item.place.name
        
        dateLabel.text = DateFormatter.recentDateFormatter.string(from: item.searchedAt)
    }
}

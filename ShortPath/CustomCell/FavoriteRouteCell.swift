//
//  FavoriteRouteCell.swift
//  ShortPath
//
//  Created by 선상혁 on 4/11/26.
//

import UIKit

final class FavoriteRouteCell: UITableViewCell {
    
    static let identifier = "FavoriteRouteCell"
    
    private var titleLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .bold)
        view.textColor = .black
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        
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
        
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 6
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        [titleLabel, menuButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
        menuButton.setContentHuggingPriority(.required, for: .horizontal)
        menuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    @objc
    private func menuButtonPressed() {
        onTapMenuButton?()
    }
    
    func bind(_ object: FavoriteRouteObject) {
        titleLabel.text = object.title
    }
}

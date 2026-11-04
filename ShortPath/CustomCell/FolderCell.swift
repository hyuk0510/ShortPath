//
//  FolderCell.swift
//  ShortPath
//
//  Created by 선상혁 on 9/11/26.
//

import UIKit
import SnapKit

final class FolderCell: UITableViewCell {
    
    static let identifier = "FolderCell"
    
    private let folderIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "folder.fill")
        view.tintColor = UIColor(hex: "0x3A7BD5")
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let menuButton: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.baseForegroundColor = UIColor(hex: "0x8E8E93")
        view.configuration = config
        return view
    }()
    
    var onTapDelete: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        
        [folderIconView, nameLabel, countLabel, menuButton].forEach { contentView.addSubview($0) }
        
        folderIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(folderIconView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    func bind(name: String, count: Int? = nil, showDeleteButton: Bool = false) {
        nameLabel.text = name
        
        if let count {
            countLabel.text = "\(count)개"
            countLabel.isHidden = false
        } else {
            countLabel.isHidden = true
        }
        
        guard showDeleteButton else {
            menuButton.isHidden = true
            menuButton.menu = nil
            return
        }
        
        menuButton.isHidden = false
        
        let deleteAction = UIAction(
            title: "폴더 삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                guard let self else { return }
                
                onTapDelete?()
            })
        
        menuButton.menu = UIMenu(title: "", children: [deleteAction])
    }
}

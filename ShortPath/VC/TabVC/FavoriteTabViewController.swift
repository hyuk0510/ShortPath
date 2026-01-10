//
//  FavoriteTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

final class FavoriteTabViewController: UIViewController {
    
    private let label = {
        let view = UILabel()
        view.text = "즐겨찾기"
        view.textColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
        }
    }
}

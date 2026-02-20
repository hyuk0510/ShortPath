//
//  PlaceDetailViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit

final class PlaceDetailViewController: UIViewController {
    
    private let label = {
        let view = UILabel()
        view.text = "장소"
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

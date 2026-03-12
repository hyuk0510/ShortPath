//
//  SaveFavoriteViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 3/5/26.
//

import UIKit

final class SaveFavoriteViewController: UIViewController {
    
    private var closeButton: UIButton = {
        let view = UIButton()
        
        view.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brown
        
        configure()
    }
    
    private func configure() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
    }
    
    @objc
    private func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    
}

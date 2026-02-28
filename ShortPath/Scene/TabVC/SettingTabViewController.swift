//
//  SettingTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

final class SettingTabViewController: UIViewController, BottomSheetInteractable {
    
    var scrollView = UIScrollView()
    private var contentStackView = UIStackView()

    var trackingScrollView: UIScrollView? {
        return scrollView
    }
    
    private let label = {
        let view = UILabel()
        view.text = "설정"
        view.textColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
        }
    }
}

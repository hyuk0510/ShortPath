//
//  HomeTabViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/23/25.
//

import UIKit

final class HomeTabViewController: UIViewController, BottomSheetInteractable {
    
    var scrollView = UIScrollView()
    private var contentStackView = UIStackView()
    
    var trackingScrollView: UIScrollView? {
        return scrollView
    }
    
    private let label = {
        let view = UILabel()
        view.text = "홈"
        view.textColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        configure()
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
                
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        
        contentStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        contentStackView.addArrangedSubview(label)
    }
}

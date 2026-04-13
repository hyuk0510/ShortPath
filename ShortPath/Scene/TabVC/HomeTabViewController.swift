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
    
    private let searchHeaderView = UIView()
    private let quickActionView = UIView()
    private let recentRouteSectionView = UIView()
    
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
            make.bottom.equalToSuperview().inset(100)
        }
                
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        
        contentStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
    }
}

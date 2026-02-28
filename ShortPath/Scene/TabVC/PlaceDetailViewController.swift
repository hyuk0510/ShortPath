//
//  PlaceDetailViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 2/20/26.
//

import UIKit

final class PlaceDetailViewController: UIViewController, BottomSheetInteractable {
    
    var scrollView = UIScrollView()
    private var contentStackView = UIStackView()
    
    var trackingScrollView: UIScrollView? {
        return scrollView
    }
        
    var place: Document?
        
    private var placeNameLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 22, weight: .bold)
        view.textColor = .black
        view.numberOfLines = 0
        
        return view
    }()
    
    private var categoryNameLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = .gray
        
        return view
    }()
    
    private var addressTitleLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .gray
        view.text = "도로명 주소"
        
        return view
    }()
    
    private var placeAddressLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.numberOfLines = 0
        view.textColor = .black
        
        return view
    }()
    
    private var telNumberTitleLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .gray
        view.text = "전화번호"
        
        return view
    }()
    
    private var telNumber: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        
        return view
    }()
    
    private var testlabel: UILabel = {
        let view = UILabel()
        view.text = "ahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahah"
        view.textColor = .green
        view.numberOfLines = 40
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        bind()
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        
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
        
        setUpHeaderSection()
        setUpAddressSection()
        setUpTelSection()
        contentStackView.addArrangedSubview(testlabel)
    }
    
    private func setUpHeaderSection() {
        let headerContainer = UIStackView()
        headerContainer.axis = .vertical
        headerContainer.spacing = 6
        
        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        
        placeNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        topRow.addArrangedSubview(placeNameLabel)
        
        headerContainer.addArrangedSubview(topRow)
        headerContainer.addArrangedSubview(categoryNameLabel)
        
        contentStackView.addArrangedSubview(headerContainer)
    }
    
    private func setUpAddressSection() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        
        stack.addArrangedSubview(addressTitleLabel)
        stack.addArrangedSubview(placeAddressLabel)
        
        contentStackView.addArrangedSubview(stack)
    }
    
    private func setUpTelSection() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        
        stack.addArrangedSubview(telNumberTitleLabel)
        stack.addArrangedSubview(telNumber)
        
        contentStackView.addArrangedSubview(stack)
    }
    
    func bind() {
        guard let place = place else { return }
        
        placeNameLabel.text = place.placeName
        categoryNameLabel.text = place.categoryName
        placeAddressLabel.text = place.roadAddressName
        telNumber.text = place.phone
    }
}

extension PlaceDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
}

//
//  BottomSheetView.swift
//  ShortPath
//
//  Created by 선상혁 on 1/2/26.
//

import UIKit

enum Mode {
    case max
    case medium
    case tip
}

enum Const {
    static let bottomSheetRatio: (Mode) -> Double = { mode in
        switch mode {
        case .max:
            return 0.2
        case .medium:
            return 0.5
        case .tip:
            return 0.9
        }
    }
    
    static let bottomSheetYPosition: (Mode) -> Double = { mode in
        Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
    }
}

final class BottomSheetView: UIView {
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(barView)
        backgroundColor = .white
        
        barView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.size.equalTo(CGSize(width: UIScreen.main.bounds.width * 0.1, height: 4))
        }
        
    }
}

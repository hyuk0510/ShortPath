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
    static let bottomSheetRatio: (Mode, SheetMode) -> Double = { (mode, sheetMode) in
        switch (mode, sheetMode) {
        case (.max, .home):
            return 0.2
        case (.medium, .home), (.medium, .placeDetail), (.max, .placeDetail):
            return 0.5
        case (.tip, .home):
            return 0.9
        case (.tip, .placeDetail):
            return 0.7
        case (_, .routing):
            return 0
        }
    }
    
    static let bottomSheetYPosition: (Mode, SheetMode) -> Double = { (mode, sheetMode) in
        Self.bottomSheetRatio(mode, sheetMode) * UIScreen.main.bounds.height
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
        translatesAutoresizingMaskIntoConstraints = false
        
        barView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.size.equalTo(CGSize(width: UIScreen.main.bounds.width * 0.1, height: 4))
        }
        
    }
}

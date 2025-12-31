//
//  BottomSheetViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 12/29/25.
//

import UIKit
import SnapKit

enum Mode {
    case max
    case medium
    case tip
}

class BottomSheetViewController: UIViewController {
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        hidesBottomBarWhenPushed = false
    }
    
    
}

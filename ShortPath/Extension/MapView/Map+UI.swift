//
//  Map+UI.swift
//  ShortPath
//
//  Created by 선상혁 on 12/12/25.
//

import UIKit
import KakaoMapsSDK

extension MapViewController {
    
    var button: UIButton {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "noti")
        view.configuration = config
        return view
    }
    
    var poiView: UIView {
        let view = UIView(frame: .init(x: 50, y: 50, width: 50, height: 50))
        view.backgroundColor = .green
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin_green")
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }
    
    var poiBadgeView: UIView {
        let view = UIView(frame: .init(x: 15, y: 15, width: 15, height: 15))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noti")
        imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        return view
    }
}

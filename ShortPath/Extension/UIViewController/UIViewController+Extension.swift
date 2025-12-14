//
//  UIViewController+Extension.swift
//  ShortPath
//
//  Created by 선상혁 on 12/14/25.
//

import UIKit

extension UIViewController {
    
    func errorAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}

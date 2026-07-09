//
//  SettingHostingController.swift
//  ShortPath
//

import UIKit
import SwiftUI

final class SettingHostingController: UIHostingController<SettingView>, BottomSheetInteractable {

    private weak var _trackingScrollView: UIScrollView?

    var trackingScrollView: UIScrollView? {
        if _trackingScrollView == nil {
            _trackingScrollView = findScrollView(in: view)
        }
        return _trackingScrollView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _trackingScrollView == nil {
            _trackingScrollView = findScrollView(in: view)
        }
    }

    private func findScrollView(in view: UIView) -> UIScrollView? {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
            if let found = findScrollView(in: subview) {
                return found
            }
        }
        return nil
    }
}

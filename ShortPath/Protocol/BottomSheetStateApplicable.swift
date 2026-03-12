//
//  BottomSheetStateApplicable.swift
//  ShortPath
//
//  Created by 선상혁 on 3/12/26.
//

import Foundation

protocol BottomSheetStateApplicable: AnyObject {
    func changedBottomSheetState(_ state: Mode)
}

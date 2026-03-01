//
//  SearchViewControllerDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 2/16/26.
//

import Foundation

protocol SearchViewControllerDelegate: AnyObject {
    func didSelectedPlace(place: Document)
    func didDisappear()
}

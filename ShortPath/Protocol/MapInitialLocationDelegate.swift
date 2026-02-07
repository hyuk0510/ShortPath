//
//  MapInitialLocationDelegate.swift
//  ShortPath
//
//  Created by 선상혁 on 2/5/26.
//

import UIKit

protocol MapInitialLocationDelegate: AnyObject {
    func mapViewControllerDidReceivedInitialLocation(_ mapVC: MapViewController)
}

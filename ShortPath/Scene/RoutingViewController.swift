//
//  RoutingViewController.swift
//  ShortPath
//
//  Created by 선상혁 on 3/7/26.
//

import UIKit

final class RoutingViewController: UIViewController {
    
    var currentRouteDraft: RouteDraft?
    
    private var routeTableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        view.backgroundColor = .white
        view.addSubview(routeTableView)
    }
    
    func addStartPlace(place: Place) {
        currentRouteDraft?.start = place
    }
    
    func addWayPoint(place: Place) {
        currentRouteDraft?.waypoints.append(place)
    }
    
    func addDestination(place: Place) {
        currentRouteDraft?.destination = place
    }
}

extension RoutingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let route = currentRouteDraft else { return 2 }
        return route.routeCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

//
//  FavoriteFolder.swift
//  ShortPath
//
//  Created by 선상혁 on 9/11/26.
//

import Foundation
import RealmSwift

final class FavoriteFolder: Object {
    @Persisted(primaryKey: true) var name: String
    @Persisted var createdAt = Date()

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

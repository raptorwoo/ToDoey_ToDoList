//
//  Category.swift
//  Todoey
//
//  Created by Jihwan Kim on 2020/02/24.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colorHexString: String = ""
    
    let items = List<Item>()
}

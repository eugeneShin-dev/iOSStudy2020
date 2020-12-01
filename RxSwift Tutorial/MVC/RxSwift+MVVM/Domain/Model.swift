//
//  Model.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation

struct Response: Decodable {
    var menus: [MenuItem]
}

struct MenuItem: Decodable {
    var name: String
    var price: Int
}

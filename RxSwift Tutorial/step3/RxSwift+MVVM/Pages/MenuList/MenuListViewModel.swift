//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by Hailey on 2020/12/04.
//  Copyright © 2020 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    var menus: [Menu] = [
        Menu(name: "젤리", price: 2000, count: 0),
        Menu(name: "초코", price: 2500, count: 0),
        Menu(name: "썬칩", price: 1500, count: 0),
        Menu(name: "몽슈슈", price: 2000, count: 0),
    ]
    
    var itemsCount: Int = 0
    var totalPrice: Observable<Int> = Observable.just(10_000)
}

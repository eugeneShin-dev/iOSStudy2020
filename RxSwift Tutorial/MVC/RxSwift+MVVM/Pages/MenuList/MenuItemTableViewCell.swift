//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    var changeCount: ((Int) -> (Void)) = { _ in }
    
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!
    
    var countNumber: Int = 0 {
        didSet {
            count.text = "\(countNumber)"
        }
    }
    
    public func setCellInfo(name: String, price: Int) {
        title.text = name
        count.text = "\(countNumber)"
        self.price.text = "\(price)"
    }
    
    public func resetCell() {
        countNumber = 0
    }
    
    @IBAction func onIncreaseCount() {
        countNumber += 1
        changeCount(1)
    }

    @IBAction func onDecreaseCount() {
        guard countNumber > 0 else { return }
        let result = countNumber - 1
        countNumber = result >= 0 ? result : 0
        changeCount(-1)
    }
}

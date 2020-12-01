//
//  OrderViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    // MARK: - Life Cycle
    var selectedMenu: [(MenuItem, Int)] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemPrice = selectedMenu.compactMap({$0.0.price * $0.1}).reduce(0, +)
        let vatPrice = Int(Float(itemPrice) * 0.1 / 10 + 0.5) * 10
        let totalPrice = itemPrice + vatPrice
        
        self.itemsPrice.text = "\(itemPrice)"
        self.vatPrice.text = "\(vatPrice)"
        self.totalPrice.text = "\(totalPrice)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nameList = selectedMenu.compactMap({"\($0.0.name) \($0.1)개"})
        let orderListString = nameList.joined(separator: "\n")
        ordersList.text = orderListString
        
        updateTextViewHeight()
    }

    // MARK: - UI Logic

    func updateTextViewHeight() {
        let text = ordersList.text ?? ""
        let width = ordersList.bounds.width
        let font = ordersList.font ?? UIFont.systemFont(ofSize: 20)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        let height = boundingBox.height

        ordersListHeight.constant = height + 40
    }

    // MARK: - Interface Builder

    @IBOutlet var ordersList: UITextView!
    @IBOutlet var ordersListHeight: NSLayoutConstraint!
    @IBOutlet var itemsPrice: UILabel!
    @IBOutlet var vatPrice: UILabel!
    @IBOutlet var totalPrice: UILabel!
}

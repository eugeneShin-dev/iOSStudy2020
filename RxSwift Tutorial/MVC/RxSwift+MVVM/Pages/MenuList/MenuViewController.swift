//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
    let menuNameList = ["라면", "떡라면", "치즈라면", "라볶이"]
    let menuPriceList = [3000, 4000, 3500, 4500]
    var totalPriceNumber: Int = 0 {
        didSet {
            totalPrice.text = "\(totalPriceNumber)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalPrice.text = "\(totalPriceNumber)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
        performSegue(withIdentifier: "OrderViewController", sender: nil)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
        let index = indexPath.row
        cell.setCellInfo(name: menuNameList[index], price: menuPriceList[index])
        cell.changeCount = { [weak self] offset in
            var priceResult = self?.totalPriceNumber ?? 0
            let menuPrice = self?.menuPriceList[index] ?? 0
            if offset > 0 {
                priceResult += menuPrice
            } else {
                priceResult = (priceResult - menuPrice) > 0 ? (priceResult - menuPrice) : 0
            }
            self?.totalPriceNumber = priceResult
        }
        return cell
    }
}

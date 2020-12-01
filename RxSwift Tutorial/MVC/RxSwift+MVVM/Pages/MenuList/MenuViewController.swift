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
    
//    let menuNameList = ["라면", "떡라면", "치즈라면", "라볶이"]
//    let menuPriceList = [3000, 4000, 3500, 4500]
    var menuList: [(MenuItem, Int)] = []
    var totalPriceNumber: Int = 0 {
        didSet {
            totalPrice.text = "\(totalPriceNumber)"
        }
    }
    var numberOfItems: Int = 0 {
        didSet {
            itemCountLabel.text = "\(numberOfItems)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSelectedMenu()
        totalPrice.text = "\(totalPriceNumber)"
        initSelectedMenu()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            orderVC.selectedMenu = menuList.filter({ $0.1 > 0 })
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    func initSelectedMenu() {
        APIService.fetchAllMenus {[weak self] result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let menuList = try? decoder.decode(Response.self, from: data) {
                    self?.menuList = menuList.menus.map({ ($0, 0) })
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                self?.showAlert("오류", "데이터 로드 중 오류 발생")
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        totalPriceNumber = 0
        
        for index in 0..<menuList.count {
            menuList[index].1 = 0
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MenuItemTableViewCell {
                cell.resetCell()
            }
        }
        tableView.reloadData()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
        guard totalPriceNumber > 0 else {
            showAlert("실패", "메뉴를 담아주세요!")
            return
        }
        performSegue(withIdentifier: "OrderViewController", sender: nil)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
        let index = indexPath.row
        let menu = menuList[index].0
        cell.setCellInfo(name: menu.name, price: menu.price)
        cell.changeCount = { [weak self] offset in
            var priceResult = self?.totalPriceNumber ?? 0
            let menuPrice = menu.price
            if offset > 0 {
                self?.numberOfItems += 1
                priceResult += menuPrice
                self?.menuList[index].1 += 1
            } else {
                self?.numberOfItems -= 1
                priceResult = (priceResult - menuPrice) > 0 ? (priceResult - menuPrice) : 0
                let previousCount = self?.menuList[index].1 ?? 0
                self?.menuList[index].1 = (previousCount - 1) > 0 ? (previousCount - 1) : 0
            }
            self?.totalPriceNumber = priceResult
        }
        return cell
    }
}

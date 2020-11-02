//
//  MemoListViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/09/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

class MemoListViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dao = MemoDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SWRevealViewController 라이브러리의 revealViewController 객체 읽어오기
        if let revealVC = self.revealViewController() {
            // 바 버튼 아이템 객체 정의
            let button = UIBarButtonItem()
            button.image = UIImage(named: "sidemenu.png")
            button.target = revealVC // 버튼 클릭시 호출할 메소드가 정의된 객체를 지정
            button.action = #selector(revealVC.revealToggle(_:)) // 버튼 클릭시 revealToggle(_:) 호출
            // 정의된 바 버튼을 내비게이션 바의 왼쪽 아이템으로 등록
            self.navigationItem.leftBarButtonItem = button
            // 제스쳐 객체 추가
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 튜토리얼 뷰컨 보여줄지 결정
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: UserInfoKey.tutorial) == false {
            let viewController = self.instanceTutorialViewController(name: "MasterVC")
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
            return
        }
        
        // 코어 데이터에 저장된 데이터 가져오기
        self.appDelegate.memolist = self.dao.fetch()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.memolist.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // memolist 배열 데이터에서 주어진 행에 맞는 데이터 꺼내기
        let row = self.appDelegate.memolist[indexPath.row]
        // 이미지 속성이 비어 있을 경우 "memoCell"로, 아니면 "memoCellWithImage"로
        let cellId = row.image == nil ? "memoCell" : "memoCellWithImage"
        
        // 재사용 큐로부터 프로토타입 셀의 인스턴스 전달받기
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MemoCell
        
        // memoCell 내용 구성
        cell.subject?.text = row.title
        cell.contents?.text = row.contents
        cell.img?.image = row.image
        
        // Date 타입의 날짜를 알맞은 포맷에 맞게 변경
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.regdate?.text = formatter.string(from: row.regdate ?? Date())
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // memolist 배열에서 선택된 행에 맞는 데이터를 변수에 저장
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 상세 화면의 인스턴스 생성
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoRead") as? MemoReadViewController else { return }
        
        // 값 전달 후 상세 화면으로 이동
        viewController.param = row
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 검색 바의 키보드에서 리턴 키가 항상 활성화되도록 처리
        searchBar.enablesReturnKeyAutomatically = false
        
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memolist[indexPath.row]
        
        if dao.delete(data.objectID!) {
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension MemoListViewController: UISearchBarDelegate {
    
    // 사용자가 검색버튼을 터치했을 때 실행되는 메소드
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색 바에 입력된 키워드를 가져오기
        let keyword = searchBar.text
        
        // 키워드를 적용해 데이터를 검색하고, 테이블 뷰 갱신
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }
}

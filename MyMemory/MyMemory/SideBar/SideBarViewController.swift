//
//  SideBarVC.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/06.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

class SideBarViewController: UITableViewController {
    let userInfoManager = UserInfoManager()
    
    let titles = ["새글 작성하기", "친구 새글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png"),
    ]
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    override func viewDidLoad() {
        self.setHeaderView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nameLabel.text = self.userInfoManager.name ?? "Guest"
        self.emailLabel.text = self.userInfoManager.account ?? ""
        self.profileImage.image = self.userInfoManager.profile
    }
    
    private func setHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = .brown
        self.tableView.tableHeaderView = headerView
        
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.nameLabel.textColor = .white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(self.nameLabel)
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 100, height: 30)
        self.emailLabel.font = UIFont.systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(self.emailLabel)
        
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2)
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        view.addSubview(self.profileImage)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // 새글작성
            // 사이드바 컨트롤러에서 프론트 컨트롤러를 직접 참조할 방법은 없다
            // 메인 컨트롤러는 사이드바와 프론트 양쪽을 참조한다
            // 사이드바에서 프론트를 간접적으로 참조하자
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            // 메인 컨트롤러 객체 가져오기 => frontViewController 참조
            let target = self.revealViewController()?.frontViewController as! UINavigationController
            // pushViewController 메소드는 내비게이션 컨트롤러에만 정의 => 위에서 캐스팅해준 이유
            target.pushViewController(uv!, animated: true)
            
            // 사이드바 닫기
            self.revealViewController()?.revealToggle(self)
        } else if indexPath.row == 5 { // 계정관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            
            // 프론트 영역이 아닌 독립된 영역에서 보여주기
            self.present(uv!, animated: true) {
                self.revealViewController()?.revealToggle(self)
            }
        }
    }
}

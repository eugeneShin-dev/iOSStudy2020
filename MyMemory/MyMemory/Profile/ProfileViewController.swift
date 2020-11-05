//
//  ProfileViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/06.
//  Copyright © 2020 Hailey. All rights reserved.
//

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let userInfoManager = UserInfoManager()
    
    let profileImage = UIImageView()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        
        // 뒤로 가기 버튼 처리
        let backButton = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        setProfileImage()
        setTableView()
        setBackground()
        
        self.view.bringSubviewToFront(self.tableView)
        self.view.bringSubviewToFront(self.profileImage)
        
        self.drawButton()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
    }
    
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        // 프로필 화면으로 돌아오기 위한 표식 역할이므로 내용 작성 x
    }
    
    func setProfileImage() {
        let image = self.userInfoManager.profile
            
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        
        self.view.addSubview(self.profileImage)
    }
    
    func setTableView() {
        self.tableView.frame = CGRect(x: 0,
                                      y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20,
                                      width: self.view.frame.width,
                                      height: 100)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.addSubview(self.tableView)
    }
    
    func setBackground() {
        let background = UIImage(named: "profile-bg")
        let backgroundImage = UIImageView(image: background)
        backgroundImage.frame.size = CGSize(width: backgroundImage.frame.size.width,
                                            height: backgroundImage.frame.size.height)
        backgroundImage.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        backgroundImage.layer.cornerRadius = backgroundImage.frame.size.width / 2
        backgroundImage.layer.borderWidth = 0
        backgroundImage.layer.masksToBounds = true
        self.view.addSubview(backgroundImage)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func drawButton() {
        let view = UIView()
        view.frame.size.width = self.view.frame.width
        view.frame.size.height = 40
        view.frame.origin.x = 0
        view.frame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.height
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        self.view.addSubview(view)
        
        let button = UIButton(type: .system)
        button.frame.size.width = 100
        button.frame.size.height = 30
        button.center.x = view.frame.size.width / 2
        button.center.y = view.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼, 로그아웃 상태일 때는 로그인 버튼
        if self.userInfoManager.isLogin == true {
            button.setTitle("로그아웃", for: .normal)
            button.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            button.setTitle("로그인", for: .normal)
            button.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        view.addSubview(button)
    }
    
    // 이미지 피커 컨트롤러
    func imagePicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "이름"
            cell.detailTextLabel?.text = self.userInfoManager.name ?? "Login Please"
        case 1:
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = self.userInfoManager.account ?? "Login Please"
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.userInfoManager.isLogin == false {
            // 로그인 상태가 아닐 경우 로그인 창 띄우기
            self.doLogin(self.tableView)
        }
    }
    
    // MARK: Action
    // 화면 복귀
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        // 로그인 창에 들어갈 입력폼
        loginAlert.addTextField() { (textField) in
            textField.placeholder = "Your account"
        }
        
        loginAlert.addTextField() { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        // 알림창 버튼 추가
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
                                
            if self.userInfoManager.login(account: account, password: password) {
                // TODO: 로그인 성공시
                self.tableView.reloadData()
                self.profileImage.image = self.userInfoManager.profile // 프로필 이미지 갱신
                self.drawButton()
            } else {
                let msg = "로그인에 실패하였습니다."
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: false)
            }
        })
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            if self.userInfoManager.logout() {
                self.tableView.reloadData()
                self.profileImage.image = self.userInfoManager.profile
                self.drawButton()
            }
        })
        self.present(alert, animated: false)
    }
    
    @objc func profile(_ sender: UIButton) {
        guard self.userInfoManager.account != nil else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil,
                                      message: "사진을 가져올 곳을 선택해주세요",
                                      preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imagePicker(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imagePicker(.savedPhotosAlbum)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imagePicker(.photoLibrary)
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}

extension ProfileViewController: UINavigationControllerDelegate {
    
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfoManager.profile = image
            self.profileImage.image = image
        }
        
        picker.dismiss(animated: true)
    }
}

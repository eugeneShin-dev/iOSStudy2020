//
//  ProfileViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/06.
//  Copyright © 2020 Hailey. All rights reserved.
//

import Alamofire
import LocalAuthentication

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    let userInfoManager = UserInfoManager()
    var isCalling = false
    
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
        
        self.view.bringSubviewToFront(indicatorView)
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
        if self.isCalling == true {
            self.alert("응답 대기")
            return
        } else {
            self.isCalling = true
        }
        
        self.indicatorView.startAnimating()
        
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
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
                                
            self.userInfoManager.login(account: account, password: password, success: {
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.tableView.reloadData()
                self.profileImage.image = self.userInfoManager.profile
                self.drawButton()
                
                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupDate()
                }
                
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()
                }
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.isCalling = false
                self.alert(msg)
            })
        })
        self.present(loginAlert, animated: false)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            self.indicatorView.startAnimating()
            self.userInfoManager.logout() {
                self.indicatorView.stopAnimating()
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
        
        self.indicatorView.startAnimating()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfoManager.newProfile(image, success: {
                self.indicatorView.stopAnimating()
                self.profileImage.image = image
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
        }
        picker.dismiss(animated: true)
    }
}

extension ProfileViewController {
    func tokenValidate() {
        // 0. 응답 캐시 삭제 : 서버와 디바이스 간의 동기화 문제
        URLCache.shared.removeAllCachedResponses()
        
        // 1. 키 체인에 액세스 토큰 없을 경우 검증 진행 x
        let tokenUtil = TokenUtils()
        guard let header = tokenUtil.getAuthorizationHeader() else {
            return
        }
        
        self.indicatorView.startAnimating()
        
        // 2. tokenValidate API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON { res in
            self.indicatorView.stopAnimating()
            
            let responseBody = try! res.result.get()
            print(responseBody)
            
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            // 3. 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 { // 응답 결과 실패 : 토큰 만료되었을 경우
                // 로컬 인증 실행
                self.touchID()
            }
        }
    }
    
    func touchID() {
        let context = LAContext()
        
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            context.evaluatePolicy(deviceAuth, localizedReason:msg) { (success, e) in
                if success {
                    self.refresh()
                } else { // 인증 실패
                    // 원인에 대한 대응 로직
                    print((e?.localizedDescription)!)
                    
                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의한 인증 취소")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의한 인증 취소") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout()
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                    
                }
            }
        } else { // 인증창이 실행되지 못한 경우
            // 인증창 실행 불가 원인에 대한 대응 로직
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디 등록 안 됨")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드 설정 안 됨")
            default:
                print("터치 아이디 사용 불가")
                
            }
            OperationQueue.main.addOperation {
                self.commonLogout(true)
            }
        }
    }
    
    func refresh() {
        self.indicatorView.startAnimating()
        
        let tokenUtil = TokenUtils()
        let header = tokenUtil.getAuthorizationHeader()
        
        let refreshToken = tokenUtil.load("kr.co.rubypaper.MyMemory", account: "refreshToken")
        let param: Parameters = ["refresh_token": refreshToken!]
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        refresh.responseJSON { res in
            self.indicatorView.stopAnimating()
            
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                let accessToken = jsonObject["access_token"] as! String
                tokenUtil.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
            } else {
                self.alert("인증 만료. 다시 로그인.") {
                    OperationQueue.main.addOperation {
                        self.commonLogout()
                    }
                }
            }
        }
    }
    
    // 토큰 갱신 과정에서 발생할 실패나 오류 상황에 사용할 공용 로그아웃 메소드
    func commonLogout(_ isLogin: Bool = false) {
        let userInfoManager = UserInfoManager()
        userInfoManager.deviceLogout()
        
        self.tableView.reloadData()
        self.profileImage.image = userInfoManager.profile
        self.drawButton()
        
        if isLogin {
            // 트리거 : 터치 이벤트를 대신해서 직접 액션 메소드 호출
            self.doLogin(self)
        }
    }
}

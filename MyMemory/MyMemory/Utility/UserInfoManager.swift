//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/13.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
import Alamofire

struct UserInfoKey {
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

// 계정 및 사용자 정보 저장 관리하는 클래스
class UserInfoManager {
    // 연산 프로퍼티 lginId 정의
    var loginId: Int {
        // 일반 변수처럼 사용할 수 있게 된다
        get { // plist에 저장된 로그인 아이디를 꺼내어 제공
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(value) { // loginId 프로퍼티에 할당된 값을 plist에 저장
            let userDefaults = UserDefaults.standard
            userDefaults.set(value, forKey: UserInfoKey.loginId)
            userDefaults.synchronize()
        }
    }
    
    var account: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(value) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(value, forKey: UserInfoKey.account)
            userDefaults.synchronize()
        }
    }
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(value) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(value, forKey: UserInfoKey.name)
            userDefaults.synchronize()
        }
    }
    
    var profile: UIImage? {
        get {
            let userDefaults = UserDefaults.standard
            if let _profile = userDefaults.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg")
            }
        }
        set(value) {
            if value != nil {
                let userDefaults = UserDefaults.standard
                userDefaults.set(value!.pngData(), forKey: UserInfoKey.profile)
                userDefaults.synchronize()
            }
        }
    }
    
    var isLogin: Bool {
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
    func login(account: String, password: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
       // 1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account": account,
            "passwd" : password
        ]
        
        // 2. API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        // 3. API 호출 결과 처리
        call.responseJSON { res in
            // 3-1. JSON 형식으로 응답했는지 확인
            let result = try! res.result.get()
            guard let jsonObject = result as? NSDictionary else {
                fail?("잘못된 응답 형식입니다:\(result)")
                return
            }
            // 3-2. 응답 코드 확인
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // 로그인 성공
                // 3-3. user_info 이하 항목을 딕셔너리 형태로 추출하여 저장
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                // 3-4. user_info 항목 중에서 프로필 이미지 처리
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                }
                
                let accessToken = jsonObject["access_token"] as! String
                let refreshToken = jsonObject["refresh_token"] as! String
                
                let tokenUtil = TokenUtils()
                tokenUtil.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                tokenUtil.save("kr.co.rubypaper.MyMemory", account: "refreshToken", value: refreshToken                                                                                                                                                                               )
                
                // 3-5. 인자값으로 입력된 success 클로저 블록 실행
                success?()
            } else { // 실패
                let message = (jsonObject["error_msg"] as? String) ?? "로그인이 실패했습니다."
                fail?(message)
            }
        }
    }
    
    func logout(completion: (()->Void)? = nil) {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { _ in
            self.deviceLogout()
            
            completion?()
        }
    }
    
    func deviceLogout() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: UserInfoKey.loginId)
        userDefaults.removeObject(forKey: UserInfoKey.account)
        userDefaults.removeObject(forKey: UserInfoKey.name)
        userDefaults.removeObject(forKey: UserInfoKey.profile)
        userDefaults.synchronize()
        
        let tokenUtils = TokenUtils()
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "refreshToken")
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "accessToken")
    }
    
    func newProfile(_ profile: UIImage?, success: (()->Void)? = nil, fail: ((String)->Void)? = nil) {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        let tokenUtil = TokenUtils()
        let header = tokenUtil.getAuthorizationHeader()
        
        let profileData = profile!.pngData()?.base64EncodedString()
        let param: Parameters = [ "profile_image" : profileData! ]
        
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        call.responseJSON { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                fail?("올바른 응답값이 아닙니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                self.profile = profile
                success?()
            } else {
                let msg = (jsonObject["error_msg"] as? String) ?? "이미지 프로필 변경 실패"
                fail?(msg)
            }
        }
    }
}

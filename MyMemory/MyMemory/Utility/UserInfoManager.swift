//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/13.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

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
    
    func login(account: String, password: String) -> Bool {
        // TODO: 서버 연동 코드로 대체하기
        if account.isEqual("shinyou@kakao.com") && password.isEqual("1234") {
            let userDefaults = UserDefaults.standard
            userDefaults.set(100, forKey: UserInfoKey.loginId)
            userDefaults.set(account, forKey: UserInfoKey.account)
            userDefaults.set("헤일리", forKey: UserInfoKey.name)
            userDefaults.synchronize()
            return true
        } else {
            return false
        }
    }
    
    func logout() -> Bool {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: UserInfoKey.loginId)
        userDefaults.removeObject(forKey: UserInfoKey.account)
        userDefaults.removeObject(forKey: UserInfoKey.name)
        userDefaults.removeObject(forKey: UserInfoKey.profile)
        return true
    }
}

//
//  Util.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
import Security
import Alamofire

class TokenUtils {
    func save(_ service: String, account: String, value: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecValueData : value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        SecItemDelete(keyChainQuery)
        
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "토근 값 저장 실패")
        NSLog("status\(status)")
    }
    
    func load(_ service: String, account: String) -> String? {
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecReturnData : kCFBooleanTrue!,
            kSecMatchLimit : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        if (status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("Nothing was retrieved from keychain. Status code \(status)")
            return nil
        }
    }
    
    func delete(_ service: String, account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account
        ]
        
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰 값 삭제 실패")
        NSLog("status=\(status)")
    }
    
    func getAuthorizationHeader() -> HTTPHeaders? {
        let serviceID = "kr.co.rubypaper.MyMemory"
        if let accessToken = self.load(serviceID, account: "accessToken") {
            return ["Authorization" : "Bearer \(accessToken)"] as HTTPHeaders
        } else {
            return nil
        }
    }
}

extension UIViewController {
    var tutorialStoryBoard: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialViewController(name: String) -> UIViewController {
        return self.tutorialStoryBoard.instantiateViewController(withIdentifier: name)
    }
    
    func alert(_ message: String, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}

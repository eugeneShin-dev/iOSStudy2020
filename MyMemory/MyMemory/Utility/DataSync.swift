//
//  DataSync.swift
//  MyMemory
//
//  Created by Hailey on 2020/11/10.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class DataSync {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func downloadBackupDate() {
        let userDefaults = UserDefaults.standard
        guard userDefaults.value(forKey: "firstLogin") == nil else { return }
        
        let tokenUtil = TokenUtils()
        let header = tokenUtil.getAuthorizationHeader()
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        let get = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        get.responseJSON { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else { return }
            guard let list = jsonObject["list"] as? NSArray else { return }
            
            for item in list {
                guard let record = item as? NSDictionary else {
                    return
                }
                
                let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                object.title = (record["title"] as! String)
                object.contents = (record["contents"] as! String)
                object.regdate = self.stringToDate(record["create_date"] as! String)
                object.sync = true
                
                if let imagePath = record["image_path"] as? String {
                    let url = URL(string: imagePath)!
                    object.image = try! Data(contentsOf: url)
                }
            }
            
            do {
                try self.context.save()
            } catch let e as NSError {
                self.context.rollback()
                NSLog("An error has occurred: %s", e.localizedDescription)
            }
            
            userDefaults.setValue(true, forKey: "firstLogin")
        }
    }
    
    func uploadData(_ indicatorView: UIActivityIndicatorView? = nil) {
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        fetchRequest.predicate = NSPredicate(format: "sync==false")
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                indicatorView?.startAnimating()
                print("upload data==\(record.title!)")
                
                self.uploadDatum(record) {
                    if record === resultset.last {
                        indicatorView?.stopAnimating()
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func uploadDatum(_ item: MemoMO, complete: (()->Void)? = nil) {
        let tokenUtil = TokenUtils()
        guard let header = tokenUtil.getAuthorizationHeader() else {
            print("로그인 상태가 아니므로 [\(item.title!)]를 업로드할 수 없습니다.")
            return
        }
        
        var param: Parameters = [
            "title": item.title!,
            "contents": item.contents!,
            "create_date": self.dateToString(item.regdate!)
        ]
        
        if let imageData = item.image as Data? {
            param["image"] = imageData.base64EncodedString()
        }
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/save"
        let upload = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        upload.responseJSON { res in
            
        }
        
        upload.responseJSON { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else {
                print("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                print("\(item.title!) 등록.")
                
                do {
                    item.sync = true
                    try self.context.save()
                } catch let e as NSError {
                    self.context.rollback()
                    NSLog("An error")
                }
            } else {
                print("")
            }
            
            complete?()
        }
    }
}

extension DataSync {
    func stringToDate(_ value: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: value)!
    }
    
    func dateToString(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: value as Date)
    }
}

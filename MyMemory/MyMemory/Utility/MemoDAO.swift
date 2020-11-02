//
//  MemoDAO.swift
//  MyMemory
//
//  Created by Hailey on 2020/11/02.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch() -> [MemoData] {
        var memoList = [MemoData]()
        // 요청 객체 생성
        /// - NSManagedObject와 MemoMO 클래스에서 반환하는 타입이 다르기 때문에 타입 어노테이션을 명시!
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 정렬 객체 생성: 최신 글순으로 정렬
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            // 읽어온 결과 리스트를 순화하면서 [MemoData] 타입으로 반환
            for record in resultset {
                // MemoData 객체 생성
                let data = MemoData()
                
                // MemoMO 프로퍼티 값을 MemoData 프로퍼티로 복사
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate! as Date
                data.objectID = record.objectID
                
                // 이미지가 있으면 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                // Memolist에 추가
                memoList.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
        return memoList
    }
}

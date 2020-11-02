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
    
    // 매개변수를 추가해 검색 키워드를 전달받도록 수정
    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memoList = [MemoData]()
        // 요청 객체 생성
        /// - NSManagedObject와 MemoMO 클래스에서 반환하는 타입이 다르기 때문에 타입 어노테이션을 명시!
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 정렬 객체 생성: 최신 글순으로 정렬
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        // contents에 키워드를 포함하는 레코드를 모두 찾아 가져오는 검색 수행
        if let text = text, text.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", text)
        }
        
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
    
    func insert(_ data: MemoData) {
        // 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        // MemoData로부터 값 복사
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!
        
        if let image = data.image {
            object.image = image.pngData()!
        }
        
        // 영구 저장소에 변경 사항 반영
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred: %s", e.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        // 삭제할 객체 찾기
        let object = self.context.object(with: objectID)
        // 컨텍스트에서 삭제
        self.context.delete(object)
        
        do {
            // 삭제된 내역을 영구저장소에 반영
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occurred: %s", e.localizedDescription)
            return false
        }
    }
}

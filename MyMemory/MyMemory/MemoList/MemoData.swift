//
//  MemoData.swift
//  MyMemory
//
//  Created by Hailey on 2020/09/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
import CoreData

class MemoData {
    var memoIdx: Int?
    var title: String?
    var contents: String?
    var image: UIImage?
    var regdate: Date?
    
    // 원본 MemoMO 객체를 참조하기 위한 속성
    var objectID: NSManagedObjectID?
}

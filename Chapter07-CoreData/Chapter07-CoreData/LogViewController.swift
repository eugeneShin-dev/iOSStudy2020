//
//  LogViewController.swift
//  Chapter07-CoreData
//
//  Created by Hailey on 2020/10/28.
//

import UIKit
import CoreData

public enum LogType: Int16 {
    case create = 0
    case edit = 1
    case delete = 2
}

class LogViewController: UITableViewController {
    var board: BoardMO! // 게시글 정보를 전달받을 변수
    
}

extension Int16 {
    func toLogType() -> String {
        switch self {
        case 0:
            return "생성"
        case 1:
            return "수정"
        case 2:
            return "삭제"
        default:
            return ""
        }
    }
}

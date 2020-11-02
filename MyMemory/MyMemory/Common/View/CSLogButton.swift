//
//  CSLogButton.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/05.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

// 1. 로그 타입 정의할 enum 객체 추가
public enum CSLogType: Int {
    case basic // 기본 로그 타입
    case title // 버튼의 타이틀 출력
    case tag // 버튼의 태그값 출력
}

public class CSLogButton: UIButton {
    // 2. 로깅 타입을 기록할 프로퍼티
    public var logType: CSLogType = .basic
    
    // 3. 초기화 메소드
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tintColor = .blue
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside)
    }
    
    // 4. 로그 출력하는 액션 메소드
    @objc func logging(_ sender: UIButton) {
        switch self.logType {
        case .basic:
            NSLog("버튼이 클릭되었다!")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "타이틀 없는"
            NSLog("\(btnTitle) 버튼이 클릭되었다!")
        case .tag:
            NSLog("\(sender.tag) 버튼 클릭")
        }
    }
}

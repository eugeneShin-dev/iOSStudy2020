//
//  TutorialMasterViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit
class TutorialMasterViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    @IBAction func close(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserInfoKey.tutorial)
        userDefaults.synchronize()
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        // 페이지VC 객체 설정
        self.pageViewController = self.instanceTutorialViewController(name: "PageVC") as? UIPageViewController
        self.pageViewController.dataSource = self
        
        // 페이지VC의 기본 페이지 설정
        let startContentsViewController = self.getContentViewController(atIndex: 0)!
        self.pageViewController.setViewControllers([startContentsViewController],
                                                   direction: .forward,
                                                   animated: true)
        
        // 페이지VC의 출력 영역 지정
        self.pageViewController.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageViewController.view.frame.size.width = self.view.frame.width
        self.pageViewController.view.frame.size.height = self.view.frame.height - 50 // 페이지 인디케이터&버튼 자리 확보
        
        // 페이지VC를 마스터VC의 자식VC로 설정
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
    }
    
    // 입력받은 인덱스 값에 해당하는 컨텐츠VC의 인스턴스를 생성해 반환
    func getContentViewController(atIndex index: Int) -> UIViewController? {
        // 인덱스 범위 확인
        guard self.contentTitles.count >= index && self.contentTitles.count > 0 else {
            return nil
        }
        
        // storyboardID로 뷰 컨트롤러 인스턴스를 생성하고 캐스팅
        // instanceTutorialViewController(name:)는 Util.swift의 extension에 추가했던 메소드
        guard let contentViewController = self.instanceTutorialViewController(name: "ContentsVC") as? TutorialContentsViewController else {
            return nil
        }
        
        contentViewController.titleText = self.contentTitles[index]
        contentViewController.imageFile = self.contentImages[index]
        contentViewController.pageIndex = index
        return contentViewController
    }
    
    // MARK: PageViewControllerDatasource
    
    // 현재 콘텐츠VC보다 앞쪽에 올 콘텐츠VC 객체: 앞으로 스와이프했을 때 보여줄 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재 페이지의 인덱스
        guard var index = (viewController as! TutorialContentsViewController).pageIndex else {
            return nil
        }
        
        // 현재 인덱스가 맨 앞일 경우
        guard index > 0 else {
            return nil
        }
        
        index -= 1 // 이전 페이지의 인덱스
        return self.getContentViewController(atIndex: index)
    }
    
    // 현재 콘텐츠VC보다 뒷쪽에 올 콘텐츠VC 객체: 뒤로 스와이프했을 때 보여줄 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as? TutorialContentsViewController)?.pageIndex else {
            return nil
        }
        
        index += 1
        
        guard index < self.contentTitles.count else {
            return nil
        }
        
        return self.getContentViewController(atIndex: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

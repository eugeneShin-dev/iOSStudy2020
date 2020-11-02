//
//  MemoFormViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/09/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

class MemoFormViewController: UIViewController {
    var subject: String!
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    @IBAction func save(_ sender: Any) {
        
        // 경고창에 사용될 콘텐츠 뷰 컨트롤러 구성
        let alertViewController = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        alertViewController.view = UIImageView(image: iconImage)
        // 이미지 뷰의 크기를 따를 수 있게 혹은 이미지가 없는 경우 CGSize.zero 사용
        alertViewController.preferredContentSize = iconImage?.size ?? CGSize.zero
        
        // 입력창이 비었을 경우
        guard self.contents.text?.isEmpty == false else {
            let alert = UIAlertController(title: nil,
                                          message: "내용을 입력해주세요",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
            // 콘텐츠 뷰 영역에 alertViewController 등록
            alert.setValue(alertViewController, forKey: "contentViewController")
            self.present(alert, animated: true)
            return
        }
        
        // MemoData 객체를 생성한 후 데이터 담기
        let data = MemoData()
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date()
        
        // AppDelegate 객체를 읽어온 후 memolist 배열에 MemoData 객체 추가
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        // 작성폼 화면 종료 후 이전 화면으로 복귀
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pick(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker, animated: false)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contents.delegate = self
        // Do any additional setup after loading the view.
        
        setSytle()
    }

    private func setSytle() {
        // 배경 이미지 설정
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        
        // 텍스트 뷰의 기본속성
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = UIColor.clear
        
        // 줄 간격
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9
        self.contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        self.contents.text = ""
    }

    // 탭하면 네비게이션 바 토글
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar
        
        // 애니메이션으로 자연스럽게 없애기
        let ts = TimeInterval(0.3)
        UIView.animate(withDuration: ts, animations: {
            bar?.alpha = ( bar?.alpha == 0 ? 1 : 0 )
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MemoFormViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.preview.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: false)
    }
}

extension MemoFormViewController: UINavigationControllerDelegate {
    
}

extension MemoFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 최대 15자리까지 subject 변수에 저장
        let contents = textView.text as NSString
        let length = ( (contents.length > 15 ) ? 15 : contents.length )
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        // 네비게이션 타이틀에 표시
        self.navigationItem.title = self.subject
    }
}

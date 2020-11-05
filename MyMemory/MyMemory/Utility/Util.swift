//
//  Util.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

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

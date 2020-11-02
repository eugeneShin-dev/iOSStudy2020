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
}

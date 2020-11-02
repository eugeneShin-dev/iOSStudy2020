//
//  TutorialContentsViewController.swift
//  MyMemory
//
//  Created by Hailey on 2020/10/14.
//  Copyright © 2020 Hailey. All rights reserved.
//

import UIKit

class TutorialContentsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        setViews()
    }
    
    func setViews() {
        self.backgroundImageView.contentMode = .scaleAspectFill
        self.backgroundImageView.image = UIImage(named: self.imageFile)
        
        self.titleLabel.text = self.titleText
        self.titleLabel.sizeToFit()
        
    }
}

//
//  BooruNavigationController.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import ChameleonFramework
import UIKit

class BooruNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func configure() {
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): Application.Theme.color.white, NSAttributedStringKey.font: Application.Theme.font.bold._15]
        self.navigationBar.tintColor = Application.Theme.color.white
        self.navigationBar.barTintColor = GradientColor(gradientStyle: UIGradientStyle.leftToRight, frame: self.navigationBar.bounds, colors: Application.Theme.color.gradient) //Application.Theme.color.blue

        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            navigationBar.largeTitleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): Application.Theme.color.white, NSAttributedStringKey.font: Application.Theme.font.bold._35]
        }

    }
    
    // MARK: - Navigation

}

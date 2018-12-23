//
//  MasterSearchController.swift
//  Danbooru Lite
//
//  Created by Satish on 24/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Closures
import Foundation
import Material
import RxSwift
import UIKit

class MasterSearchController: SearchBarController {
    fileprivate var backButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareBackButton()
        prepareStatusBar()
        prepareSearchBar()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.textField.becomeFirstResponder()
    }
}

fileprivate extension MasterSearchController {
    
    func prepareBackButton() {
        self.backButton = IconButton()
        self.backButton.image = Icon.cm.arrowBack
        self.backButton.tintColor = .black
        self.backButton.onTap { [weak self] in
            if self == nil {
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func prepareStatusBar() {
        //statusBar.theme_backgroundColor = ThemeColors.backgroundColor
    }
    
    func prepareSearchBar() {
        //        searchBarAlignment = .bottom
//        searchBar.theme_backgroundColor = ThemeColors.backgroundColor
//        searchBar.theme_tintColor = ThemeColors.barTextColor
//        searchBar.textColor = searchBar.tintColor
//        searchBar.placeholderColor = searchBar.tintColor ?? UIColor.black
//        searchBar.clearButton.theme_tintColor = ThemeColors.barTextColor
        searchBar.textField.font = Application.Theme.font.regular._16
        searchBar.leftViews = [backButton]
    }
}


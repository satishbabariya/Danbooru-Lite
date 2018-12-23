//
//  BooruButton.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import ChameleonFramework
import Closures
import Foundation
import Material
import UIKit

class BooruButton: Button {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        cornerRadiusPreset = .cornerRadius1
        depthPreset = .depth5
        titleLabel?.font = Application.Theme.font.bold._17
        titleLabel?.textColor = .white
        setTitleColor(.white, for: UIControlState.normal)
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setTitle(_ title: String?) {
        setTitle(title, for: UIControlState.normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()  
        if frame.size != .zero && frame.width != 0 && frame.height != 0 {
            backgroundColor = GradientColor(gradientStyle: .leftToRight, frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), colors: Application.Theme.color.gradient)
        }
    }
    
}

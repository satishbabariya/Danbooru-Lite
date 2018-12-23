//
//  Theme.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import Material

extension Application {
    struct Theme {
        struct color {
            static let clear = UIColor.clear
            static let white = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            static let mercury = #colorLiteral(red: 0.968627451, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
            
            static let skyBlue = #colorLiteral(red: 0.6705882353, green: 0.862745098, blue: 1, alpha: 1)
            static let blue = #colorLiteral(red: 0.01176470588, green: 0.5882352941, blue: 1, alpha: 1)
            
            static let one = #colorLiteral(red: 0.4, green: 0.4, blue: 1, alpha: 1)// #colorLiteral(red: 0.8078431373, green: 0.6235294118, blue: 0.9882352941, alpha: 1) //CE9FFC
            static let two = #colorLiteral(red: 0.4509803922, green: 0.5333333333, blue: 0.9411764706, alpha: 1)// #colorLiteral(red: 0.4509803922, green: 0.4039215686, blue: 0.9411764706, alpha: 1) //7367F0
            
            static let gradient = [color.one, color.two]
            //static let gradient : [UIColor] = [UIColor.flatSkyBlue(),UIColor.flatSkyBlueColorDark()]//color.one, color.two]
            
        }
        
        struct font {
            fileprivate struct FontStyle {
                static let bold = "OpenSans-Bold"
                static let regular = "OpenSans-Regular"
            }
            
             /*
            ===================
            Open Sans
            OpenSans-Regular
            OpenSans-Bold
            OpenSans-Light
            OpenSans-SemiBold
            OpenSans-ExtraBold
            ===================
             
             for font in UIFont.familyNames{
                print("===================",font, separator: "\n")
                for name in UIFont.fontNames(forFamilyName: font){
                    print(name)
                }
             }
             */
            
            struct bold {
                static let _35 = UIFont(name: FontStyle.bold, size: 30.0) ?? UIFont.boldSystemFont(ofSize: 30.0)
                static let _30 = UIFont(name: FontStyle.bold, size: 30.0) ?? UIFont.boldSystemFont(ofSize: 30.0)
                static let _25 = UIFont(name: FontStyle.bold, size: 25.0) ?? UIFont.boldSystemFont(ofSize: 25.0)
                static let _18 = UIFont(name: FontStyle.bold, size: 18.0) ?? UIFont.boldSystemFont(ofSize: 18.0)
                static let _17 = UIFont(name: FontStyle.bold, size: 17.0) ?? UIFont.boldSystemFont(ofSize: 17.0)
                static let _16 = UIFont(name: FontStyle.bold, size: 16.0) ?? UIFont.boldSystemFont(ofSize: 16.0)
                static let _15 = UIFont(name: FontStyle.bold, size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15.0)
                static let _14 = UIFont(name: FontStyle.bold, size: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
                static let _13 = UIFont(name: FontStyle.bold, size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13.0)
            }
            struct regular {
                static let _20 = UIFont(name: FontStyle.regular, size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
                static let _18 = UIFont(name: FontStyle.regular, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
                static let _17 = UIFont(name: FontStyle.regular, size: 17.0) ?? UIFont.systemFont(ofSize: 17.0)
                static let _16 = UIFont(name: FontStyle.regular, size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
                static let _15 = UIFont(name: FontStyle.regular, size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
                static let _14 = UIFont(name: FontStyle.regular, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
                static let _13 = UIFont(name: FontStyle.regular, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
                static let _12 = UIFont(name: FontStyle.regular, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
                static let _10 = UIFont(name: FontStyle.regular, size: 10.0) ?? UIFont.systemFont(ofSize: 10.0)
            }
        }
        
    }
    
}

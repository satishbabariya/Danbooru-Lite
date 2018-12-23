//
//  Configurations.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let authToken = DefaultsKey<String>("AuthorizationBearerToken")
    static let serviceType = DefaultsKey<Int>("ServiceType")
    static let serviceUrl = DefaultsKey<String>("ServiceEndpoint")
    static let isPremium = DefaultsKey<Bool>("isPremiumMember")
    
    static let danbooru = DefaultsKey<String>("danbooru")
    static let gelbooru = DefaultsKey<String>("gelbooru")
    static let yandere = DefaultsKey<String>("yandere")
    static let kochan = DefaultsKey<String>("kochan")
    
    static let isLaunchedBefore = DefaultsKey<Bool>("isFirstTimeLaunched")
    static let isLargeThumbnail = DefaultsKey<Bool>("isLargeThumbnail")
    
    static let layout = DefaultsKey<Int>("CollectionViewLayour")
    static let isLaunchFirstTime = DefaultsKey<Bool>("isLaunchFirsttime")
}

enum ServiceType: Int {
    
    case flickr = 0
    case danbooru = 1
    case gelbooru = 2
    case yandere = 3
    case kochan = 4
    
}

struct Application {
    
    static func layout() -> Layout{
        if !Defaults[.isLaunchFirstTime]{
            Defaults[.isLaunchFirstTime] = true
            Defaults[.layout] = Application.device.iPad ? Layout.fourByfour.rawValue : Layout.twoBytwo.rawValue
        }
        return Layout(rawValue: Defaults[.layout]) ?? Layout.twoBytwo
        
    }
    
    static func setLayout(_ layout: Layout){
       Defaults[.layout] = layout.rawValue
    }
    
    static func isFirstLaunch() -> Bool {
        if Defaults[.isLaunchedBefore]{
            return false
        }else{
            Defaults[.isLaunchedBefore] = true
            return true
        }
    }
    
    static func isLargeThumbnail() -> Bool {
          return  Defaults[.isLargeThumbnail]        
    }
    
    static func setLargeThumbnail(_ bool:Bool) {
         Defaults[.isLargeThumbnail] = bool
    }
    
    struct Service {
        static func get() -> ServiceType {
            return ServiceType(rawValue: Defaults[.serviceType]) ?? ServiceType.flickr
        }
        
        static func getID() -> Int {
            return Defaults[.serviceType]
        }
        
        static func url() -> String {
            switch self.get() {
            case .flickr:
                return "https://api.flickr.com/services/rest/"
            case .danbooru:
                return Defaults[.danbooru] // "https://danbooru.donmai.us/"
            case .gelbooru:
                return Defaults[.gelbooru] // "https://gelbooru.com/" //https://gelbooru.com/index.php?page=help&topic=dapi
            case .yandere:
                return Defaults[.yandere] // "https://yande.re/" //https://yande.re/help/api
            case .kochan:
                return Defaults[.kochan] // "https://konachan.com/" //https://konachan.com/help/api
            }
        }
        
        static func set(url: String, type: ServiceType) {
            switch type {
            case .flickr:
                break
            case .danbooru:
                Defaults[.danbooru] = url // "https://danbooru.donmai.us/"
            case .gelbooru:
                Defaults[.gelbooru] = url // "https://gelbooru.com/" //https://gelbooru.com/index.php?page=help&topic=dapi
            case .yandere:
                Defaults[.yandere] = url // "https://yande.re/" //https://yande.re/help/api
            case .kochan:
                Defaults[.kochan] = url // "https://konachan.com/" //https://konachan.com/help/api
            }
        }
        
        static func set(service: ServiceType) {
            Defaults[.serviceType] = service.rawValue
        }
        
    }
    
    struct Auth {
        static func currentUser() -> Bool {
            return Defaults[.authToken] != ""
        }
        
        static func signOut() {
            Defaults.removeAll()
            Application.appDelegate()?.isAuthorized()
        }
        
    }
    
    struct Environment {
        
        private static let production: Bool = {
            #if DEBUG
                print("DEBUG")
                return false
            #else
                print("PRODUCTION")
                return true
            #endif
        }()
        
        static func isProduction() -> Bool {
            return self.production
        }
        
        static func isDebug() -> Bool {
            return !self.production
        }
        
    }
    
    static func isPremium() -> Bool {
        return Defaults[.isPremium]
    }
    
    static func appDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    struct device {
        static let iPhone = (UIDevice.current.model as NSString).isEqual(to: "iPhone") ? true : false
        static let iPad = (UIDevice.current.model as NSString).isEqual(to: "iPad") ? true : false
        static let iPod = (UIDevice.current.model as NSString).isEqual(to: "iPod touch") ? true : false
    }
    
    struct cellIDS {
        static var home: String = "HomeCollectionViewCell"
        static var search: String = "SearchViewCell"
    }
    
}

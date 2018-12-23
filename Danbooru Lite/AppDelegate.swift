//
//  AppDelegate.swift
//  Danbooru Lite
//
//  Created by Satish on 22/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Async
import Photos.PHPhotoLibrary
import RxSwift
import SwiftMessages
import SwiftyUserDefaults
import IQKeyboardManagerSwift
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate var disposeBag: DisposeBag!
    fileprivate var navigationController: BooruNavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Dispose Bag for disposing Resources
        self.disposeBag = DisposeBag()
        
        // Setting Up Network Reachablity
        setupReachability()
        
        // Configure Third Party Tools
        configureThirdPartyTools()
        
        
        ImageCache.default.maxDiskCacheSize = 50 * 1024 * 1024
        ImageCache.default.maxCachePeriodInSecond = 60 * 60
        
        requestPhotoLibraryAuthorisation()
        
        
        // Load UI Elements
        loadUI()
        
        return true
    }
    
}

// MARK: UI
extension AppDelegate {
    fileprivate func loadUI() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = Application.Theme.color.mercury
        self.isAuthorized()
    }
    
    func isAuthorized() {
        if Application.isFirstLaunch() {
            self.loadAuthUI()
        } else {
            self.loadHomeUI()
        }
    }
    
    fileprivate func loadHomeUI() {
        self.navigationController = BooruNavigationController(rootViewController: HomeViewController())
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func loadAuthUI() {
        self.navigationController = BooruNavigationController(rootViewController: ServiceViewController())
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate {
    
    fileprivate func configureThirdPartyTools() {
        IQKeyboardManager.shared.enable = true
    }
    
    fileprivate func requestPhotoLibraryAuthorisation() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if self == nil {
                return
            }
            switch status {
            case .authorized:
                break
            default:
                self!.messageMaker(message: "Photo Library Acess Required to save Images.", position: SwiftMessages.PresentationStyle.bottom, type: Theme.warning)
                break
            }
        }
    }
    
    // For Setting Up Reachblity
    fileprivate func setupReachability() {
        do {
            let reachable = try DefaultReachabilityService()
            reachable.reachability.subscribe { [weak self] event in
                if self == nil {
                    return
                }
                switch event {
                case .next:
                    if reachable._reachability.connection == .none {
                        Async.main({ [weak self] in
                            if self == nil {
                                return
                            }
                            self!.messageMaker(message: Localizations.nointernet, position: SwiftMessages.PresentationStyle.bottom, type: .warning)
                        })
                    }
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        } catch {
            print("DefaultReachabilityService : ", error.localizedDescription)
        }
    }
    
}

// MARK: Swift Messages
extension AppDelegate {
    public func messageMaker(message: String, position: SwiftMessages.PresentationStyle, type: Theme) {
        let messageView: MessageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(type)
        messageView.bodyLabel?.text = message
        messageView.button?.isHidden = true
        messageView.titleLabel?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = position
        config.duration = .seconds(seconds: 2.0)
        SwiftMessages.show(config: config, view: messageView)
    }
}

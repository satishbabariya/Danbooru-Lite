//
//  BooruController.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import ChameleonFramework
import Closures
import Foundation
import NVActivityIndicatorView
import RxSwift
import SwiftMessages

class BooruController: UIViewController {
    
    var disposeBag: DisposeBag!
    var indicator: ActivityIndicator!
    var queue: OperationQueue!
    var activityIndicator: NVActivityIndicatorView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = Application.Theme.color.mercury
        configure()
    }
    
    deinit {
        queue.cancelAllOperations()
        queue = nil
        disposeBag = nil
        indicator = nil
        if activityIndicator != nil {
            activityIndicator.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    fileprivate func configure() {
        disposeBag = DisposeBag()
        indicator = ActivityIndicator()
        queue = OperationQueue()
        configureActivityIndicator()
       
    }
    
    fileprivate func configureActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: .zero)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.type = .ballBeat
        activityIndicator.color = GradientColor(gradientStyle: UIGradientStyle.leftToRight, frame: .init(x: 0, y: 0, width: Application.device.iPad ? 60.0 : 50.0, height: Application.device.iPad ? 60.0 : 50.0), colors: Application.Theme.color.gradient)
        view.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: Application.device.iPad ? 60.0 : 50.0).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: Application.device.iPad ? 60.0 : 50.0).isActive = true
    }
    
    fileprivate var rx_animating: AnyObserver<Bool> {
        return AnyObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            switch event {
            case .next(let value):
                if value {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            case .error(let error):
                print(error)
            case .completed:
                break
            }
        }
    }
    
    func rx_bind_activityindicator() {
        indicator.asObservable()
            .bind(to: rx_animating)
            .disposed(by: disposeBag)
    }
    
    func displayMessage(title: String, body: String?, type: Theme) {
        // if message string is empty then return
        if title == "" {
            return
        }
        let messageView: MessageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(type)
        
        if let body = body {
            messageView.titleLabel?.text = title
            messageView.bodyLabel?.text = body
        } else {
            messageView.bodyLabel?.text = title
            messageView.titleLabel?.isHidden = true
        }
        messageView.button?.isHidden = true
        // messageView.iconImageView?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        config.duration = .seconds(seconds: 2.0)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func displayRestError(error: Error) {
        if let error = error as? RESTError {
            displayMessage(title: error.title, body: error.message, type: error.type)
        } else {
            displayMessage(title: "Error", body: error.localizedDescription, type: Theme.error)
        }
    }
    
    func displayRestMessage(meta: RESTMeta) {
        displayMessage(title: meta.title, body: meta.message, type: meta.type)
    }
    
}

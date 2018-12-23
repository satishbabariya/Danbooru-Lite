//
//  PullToRefresh.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit
import Async
import NVActivityIndicatorView
import RxSwift
import ESPullToRefresh
import ChameleonFramework

public class CustomRefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    public var view: UIView { return self }
    
    public var insets: UIEdgeInsets  = UIEdgeInsets.zero
    
    public var trigger: CGFloat = 60.0
    
    public var executeIncremental: CGFloat = 60.0
    
    let h: CGFloat = Application.device.iPad ? 40.0 : 30.0
    
    public var state: ESRefreshViewState = .pullToRefresh
    
    lazy var activityColor : UIColor = GradientColor(gradientStyle: UIGradientStyle.leftToRight, frame: .init(x: 0, y: 0, width: h, height: h), colors: Application.Theme.color.gradient)
    
    fileprivate(set) lazy var activityIndicator: NVActivityIndicatorView! = {
        let activityIndicator = NVActivityIndicatorView.init(frame: .init(x: 0, y: 0, width: h, height: h), type: .ballBeat, color: activityColor, padding: 0.0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -10.0).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: h).isActive = true
        activityIndicator.widthAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        if !self.activityIndicator.isAnimating{
            self.activityIndicator.startAnimating()
        }
    }
    
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        self.activityIndicator.stopAnimating()
    }
    
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        
    }
    
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing, .autoRefreshing:
            self.setNeedsLayout()
            break
        case .releaseToRefresh:
            self.setNeedsLayout()
            break
        case .pullToRefresh:
            self.setNeedsLayout()
            self.activityIndicator.startAnimating()
            break
        case .noMoreData:
            self.setNeedsLayout()
            break
        }
    }
}



//
//  SetupServiceViewController.swift
//  Danbooru Lite
//
//  Created by Satish on 29/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Material
import UIKit

class SetupServiceViewController: BooruController {

    fileprivate var type: ServiceType = .flickr
    fileprivate var txtDomain: TextField!
    fileprivate var contentView: View!
    fileprivate var btnNext: BooruButton!

    convenience init(type: ServiceType) {
        self.init()
        self.type = type
    }

    deinit {
        if txtDomain != nil {
            txtDomain.removeFromSuperview()
            txtDomain = nil
        }
        if btnNext != nil {
            btnNext.removeFromSuperview()
            btnNext = nil
        }
        if contentView != nil {
            contentView.removeFromSuperview()
            contentView = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch type {
        case .flickr:
            title = Localizations.Flickr
        case .danbooru:
            title = Localizations.Danbooru
        case .gelbooru:
            title = Localizations.Gelbooru
        case .yandere:
            title = Localizations.Yandere
        case .kochan:
            title = Localizations.Kochan
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = View()
        contentView.depthPreset = .depth3
        contentView.shapePreset = .square
        contentView.backgroundColor = UIColor.white

        txtDomain = TextField()
        txtDomain.translatesAutoresizingMaskIntoConstraints = false
        txtDomain.text = "https://"
        txtDomain.detail = Localizations.domaindetails
        txtDomain.clearButtonMode = .whileEditing
        txtDomain.autocorrectionType = .no
        txtDomain.autocapitalizationType = .none
        txtDomain.keyboardType = .URL
        txtDomain.isPlaceholderUppercasedWhenEditing = true
        txtDomain.placeholder = Localizations.domainplaceholder
        contentView.addSubview(txtDomain)

        btnNext = BooruButton(frame: CGRect.zero)
        btnNext.setTitle(Localizations.next)
        contentView.addSubview(btnNext)

        let contentViewWidth: CGFloat = .phone == Device.userInterfaceIdiom ? Screen.width - 40 : 500

        if .phone == Device.userInterfaceIdiom {
            view.layout(contentView).width(contentViewWidth).centerHorizontally().top(20)
        } else {
            view.layout(contentView).width(contentViewWidth).center()
        }

        let views: [String: Any] = ["txtDomain": txtDomain, "btnNext": btnNext]
        let horizontalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[txtDomain]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        contentView.addConstraints(horizontalConstraint)
        let verticalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[txtDomain]-50-[btnNext]-20-|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views)
        contentView.addConstraints(verticalConstraint)

        btnNext.onTap { [weak self] in
            if self == nil {
                return
            }
            self!.view.endEditing(true)
            if self!.validateDomain() {
                if var text = self!.txtDomain.text, let last = text.last {
                    if last != "/" {
                        text.append("/")
                    }
                    self?.beginTest(text: text)
                }
            } else {
                self!.displayMessage(title: Localizations.urlnotvalid, body: nil, type: .error)
            }

        }

    }

    fileprivate func beginTest(text: String) {
        activityIndicator.startAnimating()
        queue.addOperation { [weak self] in
            if self == nil {
                return
            }
            TESTClient.test(type: self!.type, url: text).request().subscribe({ [weak self] event in
                if self == nil {
                    return
                }
                self?.activityIndicator.stopAnimating()
                switch event {
                case .next(_, let data):
                    if let data: [Post] = data as? [Post] {
                        if data.count > 0 {
                            Application.Service.set(url: text, type: self!.type)
                            Application.Service.set(service: self!.type)
                            Application.appDelegate()?.isAuthorized()
                        }
                    }
                case .error:
                    self!.displayMessage(title: Localizations.urlnotvalid, body: nil, type: .error)
                case .completed:
                    break
                }
            }).disposed(by: self!.disposeBag)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func validateDomain() -> Bool {
        guard let url = self.txtDomain.text else { return false }
        let urlRegEx = "(https://)?(?:www\\.)??[a-zA-Z0-9./]+$"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: url)
    }

}

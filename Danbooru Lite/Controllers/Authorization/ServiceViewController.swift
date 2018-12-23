//
//  AuthorizationViewController.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import ChameleonFramework
import Kingfisher
import M13Checkbox
import Material
import Material
import RxSwift
import SwiftyUserDefaults
import UIKit

class ServiceViewController: BooruController {
    
    fileprivate var tableView: TableView!
    fileprivate var btnSkip: BooruButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Localizations.service
        self.setupTableView()
    }
    
    deinit {
        if tableView != nil{
            tableView.removeFromSuperview()
            tableView = nil
        }
        if btnSkip != nil{
            btnSkip.removeFromSuperview()
            btnSkip = nil
        }
    }
    
    fileprivate func setupTableView() {
        
        self.tableView = TableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "CellIdentifire.settingsCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: Screen.width - 30, height: 80))
        self.tableView.rowHeight = 60
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isMultipleTouchEnabled = false
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = EdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        self.view.addSubview(self.tableView)
        
        self.btnSkip = BooruButton(frame: CGRect.zero)
        self.btnSkip.setTitle(Localizations.skip)
        self.tableView.tableFooterView?.addSubview(self.btnSkip)
        
        let viewDictionary: [String: Any] = ["tableView": tableView]
        let metrics: [String: Any] = ["hSpace": 15, "vSpace": 15]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hSpace-[tableView]-hSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vSpace-[tableView]-vSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))
        
        btnSkip.widthAnchor.constraint(equalTo: self.tableView.widthAnchor, multiplier: 0.8).isActive = true
        btnSkip.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        if let footer = tableView.tableFooterView{
            btnSkip.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
            btnSkip.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
        }
        
        btnSkip.onTap {
            Application.Service.set(service: ServiceType.flickr)
            Application.appDelegate()?.isAuthorized()
        }
        
    }
    
    fileprivate func privercyURLAction() {
        if let url = URL(string: "https://danbooru-lite.firebaseapp.com/privacy.html") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func aboutUsAction() {
        if let url = URL(string: "https://danbooru-lite.firebaseapp.com/privacy.html") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func donateAction() {
        if let url = URL(string: "https://www.paypal.me/satishbabariya") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}

// MARK: - Tableview Datasource Delegate Methods
extension ServiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifire.settingsCell", for: indexPath) as! TableViewCell
        cell = TableViewCell(style: .subtitle, reuseIdentifier: "CellIdentifire.settingsCell")
        cell.depthPreset = .depth1
        cell.shapePreset = .square
        cell.textLabel?.font = Application.Theme.font.bold._16
        cell.detailTextLabel?.font = Application.Theme.font.regular._13
        
        let checkBox: M13Checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        checkBox.markType = .checkmark
        checkBox.boxType = .square
        checkBox.tintColor = GradientColor(gradientStyle: UIGradientStyle.leftToRight, frame: checkBox.bounds, colors: Application.Theme.color.gradient)
        checkBox.checkmarkLineWidth = 2.0
        checkBox.boxLineWidth = 2.0
        checkBox.isUserInteractionEnabled = false
        cell.accessoryView = checkBox
        
        if Application.Service.getID() == indexPath.row {
            checkBox.setCheckState(M13Checkbox.CheckState.checked, animated: true)
        } else {
            checkBox.setCheckState(M13Checkbox.CheckState.unchecked, animated: true)
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = Localizations.Flickr
            cell.detailTextLabel?.text = "https://api.flickr.com/services/rest/"
        case 1:
            cell.textLabel?.text = Localizations.Danbooru
            cell.detailTextLabel?.text = Defaults[.danbooru] == "" ? Localizations.setupurl : Defaults[.danbooru]
        case 2:
            cell.textLabel?.text = Localizations.Gelbooru
            cell.detailTextLabel?.text = Defaults[.gelbooru] == "" ?  Localizations.setupurl : Defaults[.gelbooru]
        case 3:
            cell.textLabel?.text = Localizations.Yandere
            cell.detailTextLabel?.text = Defaults[.yandere] == "" ?  Localizations.setupurl : Defaults[.yandere]
        case 4:
            cell.textLabel?.text = Localizations.Kochan
            cell.detailTextLabel?.text = Defaults[.kochan] == "" ?  Localizations.setupurl : Defaults[.kochan]
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            Application.Service.set(service: ServiceType.flickr)
            Application.appDelegate()?.isAuthorized()
        case 1:
            if Defaults[.danbooru] == "" {
                self.navigationController?.pushViewController(SetupServiceViewController(type: ServiceType.danbooru), animated: true)
            } else {
                Application.Service.set(service: ServiceType.danbooru)
                Application.appDelegate()?.isAuthorized()
            }
            
        case 2:
            if Defaults[.gelbooru] == "" {
                self.navigationController?.pushViewController(SetupServiceViewController(type: ServiceType.gelbooru), animated: true)
            } else {
                Application.Service.set(service: ServiceType.gelbooru)
                Application.appDelegate()?.isAuthorized()
            }
        case 3:
            if Defaults[.yandere] == "" {
                self.navigationController?.pushViewController(SetupServiceViewController(type: ServiceType.yandere), animated: true)
            } else {
                Application.Service.set(service: ServiceType.yandere)
                Application.appDelegate()?.isAuthorized()
            }
            
        case 4:
            if Defaults[.kochan] == "" {
                self.navigationController?.pushViewController(SetupServiceViewController(type: ServiceType.kochan), animated: true)
            } else {
                Application.Service.set(service: ServiceType.kochan)
                Application.appDelegate()?.isAuthorized()
            }
        default:
            break
        }
    }
}

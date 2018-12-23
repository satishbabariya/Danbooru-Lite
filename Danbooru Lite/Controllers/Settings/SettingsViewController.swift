//
//  SettingsViewController.swift
//  Danbooru Lite
//
//  Created by Satish on 24/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import ChameleonFramework
import Kingfisher
import Material
import UIKit

class SettingsViewController: BooruController {
    
    fileprivate var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Localizations.settings
        self.setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        if tableView != nil{
            tableView.removeFromSuperview()
            tableView = nil
        }
    }
    
    fileprivate func setupTableView() {
        
        self.tableView = TableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "CellIdentifire.settingsCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 60
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isMultipleTouchEnabled = false
        self.tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.tableView)
        
        let viewDictionary: [String: Any] = ["tableView": tableView]
        let metrics: [String: Any] = ["hSpace": 15, "vSpace": 15]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hSpace-[tableView]-hSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vSpace-[tableView]-vSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))
    }
    
    fileprivate func privercyURLAction() {
        self.present(BooruNavigationController(rootViewController: WebViewController()), animated: true)
    }
    
    fileprivate func aboutUsAction() {
        if let url = URL(string: "https://danbooru-lite.firebaseapp.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func donateAction() {
        if let url = URL(string: "https://www.paypal.me/satishbabariya") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    fileprivate func thumbnailQualityAction() {
        let alert: UIAlertController = UIAlertController(title: Localizations.thumbnailquality, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? .alert : UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: Localizations.cancel, style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Localizations.high, style: UIAlertActionStyle.default, handler: { [weak self] _ in
            Application.setLargeThumbnail(true)
            if self == nil {
                return
            }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: Localizations.low, style: UIAlertActionStyle.default, handler: { [weak self] _ in
            Application.setLargeThumbnail(false)
            if self == nil {
                return
            }
            self?.tableView.reloadData()
        }))
        
        self.present(alert, animated: true)
    }
    
    fileprivate func layoutAction() {
        let alert: UIAlertController = UIAlertController(title: Localizations.layout, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? .alert : UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: Localizations.cancel, style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "1 x 1", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            Application.setLayout(Layout.oneByone)
            if self == nil {
                return
            }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "2 x 2", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            Application.setLayout(Layout.twoBytwo)
            if self == nil {
                return
            }
            self?.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "4 x 4", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            Application.setLayout(Layout.fourByfour)
            if self == nil {
                return
            }
            self?.tableView.reloadData()
        }))
        
        self.present(alert, animated: true)
    }
    
}

// MARK: - Tableview Datasource Delegate Methods
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45.0))
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 4, width: UIScreen.main.bounds.width - 30, height: 35.0))
        label.font = Application.Theme.font.bold._16
        
        switch section {
        case 0:
            label.text = Localizations.services
        case 1:
            label.text = Localizations.application
        case 2:
            label.text = Localizations.appname
        default:
            return UIView()
        }
        view.addSubview(label)
        let border = CALayer()
        border.frame = CGRect(x: 0, y: view.frame.height - 2.0, width: view.frame.width, height: 2.0)
        border.backgroundColor = GradientColor(gradientStyle: UIGradientStyle.leftToRight, frame: border.bounds, colors: Application.Theme.color.gradient).cgColor
        view.layer.addSublayer(border)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifire.settingsCell", for: indexPath) as! TableViewCell
        cell = TableViewCell(style: .subtitle, reuseIdentifier: "CellIdentifire.settingsCell")
        cell.depthPreset = .depth1
        cell.shapePreset = .square
        cell.textLabel?.font = Application.Theme.font.regular._15
        cell.detailTextLabel?.font = Application.Theme.font.regular._13
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = Localizations.servicesettings
            switch Application.Service.get() {
                
            case .flickr:
                cell.detailTextLabel?.text = Localizations.Flickr
            case .danbooru:
                cell.detailTextLabel?.text = Localizations.Danbooru
            case .gelbooru:
                cell.detailTextLabel?.text = Localizations.Gelbooru
            case .yandere:
                cell.detailTextLabel?.text = Localizations.Yandere
            case .kochan:
                cell.detailTextLabel?.text = Localizations.Kochan
            }
            
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = Localizations.thumbnailquality
                if Application.isLargeThumbnail() {
                    cell.detailTextLabel?.text = Localizations.high
                } else {
                    cell.detailTextLabel?.text = Localizations.low
                }
                
            }else if indexPath.row == 1 {
                cell.textLabel?.text = Localizations.layout
                switch Application.layout(){
                    
                case .oneByone:
                    cell.detailTextLabel?.text = "1 x 1"
                case .twoBytwo:
                    cell.detailTextLabel?.text = "2 x 2"
                case .fourByfour:
                    cell.detailTextLabel?.text = "4 x 4"
                }
            }else {
                cell.textLabel?.text = Localizations.clearcache
                cell.detailTextLabel?.text = Localizations.clearcachedetails
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = Localizations.about
            case 1:
                cell.textLabel?.text = Localizations.privacy
            default:
                return cell
            }
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.navigationController?.pushViewController(ServiceViewController(), animated: true)
        case 1:
            switch indexPath.row {
            case 0:
                self.thumbnailQualityAction()
            case 1:
                self.layoutAction()
            case 2:
                ImageCache.default.clearMemoryCache()
            default:
                return
            }
        case 2:
            switch indexPath.row {
            case 0:
                self.aboutUsAction()
            case 1:
                self.privercyURLAction()
            default:
                return
            }
        default:
            return
        }
        
    }
}

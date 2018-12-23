//
//  SearchViewController.swift
//  Danbooru Lite
//
//  Created by Satish on 24/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Async
import Dwifft
import ESPullToRefresh
import FontAwesome_swift
import Material
import RxSwift
import UIKit

class SearchViewController: BooruController {
    
    fileprivate var tableView: TableView!
    fileprivate var diffCalculator: SingleSectionTableViewDiffCalculator<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.prepareSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if tableView != nil{
            tableView.removeFromSuperview()
            tableView = nil
        }
        if diffCalculator != nil{
            diffCalculator = nil
        }
    }
    
    fileprivate func configureTableView() {
        
        self.tableView = TableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: Application.cellIDS.search)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.keyboardDismissMode = .onDrag
        self.view.addSubview(self.tableView)
        
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        
        header = CustomRefreshHeaderAnimator(frame: CGRect.zero)
        
        tableView.es.addPullToRefresh(animator: header) { [weak self] in
            if self == nil {
                return
            }
            self!.tableView.es.stopPullToRefresh()
        }
        
        self.diffCalculator = SingleSectionTableViewDiffCalculator(tableView: self.tableView)
        self.diffCalculator?.insertionAnimation = .fade
        self.diffCalculator?.deletionAnimation = .fade
        
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        if #available(iOS 11, *) {
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        
    }
    
    fileprivate func search(text: String) {
        self.tableView.es.startPullToRefresh()
        queue.addOperation { [weak self] in
            if self == nil {
                return
            }
            RESTClient.tagsAutoComplete(name: text)
                .request()
                // .debug()
                .subscribe({ [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case .next(let meta, let data):
                        if let data: [String] = data as? [String] {
                            self!.diffCalculator?.rows = [text.replacingOccurrences(of: "+", with: " ")] + data
                        }
                        if meta.statusCode == 410 {
                            self!.tableView.es.noticeNoMoreData()
                        }
                    case .error(let error):
                        self!.displayRestError(error: error)
                        break
                    case .completed:
                        self!.tableView.es.stopPullToRefresh()
                    }
                }).disposed(by: self!.disposeBag)
        }
    }
    
    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension SearchViewController: SearchBarDelegate {
    internal func prepareSearchBar() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        searchBar.delegate = self
        searchBar.textField.autocorrectionType = .no
        searchBar.textField.autocapitalizationType = .none
        searchBar.textField.onReturn {
            searchBar.endEditing(true)
        }
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        self.diffCalculator!.rows = []
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let pattern = text?.trimmed, 0 < pattern.utf16.count else {
            self.diffCalculator!.rows = []
            return
        }
        self.search(text: pattern.replacingOccurrences(of: " ", with: "+"))
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: Application.cellIDS.search, for: indexPath) as! TableViewCell
        cell.depthPreset = .depth1
        cell.textLabel?.font = Application.Theme.font.regular._16
        cell.textLabel?.text = self.diffCalculator?.rows[indexPath.row]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = BooruNavigationController(rootViewController: SearchResultController(tag: self.diffCalculator!.rows[indexPath.row].replacingOccurrences(of: " ", with: "+")))
        self.present(controller, animated: true, completion: nil)
    }
}

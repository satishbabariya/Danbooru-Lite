//
//  FlickrSearchController.swift
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

class FlickrSearchController: BooruController {
    
    // MARK: - Attribute -
    
    fileprivate var collectionView: CollectionView!
    fileprivate var collectionLayout: Layout!
    fileprivate var btnLayoutSwitcher: UIBarButtonItem!
    
    fileprivate var diffCalculator: SingleSectionCollectionViewDiffCalculator<Post>?
    
    fileprivate var pageIndex: Int = 1
    fileprivate var pageLimit: Int = 100
    
    fileprivate var tag: String = ""
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = tag
        prepareSearchBar()
        self.configureCollectionView()
        self.collectionView.es.startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        prepareSearchBar()
    }
    
    deinit {
        if collectionView != nil{
            collectionView.removeFromSuperview()
            collectionView = nil
        }
        if btnLayoutSwitcher != nil{
            btnLayoutSwitcher = nil
        }
        if diffCalculator != nil {
            diffCalculator = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.diffCalculator?.items.removeAll()
        self.loadMorePostRequest(page: self.pageIndex)
    }
    
    // MARK: - Configrations -
    
    fileprivate func configureCollectionView() {
        
        self.collectionLayout = Application.device.iPad ? Layout.fourByfour : Layout.twoBytwo
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .vertical
        layout.itemSize = Application.layout().value()//self.collectionLayout.value()
        
        collectionView = CollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = EdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: Application.cellIDS.home)
         collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        if #available(iOS 11, *) {
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        
        self.diffCalculator = SingleSectionCollectionViewDiffCalculator(collectionView: self.collectionView)
        
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        
        header = CustomRefreshHeaderAnimator(frame: CGRect.zero)
        footer = CustomRefreshHeaderAnimator(frame: CGRect.zero)
        
        collectionView.es.addPullToRefresh(animator: header) { [weak self] in
            if self == nil {
                return
            }
            self!.postListRequest()
        }
        
        self.collectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self == nil {
                return
            }
            self?.pageIndex += 1
            self?.loadMorePostRequest(page: self!.pageIndex)
        }
        
        let closeButton = IconButton()
        closeButton.image = UIImage.fontAwesomeIcon(name: FontAwesome.times, textColor: UIColor.white, size: .init(width: 35, height: 35))
        closeButton.tintColor = .white
        closeButton.onTap { [weak self] in
            if self == nil {
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
    }
    
    // MARK: - REST Requests -
    
    fileprivate func postListRequest() {
        if  tag == ""{
            self.collectionView.es.stopPullToRefresh()
            return
        }
        queue.addOperation { [weak self] in
            if self == nil {
                
                return
            }
            RESTClient.flickrSearch(limit: self!.pageLimit, page: 1, name: self!.tag)
                .request()
                // .debug()
                .subscribe({ [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case .next(let meta, let data):
                        if let data: [Post] = data as? [Post] {
                            self?.diffCalculator?.items = data
                        }
                        if meta.statusCode == 410 {
                            self?.collectionView.es.noticeNoMoreData()
                        }
                    case .error(let error):
                        self!.displayRestError(error: error)
                    case .completed:
                        self?.collectionView.es.stopPullToRefresh()
                    }
                }).disposed(by: self!.disposeBag)
        }
    }
    
    fileprivate func loadMorePostRequest(page: Int) {
        queue.addOperation { [weak self] in
            if self == nil {
                return
            }
            RESTClient.flickrSearch(limit: self!.pageLimit, page: page, name: self!.tag)
                .request()
                // .debug()
                .subscribe({ [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case .next(let meta, let data):
                        if let data: [Post] = data as? [Post] {
                            self?.diffCalculator?.items.append(contentsOf: data)
                        }
                        if meta.statusCode == 410 {
                            self?.collectionView.es.noticeNoMoreData()
                        }
                    case .error(let error):
                        self!.displayRestError(error: error)
                    case .completed:
                        self?.collectionView.es.stopLoadingMore()
                    }
                }).disposed(by: self!.disposeBag)
        }
    }
    

    fileprivate func search(text: String) {
        
    }
    
}

extension FlickrSearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diffCalculator?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeCell = collectionView.dequeueReusableCell(withReuseIdentifier: Application.cellIDS.home, for: indexPath) as! HomeCell
        cell.configureCell(Post: self.diffCalculator!.items[indexPath.row])
        cell.loadFile()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell : HomeCell = cell as? HomeCell{
            cell.loadFile()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell : HomeCell = cell as? HomeCell{
            cell.releseFile()
        }
    }
}

//extension FlickrSearchController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return self.collectionLayout.value()
//    }
//}

extension FlickrSearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = LightboxController.init(images: [self.diffCalculator!.items[indexPath.row].lightBoxImage()])//LightboxController(images: self.diffCalculator!.items.flatMap({ $0.lightBoxImage() }))
        controller.booruPage = indexPath.row
        let button = IconButton(image: Icon.cm.menu, tintColor: .white)        
        controller.view.addSubview(button)
        self.present(controller, animated: true)
    }
}

extension FlickrSearchController: SearchBarDelegate {
    internal func prepareSearchBar() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        searchBar.delegate = self
        searchBar.textField.autocorrectionType = .no
        searchBar.textField.autocapitalizationType = .none
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        self.diffCalculator!.items = []
        tag = ""
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let pattern = text?.trimmed, 0 < pattern.utf16.count else {
            self.diffCalculator!.items = []
            tag = ""
            return
        }
        tag = pattern
        postListRequest()
    }
}

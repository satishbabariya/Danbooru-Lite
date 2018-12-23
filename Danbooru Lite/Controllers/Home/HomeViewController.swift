//
//  HomeViewController.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Async
import Dwifft
import ESPullToRefresh
import FontAwesome_swift
import Material
import RxSwift
import UIKit

class HomeViewController: BooruController {

    // MARK: - Attribute -

    fileprivate var collectionView: CollectionView!
    fileprivate var collectionLayout: Layout!
    fileprivate var btnLayoutSwitcher: UIBarButtonItem!

    fileprivate var diffCalculator: SingleSectionCollectionViewDiffCalculator<Post>?

    fileprivate var pageIndex: Int = 1
    fileprivate var pageLimit: Int = 100

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localizations.appname
        self.configureCollectionView()
        self.configureBarButtons()
        self.configureSearchController()
        self.collectionView.es.startPullToRefresh()
    }

    deinit {
        if collectionView != nil {
            collectionView.removeFromSuperview()
            collectionView = nil
        }
        if btnLayoutSwitcher != nil {
            btnLayoutSwitcher = nil
        }
        if diffCalculator != nil {
            diffCalculator = nil
        }
        if collectionLayout != nil {
            collectionLayout = nil
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
        layout.itemSize = Application.layout().value() // self.collectionLayout.value()

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
            self?.postListRequest()
        }

        self.collectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            if self == nil {
                return
            }
            self?.pageIndex += 1
            self?.loadMorePostRequest(page: self!.pageIndex)
        }

        UserDefaults.standard.rx.observe(Int.self, "CollectionViewLayour")
            .debounce(0.1, scheduler: MainScheduler.asyncInstance)
            .subscribe { [weak self] _ in
                if self == nil {
                    return
                }
                let layout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = 5
                layout.minimumInteritemSpacing = 5
                layout.scrollDirection = .vertical
                layout.itemSize = Application.layout().value() // self.collectionLayout.value()
                self!.collectionView.setCollectionViewLayout(layout, animated: true)
            }.disposed(by: self.disposeBag)

    }

    fileprivate func configureBarButtons() {
        let searchButton = IconButton()
        searchButton.image = UIImage.fontAwesomeIcon(name: FontAwesome.search, textColor: UIColor.white, size: .init(width: 25, height: 25))
        searchButton.tintColor = .white
        searchButton.onTap { [weak self] in
            if self == nil {
                return
            }
            switch Application.Service.get() {

            case .flickr, .gelbooru:
                let searchController: MasterSearchController = MasterSearchController(rootViewController: FlickrSearchController())
                self?.present(searchController, animated: true, completion: nil)
                break
            default:
                let searchController: MasterSearchController = MasterSearchController(rootViewController: SearchViewController())
                self?.present(searchController, animated: true, completion: nil)
            }

        }

        let settingsButton = IconButton()
        settingsButton.image = UIImage.fontAwesomeIcon(name: FontAwesome.cog, textColor: UIColor.white, size: .init(width: 25, height: 25))
        settingsButton.tintColor = .white
        settingsButton.onTap { [weak self] in
            if self == nil {
                return
            }
            self!.navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: settingsButton), UIBarButtonItem(customView: searchButton)]
    }

    func configureSearchController() {

    }

    // MARK: - REST Requests -

    fileprivate func postListRequest() {
        queue.addOperation { [weak self] in
            if self == nil {
                return
            }
            RESTClient.posts(limit: self!.pageLimit, page: 1, tags: nil)
                .request()
                // .debug()
                .subscribe({ [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case .next(let meta, let data):
                        if let data: [Post] = data as? [Post] {
                            self!.diffCalculator?.items = data
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
            RESTClient.posts(limit: self!.pageLimit, page: page, tags: nil)
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

}

extension HomeViewController: UICollectionViewDataSource {
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
        if let cell: HomeCell = cell as? HomeCell {
            cell.loadFile()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell: HomeCell = cell as? HomeCell {
            cell.releseFile()
        }
    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = LightboxController(images: [self.diffCalculator!.items[indexPath.row].lightBoxImage()]) // LightboxController(images: self.diffCalculator!.items.flatMap({ $0.lightBoxImage() }))
        controller.booruPage = indexPath.row
        let button = IconButton(image: Icon.cm.menu, tintColor: .white)
        controller.view.addSubview(button)
        self.present(controller, animated: true)
    }

}

enum Layout: Int {
    case oneByone = 0
    case twoBytwo = 1
    case fourByfour = 2

    func value() -> CGSize {
        var width = Screen.width - 10
        var height = width
        switch self {
        case .twoBytwo:
            width = Screen.width - (5 * 3)
            height = width / 2
            return CGSize(width: width / 2, height: height)
        case .fourByfour:
            width = Screen.width - (5 * 5)
            height = width / 4
            return CGSize(width: width / 4, height: height)
        case .oneByone:
            return CGSize(width: width, height: height)
        }
    }
}

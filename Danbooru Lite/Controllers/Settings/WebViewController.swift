//
//  WebViewController.swift
//  Danbooru
//
//  Created by Satish on 31/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import UIKit
import WebKit
import Material
import FontAwesome_swift

class WebViewController: BooruController, WKNavigationDelegate {

    fileprivate var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy Policy"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        self.webView = WKWebView()
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.navigationDelegate = self
        view.addSubview(self.webView)

        let viewDictionary: [String: Any] = ["webView": webView]
        let metrics: [String: Any] = ["hSpace": 0, "vSpace": 0]

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hSpace-[webView]-hSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vSpace-[webView]-vSpace-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewDictionary))

        activityIndicator.startAnimating()
        webView.load(URLRequest(url: URL(string: "https://danbooru-lite.firebaseapp.com/privacy.html")!))

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
    
    deinit {
        if webView != nil {
            webView.removeFromSuperview()
            webView = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
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

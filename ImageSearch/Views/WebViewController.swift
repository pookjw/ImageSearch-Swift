//
//  WebViewController.swift
//  ImageSearch
//
//  Created by pook on 6/12/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var web: WKWebView!
    
    @IBAction func reloadBtn(_ sender: UIBarButtonItem) {
        web.reload()
    }
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        if web.canGoBack {
            web.goBack()
        }
    }
    @IBAction func fwdBtn(_ sender: UIBarButtonItem) {
        if web.canGoForward {
            web.goForward()
        }
    }
    @IBAction func exSafariBtn(_ sender: UIBarButtonItem) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(web.url ?? URL(string: "")!, options: [:], completionHandler: nil)
        }
    }
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        web.navigationDelegate = self
        let request = URLRequest(url: url)
        web.load(request)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}

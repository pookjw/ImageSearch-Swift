//
//  WebViewController.swift
//  ImageSearch
//
//  Created by pook on 6/12/20.
//  Copyright © 2020 jinwoopeter. All rights reserved.
//

import UIKit
import WebKit

// DetailViewController에서 문서를 열여주는 View 입니다. Safari 앱으로 이동시킬 수도 있습니다.
// URL Scheme를 통해 Chrome 앱으로 이동시키는 것도 넣어볼까 생각 중입니다.

class WebViewController: UIViewController {
    var url: URL!
    
    @IBOutlet weak var web: WKWebView!
    @IBAction func doneBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
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
            UIApplication.shared.open(web.url ?? URL(string: "https://smoothy.co/ko")!, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        web.navigationDelegate = self
        let request = URLRequest(url: url)
        web.load(request)
    }
    
    deinit {
        if SettingsManager.show_deinit_log_message {
            print("deinit: WebViewController")
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}

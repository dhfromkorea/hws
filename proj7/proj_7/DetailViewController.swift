//
//  DetailViewController.swift
//  proj_7
//
//  Created by dh on 9/28/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import Foundation
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: [String: String]!
    
    override func loadView() {
        //we interject the default view and replace it with webview
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let html = composeHTMLString()
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func composeHTMLString() -> String {
        var html = "<html>"
        html += "<head>"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "<style> body { font-size: 150%; } </style>"
        html += "</head>"
        html += "<body>"
        html += detailItem["body"]!
        html += "</body>"
        html += "</html>"
        return html
    }
}

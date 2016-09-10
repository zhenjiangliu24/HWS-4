//
//  ViewController.swift
//  HWS-4
//
//  Created by Zhenjiang Liuon 2016-09-10.
//  Copyright © 2016 Zhenjiang Liu. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "facebook.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "HWS-4"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .Plain, target: self, action: #selector(openButtonTapped))
        
        let url = NSURL(string: "https://" + websites[0])!
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
        
        //add progress bar
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        //add tool bar
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.toolbarHidden = false
        
        //KVO for webview loading progress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

}

//button action handler
extension ViewController {
    func openButtonTapped(){
        let alertVC = UIAlertController(title: "Open page", message: nil, preferredStyle: .ActionSheet)
        for website in websites {
            alertVC.addAction(UIAlertAction(title: website, style: .Default, handler: openPage))
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func openPage(sender: UIAlertAction){
        let url = NSURL(string: "https://" + sender.title!)!
        webView.loadRequest(NSURLRequest(URL: url))
    }

}

//KVO
extension ViewController {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.URL
        if let host = url!.host {
            for website in websites {
                if host.rangeOfString(website) != nil {
                    decisionHandler(.Allow)
                    return
                }
            }
        }
        return decisionHandler(.Cancel)
    }
    
}


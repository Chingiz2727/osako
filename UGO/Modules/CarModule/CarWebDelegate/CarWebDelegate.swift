//
//  CarWebDelegate.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 14.05.2023.
//

import Foundation
import WebKit


final class CarWebDelegate: NSObject {
    var onErrorReceive: (() -> Void)?
    var onVinReceive: ((String) -> Void)?
    
    private var webView: WKWebView = .init(frame: .zero)
    private var popupHandler = PopupHandler()

    func start() {
        webView.navigationDelegate = self
        let url = URL (string: "https://www.alfastrah.ru/landing/eosago/")
        let request = URLRequest(url: url!)
        onErrorReceive = popupHandler.popUpPresented
        webView.load(request)
    }
    
    func makeVinRequest(number: String, region: String) {
        let autoNumberScript = "document.getElementById('AUTO_NUMBER').value = '\(number)'"
        let regionScript = "document.getElementsByName('AUTO_REGION')[0].value = '\(region)'"
        let buttonClick = "document.getElementById('btnCalculate').click()"
        let script = "\(regionScript);\(autoNumberScript);\(buttonClick)"
        webView.evaluateJavaScript(script) { value, error in
            print(value)
        }
    }
    
    private func checkPopupWindow() {
        let script = """
            var observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    var popup = document.querySelector('[data-popup-widget-id="js-popup-calculation-errors"]');
                    if (popup && getComputedStyle(popup).display !== "none") {
                        window.webkit.messageHandlers.popupHandler.postMessage("popupVisible");
                    }
                });
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            """
        
        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "popupHandler")
        userContentController.add(popupHandler, name: "popupHandler")
        webView.evaluateJavaScript(script)
    }
}

extension CarWebDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        checkPopupWindow()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let vinScript = "document.getElementsByName('CarIdBodyNumber')[0].value;"
        webView.evaluateJavaScript(vinScript) { [weak self] value, error in
            if let vin = value as? String {
                self?.onVinReceive?(vin)
            }
        }
    }
}

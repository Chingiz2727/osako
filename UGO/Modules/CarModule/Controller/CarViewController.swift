//
//  CarViewController.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 14.05.2023.
//

import UIKit
import UGOUIKit
import WebKit

class CarViewController: UIViewController, ViewHolder {
    typealias RootViewType = CarView
    
    private var delegate: CarWebDelegate
    private let popupHandler = PopupHandler()
    private let fieldValueHandler = FieldValueHandler()

    init(delegate: CarWebDelegate = .init()) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = CarView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView.webView.goBack()
    }
    
    private func setupWebView() {
        let url = URL (string: "https://www.alfastrah.ru/landing/eosago/")
        let request = URLRequest(url: url!)
        rootView.webView.load(request)
    }
    
    private func configure() {
        rootView.webView.navigationDelegate = self
       
        rootView.onSendRequest = { [weak self] number, region in
            self?.makeRequestToField(number: number, region: region)
        }
        
        fieldValueHandler.onReceiveVin = { [weak self] vin in
            self?.rootView.hideLoadingView()
            if vin == "" {
                self?.rootView.setError(text: "Не удалось найти данные по этому номеру")
                self?.rootView.webView.goBack()
            } else {
                let vc = CarInfoViewController(vin: vin)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        popupHandler.popUpPresented = { [weak self] in
            self?.rootView.hideLoadingView()
            self?.rootView.setError(text: "Ошибка, превышено количество запросов")
            self?.rootView.webView.goBack()
        }
    }
    
    private func makeRequestToField(number: String, region: String) {
        let autoNumberScript = "document.getElementById('AUTO_NUMBER').value = '\(number)'"
        let regionScript = "document.getElementsByName('AUTO_REGION')[0].value = '\(region)'"
        let buttonClick = "document.getElementById('btnCalculate').click()"
        let script = "\(regionScript);\(autoNumberScript);\(buttonClick)"
        rootView.showLoadingView()
        rootView.webView.evaluateJavaScript(script)
    }
    
    func setupFieldObserver() {
        let script = """
        var elements = document.getElementsByName('CarIdBodyNumber');
        var value = elements[0].value;
        window.webkit.messageHandlers.fieldValueHandler.postMessage(value);
        """
        
        let userContentController = rootView.webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "fieldValueHandler")
        userContentController.add(fieldValueHandler, name: "fieldValueHandler")
        rootView.webView.evaluateJavaScript(script)
    }
    
    func checkPopupWindow() {
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
        
        let userContentController = rootView.webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "popupHandler")
        userContentController.add(popupHandler, name: "popupHandler")
        rootView.webView.evaluateJavaScript(script)
    }
}

extension CarViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        rootView.hideLoadingView()
        checkPopupWindow()
        setupFieldObserver()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        rootView.showLoadingView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        rootView.hideLoadingView()
        rootView.setError(text: "Ошибка загрузки страницы")
    }
}

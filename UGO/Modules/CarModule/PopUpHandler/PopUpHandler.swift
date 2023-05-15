//
//  PopUpHandler.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 14.05.2023.
//

import Foundation
import WebKit

class PopupHandler: NSObject, WKScriptMessageHandler {
    var popUpPresented: (() -> Void)?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String {
            if messageBody == "popupVisible" {
                self.popUpPresented?()
            }
        }
    }
}

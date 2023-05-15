//
//  FieldValueHandler.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import Foundation
import WebKit
class FieldValueHandler: NSObject, WKScriptMessageHandler {
    var onReceiveVin: ((String) -> Void)?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let value = message.body as? String {
            self.onReceiveVin?(value)
        }
    }
}

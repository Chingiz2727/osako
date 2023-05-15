//
//  ViewController.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 06.04.2022.
//

import UIKit
import UGOCore
import UGOUIKit

class ViewController: UIViewController {

    let button = UGOButton()
    let textField = UGOTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.addSubview(textField)
        button.config = .init(priority: .beta, size: .medium, cornerRadius: 16)
        
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        button.setAttributedTitle(NSAttributedString(string: "Узнать больше", typography: .of(.buttonM), alignment: .center), for: .normal)
//        textField.isFailed = true
        textField.isFailed = true
        
        
    }
}

indirect enum Webkul {
    case startPoint(value: Int)
    case linkNode(value: Int, next: Webkul)
    
    var value: Int {
        switch self {
        case .startPoint(let value):
            return value
        case .linkNode(let value, let next):
            return value + next.value
        }
    }
}

//
//  CarView.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 14.05.2023.
//

import Foundation
import UIKit
import UGOUIKit
import SnapKit
import WebKit

final class CarView: UIView {
    var onSendRequest: ((String, String) -> Void)?
    private let textField = TextFieldContainer<CarNumberTextField>()
    private let sendButton: UGOButton = {
        let button = UGOButton(config: .alphaMedium, frame: .zero)
        button.setAttributedTitle(NSAttributedString(string: "Рассчитать", typography: .buttonM), for: .normal)
        return button
    }()
    
    let webView = WKWebView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialLayout()
        configureView()
    }
    
    func setError(text: String?) {
        textField.error = text
    }
    
    @objc private func send() {
        let carNumber = textField.textField.carNumber
        let regionNumber = textField.textField.regionNumber
        onSendRequest?(carNumber, regionNumber)
    }
    
    private func setupInitialLayout() {
        let stackView = UIStackView(arrangedSubviews: [textField, sendButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        addSubview(webView)
        
        addSubview(stackView)
        
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        webView.isHidden = true
    }
    
    private func configureView() {
        backgroundColor = .gray03
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        textField.titleLabel.text = "Введите номер машины"
        textField.textField.placeholder = "A 111 A 111"
        textField.textField.isFullFilled = { [weak self] isFilled in
            self?.textField.error = nil
            self?.sendButton.isEnabled = isFilled
        }
    }
}


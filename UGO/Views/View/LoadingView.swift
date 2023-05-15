//
//  LoadingView.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 15.05.2023.
//

import Foundation
import UIKit

class LoadingView: UIView {
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func startAnimating() {
        activityIndicatorView.startAnimating()
        isHidden = false
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
}

extension UIView {
    private static let loadingViewTag = 9876
    
    func showLoadingView() {
        // Проверяем, что загрузочный экран еще не отображается
        if let _ = viewWithTag(UIView.loadingViewTag) {
            return
        }
        
        let loadingView = UIView(frame: bounds)
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loadingView.tag = UIView.loadingViewTag
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        addSubview(loadingView)
    }
    
    func hideLoadingView() {
        let loadingView = viewWithTag(UIView.loadingViewTag)
        loadingView?.removeFromSuperview()
    }
}

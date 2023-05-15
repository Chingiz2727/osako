//
//  AppDelegate.swift
//  UGO
//
//  Created by Shyngys Kuandyk on 06.04.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        makeSignInModule()
        // Override point for customization after application launch.
        return true
    }

    private func makeSignInModule() {
        let vc = ViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainNavigationController(rootViewController: CarViewController())
        window?.makeKeyAndVisible()
    }
}


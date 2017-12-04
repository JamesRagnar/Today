//
//  AppDelegate.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataManager = CoreDataManager()
    lazy var dashboardViewModel = DashboardViewModel(coreDataManager: coreDataManager)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: RootViewController(viewModel: dashboardViewModel))
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

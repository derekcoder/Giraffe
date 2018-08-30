//
//  AppDelegate.swift
//  Giraffe
//
//  Created by derekcoder@gmail.com on 03/20/2018.
//  Copyright (c) 2018 derekcoder@gmail.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var app: App?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let window = window {
            app = App(window: window)
        }
        return true
    }

}


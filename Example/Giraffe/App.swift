//
//  App.swift
//  Giraffe_Example
//
//  Created by Derek on 30/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Giraffe

final class App {
    let window: UIWindow
    let webservice = Webservice()
    
    init(window: UIWindow) {
        self.window = window
        configureSearchReposVC()
    }
    
    private func configureSearchReposVC() {
        let nav = window.rootViewController as! UINavigationController
        let searchReposVC = nav.viewControllers[0] as! SearchReposViewController
        searchReposVC.webservice = webservice
    }
}

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
        configureUserDetail()
    }
    
    private func configureUserDetail() {
        let nav = window.rootViewController as! UINavigationController
        let userDetailVC = nav.viewControllers[0] as! UserDetailViewController
        userDetailVC.didShowRepos = { [unowned self, unowned nav] user in
            self.showRepos(for: user, from: nav)
        }
        userDetailVC.webservice = webservice
    }
    
    private func showRepos(for user: User, from: UINavigationController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reposVC = storyboard.instantiateViewController(withIdentifier: "Repos") as! ReposViewController
        reposVC.webservice = webservice
        reposVC.user = user
        from.pushViewController(reposVC, animated: true)
    }    
}

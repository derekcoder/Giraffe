//
//  SearchViewController.swift
//  Giraffe
//
//  Created by derekcoder@gmail.com on 03/20/2018.
//  Copyright (c) 2018 derekcoder@gmail.com. All rights reserved.
//

import UIKit
import Giraffe

class SearchReposViewController: UITableViewController {
    var webservice: Webservice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        let resource = Repo.searchResource(text: "Giraffe")
        webservice.load(resource) { result in
            switch result {
            case .error(let error): print("Failed to search repos: \(error)")
            case .success(let repos):
                print(repos)
            }
        }
    }
}


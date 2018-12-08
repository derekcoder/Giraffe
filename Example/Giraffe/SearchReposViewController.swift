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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var webservice: Webservice!
    private var repos: [Repo] = []
    
    private func search(text: String) {
        spinner.startAnimating()
        let resource = Repo.searchResource(text: text)
        webservice.load(resource) { [weak self] result in
            self?.spinner.stopAnimating()
            switch result {
            case .failure(let error): print(error.localizedDescription)
            case .success(let repos):
                self?.repos = repos
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        cell.textLabel?.text = repos[indexPath.row].fullName
        return cell
    }
}

extension SearchReposViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text else { return }
        search(text: text)
    }
}

//
//  ReposViewController.swift
//  Giraffe_Example
//
//  Created by derekcoder on 8/12/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Giraffe

class RepoCell: UITableViewCell {
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}

class ReposViewController: UITableViewController {
    var user: User!
    var webservice: Webservice!
    private var repos: [Repo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        loadRepos(strategy: .cacheThenReload)
    }
    
    private func loadRepos(strategy: Giraffe.LoadStrategy) {
        let option = Giraffe.Option(strategy: strategy, expiration: .days(2))
        webservice.load(user.reposResource, option: option) { [weak self] result in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            switch result {
            case .failure(let error):
                if error.isNoDataForConditionalRequest {
                    print("No new data to pull")
                } else {
                    print("error: \(error)")
                }
            case let .success(repos, isCached):
                print("loaded \(isCached ? "cached" : "latest") repos")
                self.repos = repos
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Action Methods

    @IBAction func refresh() {
        loadRepos(strategy: .onlyReload)
    }
    
    @IBAction func removeCache() {
        webservice.removeCache(for: user.reposResource)
        repos.removeAll()
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath) as! RepoCell
        let repo = repos[indexPath.row]
        cell.fullNameLabel.text = repo.fullName
        cell.descriptionLabel.text = repo.description ?? "--"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

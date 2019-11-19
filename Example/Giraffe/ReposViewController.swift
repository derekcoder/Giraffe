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
    loadRepos()
  }
  
  private func loadRepos() {
    webservice.load(user.reposResource) { [weak self] response in
      guard let self = self else { return }
      self.refreshControl?.endRefreshing()
      switch response.result {
      case .failure(let error):
        switch error {
        case .requestTimeout: print("Request time out")
        case .invalidResponse: print("Invalid response")
        case .apiFailed(let statusCode): print("API failed with status code: \(statusCode)")
        }
      case .success(let repos):
        print("loaded latest repos")
        self.repos = repos
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: - Action Methods
  
  @IBAction func refresh() {
    loadRepos()
  }
}

extension ReposViewController {
  
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

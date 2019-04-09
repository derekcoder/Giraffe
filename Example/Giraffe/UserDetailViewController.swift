//
//  UserDetailViewController.swift
//  Giraffe_Example
//
//  Created by derekcoder on 8/12/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Giraffe

class UserInfoCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
}

class UserDetailViewController: UITableViewController {
    var webservice: Webservice!
    var didShowRepos: (User) -> () = { _ in }
    
    private enum TableSection: Int, CaseIterable { case info, basic }
    private enum BasicSectionRow: Int, CaseIterable { case repos }
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.beginRefreshing()
        loadUser(strategy: .cacheThenReload)
    }
    
    private func loadUser(strategy: Giraffe.LoadStrategy) {
        let resource = User.resource(for: "derekcoder")
        let option = Giraffe.Option(strategy: strategy, expiration: .hours(2), httpCacheEnabled: true)
        webservice.load(resource, option: option) { [weak self] response in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            switch response.result {
            case .failure(let error):
                switch error {
                case .requestTimeout: print("Request time out")
                case .invalidResponse: print("Not http url response")
                case .apiFailed(let responseError):
                    switch responseError {
                    case .entryNotFound: print("Entry not found")
                    case .notModified: print("No new data to pull")
                    case .permissionDenied: print("Permission denied")
                    case .serverDied: print("Server died")
                    case .others(let statusCode): print("Others response error: \(statusCode)")
                    }
                case .apiResultFailed(let resultError): print("Result error: \(resultError)")
                }
            case .success(let user):
                print("loaded \(response.isCached ? "cached" : "latest") user")
                self.refreshControl?.endRefreshing()
                self.user = user
                self.tableView.reloadData()
                self.loadAvatar()
            }
        }
    }
    
    private func loadAvatar() {
        guard let resource = user?.avatarResource else { return }
        webservice.load(resource) { [weak self] response in
            switch response.result {
            case .failure(let error): print(error.localizedDescription)
            case .success(let image): self?.updateAvatarImageView(with: image)
            }
        }
    }
    
    private func updateAvatarImageView(with avatar: UIImage?) {
        let indexPath = IndexPath(row: 0, section: TableSection.info.rawValue)
        guard let cell = tableView.cellForRow(at: indexPath) as? UserInfoCell else { return }
        cell.avatarImageView.image = avatar
    }
    
    // MARK: - Action
    
    @IBAction func refresh() {
        loadUser(strategy: .onlyReload)
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard user != nil else { return 0 }
        return TableSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard user != nil else { return 0 }
        let tableSection = TableSection.allCases[section]
        switch tableSection {
        case .info: return 1
        case .basic: return BasicSectionRow.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableSection = TableSection.allCases[indexPath.section]
        switch tableSection {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.loginLabel.text = user?.login
            return cell
        case .basic:
            let row = BasicSectionRow.allCases[indexPath.row]
            switch row {
            case .repos:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = "Repos"
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tableSection = TableSection.allCases[indexPath.section]
        switch tableSection {
        case .info: break
        case .basic:
            let row = BasicSectionRow.allCases[indexPath.row]
            switch row {
            case .repos: didShowRepos(user!)
            }
        }
    }
}

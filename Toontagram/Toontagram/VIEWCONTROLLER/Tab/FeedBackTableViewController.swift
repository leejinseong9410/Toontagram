//
//  FeedBackTableViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit

class FeedBackTableViewController: UITableViewController {
    //MARK: - Properties
    private var feedbacks = [FeedBack]() {
        didSet { tableView.reloadData()}
    }
    private let refresher = UIRefreshControl()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchFeedback()
    }
    //MARK: - API
    func fetchFeedback(){
        FeedBackService.fetchFeedBack { feedbacks in
            self.feedbacks = feedbacks
            self.checkFeedBack()
        }
    }
    func checkFeedBack(){
        feedbacks.forEach { feedback in
           guard feedback.type == .fan else { return }
            UserService.checkUserFans(uid: feedback.uid) { fan in
                if let index = self.feedbacks.firstIndex(where: { $0.id == feedback.id }) {
                    self.feedbacks[index].userFan = fan
                }
            }
        }
    }
    //MARK: - Configure
    func configureUI() {
        tableView.register(FeedBackCell.self, forCellReuseIdentifier: FeedBackCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        refresher.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    //MARK: - @objc Action
    @objc func refreshView(){
        feedbacks.removeAll()
        fetchFeedback()
        refresher.endRefreshing()
    }
}
//MARK: - Extension
extension FeedBackTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedBackCell.identifier, for: indexPath) as! FeedBackCell
        cell.viewModel = FeedBackViewModel(feedback: feedbacks[indexPath.row])
        cell.delegate = self
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
}
//MARK: - collectionView Delegate
extension FeedBackTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        UserService.fetchUser(with: feedbacks[indexPath.row].uid) { user in
            self.showLoader(false)
             let vc = ProfileCollectionViewController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - FeedBackCellDelegate
extension FeedBackTableViewController : FeedBackCellDelegate {
    func cell(_ cell: FeedBackCell, fan uid: String) {
        showLoader(true)
        UserService.fanUsers(uid: uid) { _ in
            self.showLoader(false)
            cell.viewModel?.feedback.userFan.toggle()
        }
    }
    
    func cell(_ cell: FeedBackCell, unFan uid: String) {
        showLoader(true)
        UserService.antiFanUser(uid: uid) { _ in
            self.showLoader(false)
            cell.viewModel?.feedback.userFan.toggle()
        }
    }
    
    func cell(_ cell: FeedBackCell, viewCartoon cartoonId: String) {
        showLoader(true)
        CartoonService.fetchCartoon(withCartoonID: cartoonId) { cartoon in
            self.showLoader(false)
            let vc = HomeCollectionViewController()
            vc.cartoon = cartoon
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

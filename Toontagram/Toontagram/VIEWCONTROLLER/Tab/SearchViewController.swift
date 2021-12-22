//
//  SearchViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit

class SearchViewController: UIViewController {
    //MARK: - Properties
    private let tableView = UITableView()
    private var users = [User]()
    private var usersFillter = [User]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchMode : Bool {
        // searchBar 를 탭 || 탭X 상태에 따라 tableView Cell 달라져야됨
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private var cartoons = [Cartoon]()
    
    private lazy var collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .secondarySystemBackground
        cv.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        return cv
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureUI()
        fetchUsers()
        fetchCartoon()
    }
    //MARK:  API
    func fetchUsers(){
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData() // 리로드 해줘야 쓰레드 한번 더 돌때 데이터가 들어가서 View로 나옴
        }
    }
    func fetchCartoon(){
        CartoonService.fetchCartoons { cartoons in
            self.cartoons = cartoons
            self.collectionView.reloadData()
        }
    }
    //MARK: - Configure
    private func configureUI(){
        view.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.rowHeight = 64
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.isHidden = true
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요."
        // searchController의 text값으로 변경하려면 무조건 UISearchBarDelegate으로 받아야한다.
        // UISearchControllerDelegate 로 extension해도 값변경이 절대되지 않는다...
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    //MARK: - @objc Action
    
    
    
}
//MARK: - Extension
extension SearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 모드에 따라서 검색한 유저 count , 검색을 하지 않을경우 fetch 한 user들 count
        return searchMode ? usersFillter.count : users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        // cell viewModel 인스턴스 생성하기전에
        // searchMode Bool 값에 따라서 true 즉 검색을 했으면 userFillter로 parm 을 넣어줌
        // 그렇지 않을경우는 users 를 넣어줌 즉 fetch한 전체 유저(스타)
        let user = searchMode ? usersFillter[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        return cell
    }
}
// MARK: - TableView Delegate - !!!didSelect!!!
extension SearchViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileVC = ProfileCollectionViewController(user: users[indexPath.row])
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
//MARK: UISearchBarDelegate
// searchController의 text값으로 변경하려면 무조건 UISearchBarDelegate으로 받아야한다.
// UISearchControllerDelegate 로 extension해도 값변경이 절대되지 않는다...
extension SearchViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        collectionView.isHidden = true
        tableView.isHidden = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        collectionView.isHidden = false
        tableView.isHidden = true
    }
}
//MARK: UISearchResultsUpdating
extension SearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // 검색한 데이터 필터로 찾아오기
        // name , penname 으로 검색했을때 나오게 한뒤
        // 검색된 결과를 -> Properties - usersFillter -> 그후 테이블 리로드가 되면 쓰레드가 한번 더돌기 때문에
        // 그때 cellForRowAt에서 viewModel의 값이 달라짐
        guard let searchText = searchController.searchBar.text else { return }
        usersFillter = users.filter({
            // contains 정도로도 괜찮을것 같다
            // if는 쓰지 말기 ...ㅎㅎ
            $0.name.contains(searchText) ||
            $0.penname.contains(searchText)})
        self.tableView.reloadData()
    }
}
//MARK: - CollectionView DataSource
extension SearchViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
        cell.viewModel = CartoonViewModel(cartoon: cartoons[indexPath.row])
        cell.backgroundColor = .blue
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartoons.count
    }
    
}
//MARK: - CollectionView Delegate
extension SearchViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CartoonViewController()
        vc.cartoon = cartoons[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension SearchViewController : UICollectionViewDelegateFlowLayout{
    // cell 사이 간격주기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}

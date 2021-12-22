//
//  ProfileCollectionViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit
import Firebase

class ProfileCollectionViewController: UICollectionViewController, EditProfileViewControllerDelegate {

    //MARK: - Properties
    private var user : User
    init(user : User) {
        self.user = user
        // FlowLayout 인지 확인 잘하기...!!!
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    private var cartoons = [Cartoon]() {
        didSet { collectionView.reloadData()}
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var logOutMenu : UIMenu = {
        return UIMenu(title: "", image: nil, options:.displayInline , children: menuInstance)
    }()
    private lazy var menuInstance : [UIAction] = {
        return [UIAction(title: "로그아웃", image: nil,handler: { _ in
            do{
                try Auth.auth().signOut()
                let loginVC = LogInViewController()
                loginVC.delegate = self.tabBarController as? RootTabBarController
                let navi = UINavigationController(rootViewController: loginVC)
                navi.modalPresentationStyle = .fullScreen
                self.present(navi, animated: true, completion: nil)
            }catch{
                print("DEBUG = logOut")
            }
        }),
                UIAction(title: "취소", handler: { _ in
                print("취소")
        })
        ]
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        checkFansForUser()
        fetchUserStats()
        fetchCartoons()
    }
    //MARK: - API
    func checkFansForUser() {
        UserService.checkUserFans(uid: user.uid) { valued in
            self.user.fan = valued
            self.collectionView.reloadData()
        }
    }
    func fetchUserStats(){
        UserService.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    func fetchCartoons(){
        CartoonService.fetchCartoons(id: user.uid) { cartoons in
            self.cartoons = cartoons
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    //MARK: - Configure
    private func configureUI(){
        navigationItem.title = user.name
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(wantRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
        let logOutImage = UIImage(systemName: "ellipsis.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: logOutImage, style: .plain, target: self, action:nil)
        navigationItem.rightBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.menu = logOutMenu
    }
    //MARK: - @objc Action
    @objc private func wantRefresh(){
        cartoons.removeAll()
        fetchCartoons()
    }
    
    func didFinish(_ vc: EditProfileViewController) {
        vc.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        let vc = RootTabBarController()
        vc.user = user
        vc.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
}
//MARK: - Extension
// MARK: - collectionView DataSource
extension ProfileCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartoons.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
        cell.viewModel = CartoonViewModel(cartoon: cartoons[indexPath.row])
        return cell
    }
    // MARK: - collectionView DataSource - Header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
            header.delegate = self
            header.viewModel = ProfileHeaderViewModel(user: user)
            return header
    }
}
// MARK: - collectionView Delegate
extension ProfileCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CartoonViewController()
        vc.cartoon = cartoons[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - collectionView DelegateFlowLayout
extension ProfileCollectionViewController : UICollectionViewDelegateFlowLayout{
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
    // Header 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 0, bottom: 1.0, right: 0)
    }
}
// MARK: - ProfileHeaderDelegate
extension ProfileCollectionViewController : ProfileHeaderDelegate {
    func header(_ header: ProfileHeader, didTapButton user: User) {
        guard let tab = self.tabBarController as? RootTabBarController else { return }
        guard let currentUser = tab.user else { return }
        if user.currentUser {
            // 프로필 편집.
            print("called - ProfileHeaderDelegate")
            let vc = EditProfileViewController()
            vc.user = self.user
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
            
        }else if user.fan {
            UserService.antiFanUser(uid: user.uid) { error in
                self.user.fan = false
                self.collectionView.reloadData()
                CartoonService.updateMainUserAfterFan(user: user, didFan: false)
            }
        }else{
            UserService.fanUsers(uid: user.uid) { error in
                self.user.fan = true
                self.collectionView.reloadData()
                FeedBackService.uploadFeedBack(toUid: user.uid, type: .fan, user: currentUser)
                CartoonService.updateMainUserAfterFan(user: user, didFan: true)
            }
        }
    }
}


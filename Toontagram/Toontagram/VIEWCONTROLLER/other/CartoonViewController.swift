//
//  CartoonViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit
import SnapKit
import SDWebImage
import Firebase

class CartoonViewController: UIViewController {
    //MARK: - Properties
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex,envi) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createCartoonCompositional()
            default: fatalError()
            }
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CartoonCell.self, forCellWithReuseIdentifier:CartoonCell.identifier)
        collectionView.register(CartoonMIDCell.self, forSupplementaryViewOfKind: CartoonMIDCell.idenfitier , withReuseIdentifier: CartoonMIDCell.idenfitier)
        return collectionView
    }()
    private lazy var profileImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTap))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    private lazy var profileName : UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(didTapUserName), for: .touchUpInside)
        return button
    }()
    private lazy var titleLabel : UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    var cartoon : Cartoon? {
        didSet {
            collectionView.reloadData()
            configureUI()
        }
    }
    var user : User? {
        didSet {
            collectionView.reloadData()
        }
    }
    var cartoonImageArray = [URL?]() {
        didSet {
            collectionView.reloadData()
            configureUI()
        }
    }
    private lazy var editMenu : UIMenu = {
        return UIMenu(title: "", image: nil, options:.displayInline , children: menuInstance)
    }()
    private lazy var menuInstance : [UIAction] = {
        return [UIAction(title: "수정", image: nil,handler: { _ in
            let vc = EditViewController()
            vc.delegate = self
            vc.cartoon = self.cartoon
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navi, animated: true, completion: nil)
        }),UIAction(title: "삭제", image: nil, handler: { _ in
            let alert = UIAlertController(title: "게시글 삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
                guard let cartoon = self.cartoon else { return }
                CartoonService.deleteCartoon(cartoon: cartoon) { result in
                    if result {
                        self.dismiss(animated: true, completion: nil)
                        let root = RootTabBarController()
                        root.user = self.user
                        self.navigationController?.pushViewController(root, animated: true)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }),UIAction(title: "취소", handler: { _ in
            print("취소")
        })
        ]
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cartoonSub()
        checkUserLikeCartoon()
        configureUI()

    }
    //MARK: - API
    func cartoonSub(){
        guard let cartoon = cartoon else { return }
        let array = [cartoon.thumbnailImage,cartoon.page1,cartoon.page2,cartoon.page3,cartoon.page4]
        var urlArray = [URL?]()
        array.forEach { ary in
            urlArray.append(URL(string: ary))
        }
        self.cartoonImageArray = urlArray
    }
    func checkUserLikeCartoon(){
        if let cartoon = cartoon {
            CartoonService.checkUserLikeCartoon(cartoon: cartoon) { like in
                self.cartoon?.didLike = like
            }
        }else{
            guard let cartoon = cartoon else { return }
            CartoonService.checkUserLikeCartoon(cartoon: cartoon) { like in
                self.cartoon?.didLike = like
        }
    }
}
    //MARK: - Configure
    func configureUI(){
        guard let cartoon = cartoon else { return }
        let vm = CartoonViewModel(cartoon: cartoon)
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        profileImageView.sd_setImage(with: vm.userProfileImageUrl)
        profileImageView.layer.cornerRadius = 80/2
        view.addSubview(profileName)
        profileName.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.width.equalTo(120)
            make.height.equalTo(20)
        }
        profileName.setTitle(vm.username, for: .normal)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileName.snp.bottom).offset(8)
            make.leading.equalTo(profileName.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        titleLabel.text = "제목: \(vm.title)"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(wantRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //만화의 작가 와 currentUser 가 일치하는지 보고 일치할 경우에만 수정,삭제 메뉴를 보일수 있게 하기
        // 만화의 uid와 Auth.auth().currentUser?.uid 를 비교해서 일치하면 버튼 생성
        // 뷰전환시 user를 따로 받아와도 되지만 이부분에서만 쓰기 때문에 굳이 받진 않음
        if cartoon.uid == uid {
            let rightImage = UIImage(systemName: "ellipsis.circle")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImage, style: .plain, target: self, action:nil)
            navigationItem.rightBarButtonItem?.tintColor = .label
            navigationItem.rightBarButtonItem?.menu = editMenu
        }
    }
    //MARK: - ConfigureCompositionalLayout
    private func createCartoonCompositional() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.trailing = 15
        item.contentInsets.bottom = 15
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(500))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), elementKind: CartoonMIDCell.idenfitier, alignment: .bottom)]
        return section
    }
    //MARK: - @objc Method
    @objc func profileTap(){
        
    }
    @objc func didTapUserName(){
        
    }
    @objc func wantRefresh(){
       
    }
}
//MARK: - collectionView DataSource
extension CartoonViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartoonCell.identifier, for: indexPath) as! CartoonCell
        // indexPath.row 를 이용한 switch로 cell에게 이미지를 row 의 값별로 따로따로 넣어주어도 되긴하지만
        // 그렇게 되면 image가 들어가는데 딜레이가 걸림  DispatchQueue를 걸어도 마찬가지 그래서 미리 전처리를 한후에
        // cell에 URL을 넣어주고 cell안에서 URL를 이용해서 이미지를 적용
        cell.imageURL = cartoonImageArray[indexPath.row]
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 5
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CartoonMIDCell.idenfitier, for: indexPath) as! CartoonMIDCell
        if let cartoon = cartoon {
            header.viewModel = CartoonViewModel(cartoon:cartoon)
        }
        header.delegate = self
        return header
    }
}
//MARK: - collectionView Delegate
extension CartoonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
//MARK: - cellDelegate Protocol
extension CartoonViewController : CartoonMIDCellDelegate {
    func cell(_ cell: CartoonMIDCell, showComments cartoon: Cartoon) {
        let vc = CommentCollectionViewController(cartoon: cartoon)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func cell(_ cell: CartoonMIDCell, didLike cartoon: Cartoon) {
        guard let tab = self.tabBarController as? RootTabBarController else { return }
        guard let user = tab.user else { return }
        cell.viewModel?.cartoon.didLike.toggle()
        if cartoon.didLike {
            CartoonService.unLikeCartoon(cartoon: cartoon) { error in
                let image = UIImage(systemName: "hand.thumbsup")
                DispatchQueue.main.async {
                    cell.likeButton.setImage(image, for: .normal)
                }
            }
        }else{
            CartoonService.likeCartoon(cartoon: cartoon) { error in
                let image = UIImage(systemName: "heart.fill")
                DispatchQueue.main.async {
                    cell.likeButton.setImage(image, for: .normal)
                    FeedBackService.uploadFeedBack(toUid: cartoon.uid, type: .like, cartoon: cartoon,user: user)
                }
            }
        }
    }
    func cell(_ cell: CartoonMIDCell, showProfile uid: String) {
        UserService.fetchUser(with: uid) { user in
            let vc = ProfileCollectionViewController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
extension CartoonViewController : EditViewControllerDelegate {
    func vcDidFinish(_ vc: EditViewController) {
        vc.dismiss(animated: true, completion: nil)
        self.cartoon = vc.newCartoon
    }
}

//
//  DrawViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit
import SnapKit
protocol SetUpViewControllerDelegate : AnyObject {
    func vcDidFinish(_ vc : SetUpViewController)
}
class SetUpViewController: UIViewController {
    //MARK: - Properties
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SetUpViewController.createCompositionalLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SetUpCell.self, forCellWithReuseIdentifier:SetUpCell.identifier)
        return collectionView
    }()
    //MARK: - Protocol delegate
    weak var delegate : SetUpViewControllerDelegate?
    
    var viewModel : SetUpViewModel? {
        didSet { collectionView.reloadData() }
    }
    private var user : User
    
    init(user : User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       tabBarController?.tabBar.isHidden = false
    }
    //MARK: - Configure
    static func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex , envi) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets.bottom = 15
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(240))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    }
    func setupNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "업로드", style: .plain, target: self,action: #selector(successHandle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelHandle))
    }
    func configure(){
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.leading.trailing.bottom.equalToSuperview()
        }
    }
    //MARK: - @objc Action
    @objc func successHandle(){
        let vc = UploadViewController()
        vc.delegate = self
        vc.delegates = self
        vc.currentUser = user
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true, completion: nil)
        
    }
    @objc func cancelHandle(){
        self.showLoader(true)
        let alert = UIAlertController(title: "돌아가기", message: "정보는 저장되지 않습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            self.showLoader(false)
           // UserDefaults 데이터는 rootTabbar에서 모두 삭제.
            self.delegate?.vcDidFinish(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - Extension
extension SetUpViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetUpCell.identifier, for: indexPath) as! SetUpCell
        switch indexPath.section {
        case 0:
            if let imgData = UserDefaults.standard.object(forKey: "thumbnail") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    cell.configure(text: "THUMBNAIL", image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(text: "THUMBNAIL", image: image)
                }}
        case 1:
            if let imgData = UserDefaults.standard.object(forKey: "page1") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    cell.configure(text: "PAGE-1", image: img)}
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") { cell.configure(text: "PAGE-1", image: image)}}
        case 2:
            if let imgData = UserDefaults.standard.object(forKey: "page2") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    cell.configure(text: "PAGE-2", image: img)}
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") { cell.configure(text: "PAGE-2", image: image)}}
        case 3:
            if let imgData = UserDefaults.standard.object(forKey: "page3") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    cell.configure(text: "PAGE-3", image: img)}
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") { cell.configure(text: "PAGE-3", image: image)}}
        case 4:
            if let imgData = UserDefaults.standard.object(forKey: "page4") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    cell.configure(text: "PAGE-4", image: img)}
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") { cell.configure(text: "PAGE-4", image: image)}}
        default :
            fatalError("ERROR")
        }
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
}
extension SetUpViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DrawViewController(user: user, section: indexPath.section)
        vc.delegate = self
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true, completion: nil)
    }
}

extension SetUpViewController : DrawViewControllerDelegate {
    func vcDidFinish(_ vc: DrawViewController) {
        vc.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}
extension SetUpViewController : VCdismissDelegate {
    func vcdismissProtocol(_ vc: UIViewController) {
        vc.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}
extension SetUpViewController : UploadViewControllerDelegate {
    func vcDidFinish(_ vc: UploadViewController) {
        vc.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        let vc = RootTabBarController()
        vc.user = user
        vc.modalPresentationStyle = .fullScreen
        tabBarController?.present(vc, animated: true, completion: nil)
    }
}

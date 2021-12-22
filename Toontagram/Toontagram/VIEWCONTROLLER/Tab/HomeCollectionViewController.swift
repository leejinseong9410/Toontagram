//
//  HomeCollectionViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import Firebase
import SnapKit
import Combine

class HomeCollectionViewController: UIViewController {
    //MARK: - Properties
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex,envi) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0 : return self.homeFirstCreateCompositionalLayout()
            case 1 : return self.homeSecondCreateCompositionalLayout()
            default: fatalError()
            }
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HomeTopCell.self, forCellWithReuseIdentifier:HomeTopCell.identifier)
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier:HomeCell.identifier)
        collectionView.register(HomeHeader.self, forSupplementaryViewOfKind: HomeHeader.identifier, withReuseIdentifier: HomeHeader.identifier)
        return collectionView
    }()
    var cartoons = [Cartoon]() {
        didSet { collectionView.reloadData() }
    }
    var cartoon : Cartoon? {
        didSet { collectionView.reloadData() }
    }
    var userSelect = "ALL" {
        didSet { collectionView.reloadData() }
    }
    var recomToons = [Cartoon]() {
        didSet { collectionView.reloadData() }
    }
    var loveToons = [Cartoon]() {
        didSet { collectionView.reloadData() }
    }
    var dailyToons = [Cartoon]() {
        didSet { collectionView.reloadData() }
    }
    var actionToons = [Cartoon]() {
        didSet { collectionView.reloadData() }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCartoon()
        configure()
    }
    //MARK: - API
    func fetchCartoon() {
        self.cartoons.removeAll()
        guard cartoon == nil else { return }
        CartoonService.fetchCartoonFeed { cartoons in
            cartoons.forEach { cartoon in
                if cartoon.type == "RECOM" {
                    if self.recomToons.contains(cartoon) == false {
                        self.recomToons.append(cartoon)
                    }
                }else if cartoon.type == "DAILY" {
                    if self.dailyToons.contains(cartoon) == false {
                        self.dailyToons.append(cartoon)
                        self.cartoons.append(cartoon)
                    }
                }else if cartoon.type == "ACTION" {
                    if self.actionToons.contains(cartoon) == false {
                        self.actionToons.append(cartoon)
                        self.cartoons.append(cartoon)
                    }
                }else{
                    if self.loveToons.contains(cartoon) == false {
                        self.loveToons.append(cartoon)
                        self.cartoons.append(cartoon)
                    }
                }
            }
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    
    //MARK: - Configure
    func configure(){
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(wantRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    //MARK: - ConfigureCompositionalLayout(1)
    private func homeFirstCreateCompositionalLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .absolute(200))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize,
                                                             subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        return layoutSection
    }
    //MARK: - ConfigureCompositionalLayout(2)
    private func homeSecondCreateCompositionalLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(130),
                                              heightDimension: .absolute(170))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                     heightDimension: .estimated(600))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize,
                                                             subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)), elementKind: HomeHeader.identifier, alignment: .top)]
        return layoutSection
    }
    
    //MARK: - @objc
    @objc func wantRefresh(){
        cartoons.removeAll()
        fetchCartoon()
    }
}
extension HomeCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTopCell.identifier, for: indexPath) as! HomeTopCell
            cell.viewModel = CartoonViewModel(cartoon: self.recomToons[indexPath.row])
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.identifier, for: indexPath) as! HomeCell
            DispatchQueue.main.async {
                switch self.userSelect {
            case "LOVE" :
                    cell.viewModel = CartoonViewModel(cartoon: self.loveToons[indexPath.row])
            case "DAILY" :
                    cell.viewModel = CartoonViewModel(cartoon: self.dailyToons[indexPath.row])
            case "ACTION" :
                    cell.viewModel = CartoonViewModel(cartoon: self.actionToons[indexPath.row])
            case "ALL" :
                    cell.viewModel = CartoonViewModel(cartoon: self.cartoons[indexPath.row])
            default : fatalError()
            }
        }
            return cell
    }
}
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return recomToons.count
        }else{
                var count = 0
                switch self.userSelect {
                case "LOVE" :
                    count = self.loveToons.count
                case "ACTION" :
                    count = self.actionToons.count
                case "DAILY" :
                    count = self.dailyToons.count
                case "ALL" :
                    count = self.cartoons.count
                default :
                    break
            }
            return count
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeHeader.identifier, for: indexPath) as! HomeHeader
        header.delegate = self
        return header
    }
    
}
extension HomeCollectionViewController : UICollectionViewDelegate {
    // 카툰테이블로보내기.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //RECOM
        if indexPath.section == 0 {
            let vc = CartoonViewController()
            vc.cartoon = self.recomToons[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        //CARTOON
        }else{
            let vc = CartoonViewController()
            vc.cartoon = self.cartoons[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension HomeCollectionViewController : HomeHeaderDelegate {
    func didAllTab(_ category: String) {
        print(self.userSelect)
        self.userSelect = category }
    func didLoveTab(_ category: String) { self.userSelect = category }
    func didActionTab(_ category: String) { self.userSelect = category }
    func didDailyTab(_ category: String) { self.userSelect = category }
}

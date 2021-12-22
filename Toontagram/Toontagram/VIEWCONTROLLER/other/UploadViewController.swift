//
//  UploadViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SnapKit

protocol UploadViewControllerDelegate : AnyObject {
    func vcDidFinish(_ vc : UploadViewController)
}
class UploadViewController: UIViewController {
    //MARK: - Properties
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UploadViewController.createCompositionalLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UploadCell.self, forCellWithReuseIdentifier:UploadCell.identifier)
        return collectionView
    }()
    
    private let titleTF = CustomTF(placholder: "타이틀을 적어주세요.")
    private var categoryBtn : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("카테고리", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.backgroundColor = .darkGray
        bt.layer.cornerRadius = 10
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return bt
    }()
    var currentUser : User?
    var delegate : VCdismissDelegate?
    
    var delegates : UploadViewControllerDelegate?
    
    private lazy var menuInstance : [UIAction] = {
        return [UIAction(title: "LOVE", image: nil,handler: { _ in
            self.categoryBtn.setTitle("LOVE", for: .normal)
        }),
                UIAction(title: "ACTION", image: nil,handler: { _ in
            self.categoryBtn.setTitle("ACTION", for: .normal)
        }),
                UIAction(title: "DAILY", image: nil,handler: { _ in
            self.categoryBtn.setTitle("DAILY", for: .normal)
        }),
                UIAction(title: "RECOM", image: nil,handler: { _ in
            self.categoryBtn.setTitle("RECOM", for: .normal)
        })
        ]
    }()
    private var thumbnail : UIImage!
    private var page1 : UIImage!
    private var page2 : UIImage!
    private var page3 : UIImage!
    private var page4 : UIImage!
    
    private lazy var categoryMenu : UIMenu = {
        return UIMenu(title: "", image: nil, options:.displayInline , children: menuInstance)
    }()
    private lazy var captionTextView : InputTextView = {
       let textView = InputTextView()
        textView.placeholderText = "만화의 설명이 필요합니다." // textView input 값들어오면 없어질 text
        textView.font = .systemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.delegate = self
        textView.placeholderCenter = false
        return textView
    }()
    private let characterLabel : UILabel = {
       let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12)
        label.text = "0/100"
        return label
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setupNavigation()
    }
    //MARK: - Configure
    func configure(){
        view.addSubview(categoryBtn)
        categoryBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        categoryBtn.menu = categoryMenu
        view.addSubview(titleTF)
        titleTF.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(categoryBtn.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        view.addSubview(captionTextView)
        captionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTF.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        view.addSubview(characterLabel)
        characterLabel.snp.makeConstraints { make in
            make.top.equalTo(captionTextView.snp.bottom)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(15)
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(characterLabel.snp.bottom).offset(20)
            make.centerX.leading.bottom.trailing.equalToSuperview()
        }
    }

    
    //MARK: - Navigation Setup
    func setupNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self,action: #selector(successHandle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelHandel))
    }
    //MARK: - Configure CompositionalLayout
    static func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex , envi) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets.trailing = 5
            item.contentInsets.bottom = 5
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    }
    //MARK: - characterLabel Count Check Method
    func characterLabelCountCheck(_ texView : UITextView){
        if (texView.text.count) > 100 {
            texView.deleteBackward()
        }
    }
    //MARK: - @objc Method
    
    @objc func successHandle(){
        showLoader(true)
        guard let titleTxt = titleTF.text ,let caption = captionTextView.text, let user = currentUser, let type = categoryBtn.titleLabel?.text else { return }
        let getData = getUserDefaultsData()
        showLoader(true)
        CartoonService.uploadCartoon(title: titleTxt, caption: caption, image: getData, user: user, type: type) { error in
            self.showLoader(false)
            if error != nil {
                print("DEBUG😰 = uploadFail \(String(describing: error?.localizedDescription))")
                return
            }
            self.delegates?.vcDidFinish(self)
        }
    }
    @objc func cancelHandel(){
        let alert = UIAlertController(title: "돌아가기", message: "정보는 저장되지 않습니다\n첫번째 페이지로 이동합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            self.delegate?.vcdismissProtocol(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func getUserDefaultsData() -> [UIImage] {
        let defaultArray = [
            UserDefaults.standard.object(forKey: "thumbnail"),
            UserDefaults.standard.object(forKey: "page1"),
            UserDefaults.standard.object(forKey: "page2"),
            UserDefaults.standard.object(forKey: "page3"),
            UserDefaults.standard.object(forKey: "page4")
        ]
        var newImageArray = [UIImage]()
        
        defaultArray.forEach { image in
            if let imgData = image as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    newImageArray.append(img)
                }
            }
        }
        return newImageArray
    }
    
}
extension UploadViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UploadCell.identifier, for: indexPath) as! UploadCell
        switch indexPath.row {
        case 0:
            if let imgData = UserDefaults.standard.object(forKey: "thumbnail") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    self.thumbnail = img
                    cell.configure(image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(image: image)
                }}
        case 1:
            if let imgData = UserDefaults.standard.object(forKey: "page1") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    self.page1 = img
                    cell.configure(image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(image: image)
                }}
        case 2:
            if let imgData = UserDefaults.standard.object(forKey: "page2") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    self.page2 = img
                    cell.configure(image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(image: image)
                }}
        case 3:
            if let imgData = UserDefaults.standard.object(forKey: "page3") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    self.page3 = img
                    cell.configure(image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(image: image)
                }}
        default :
            if let imgData = UserDefaults.standard.object(forKey: "page4") as? NSData {
                if let img = UIImage(data: imgData as Data ) {
                    self.page4 = img
                    cell.configure(image: img)
                }
            }else{
                if let image = UIImage(systemName:"photo.on.rectangle.angled") {
                    cell.configure(image: image)
                }}
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
}
extension UploadViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
//MARK: - UITextViewDelegate
extension UploadViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        characterLabelCountCheck(textView)
        let count = textView.text.count
        characterLabel.text = "\(count)/100"
    }
}

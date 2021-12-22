//
//  EditViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit
protocol EditViewControllerDelegate : AnyObject {
    func vcDidFinish(_ vc : EditViewController)
}
class EditViewController: UIViewController {
    //MARK: - Properties
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: EditViewController.createCompositionalLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CartoonCell.self, forCellWithReuseIdentifier:CartoonCell.identifier)
        return collectionView
    }()
    private let titleTF = CustomTF(placholder: "타이틀을 적어주세요.")
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
    private var categoryBtn : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("카테고리", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.backgroundColor = .darkGray
        bt.layer.cornerRadius = 10
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return bt
    }()
    private lazy var categoryMenu : UIMenu = {
        return UIMenu(title: "", image: nil, options:.displayInline , children: menuInstance)
    }()
    
    var delegate : EditViewControllerDelegate?
    
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
    
    var cartoon : Cartoon? {
        didSet {
            collectionView.reloadData()
            configureUI()
        }
    }
    var cartoonImageArray = [URL?]() {
        didSet {
            collectionView.reloadData()
            configureUI()
        }
    }
    var newCartoon : Cartoon?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cartoonSub()
        
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
    //MARK: - Configure
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .done, target: self, action: #selector(didTapEdit))
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
    @objc func didTapEdit(){
    guard let tf = titleTF.text,let tfView = captionTextView.text,let type = categoryBtn.titleLabel?.text else { return }
        if (tf.isEmpty && tfView.isEmpty && type == "카테고리") == true {
            let alert = UIAlertController(title: "미설정", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }else{
            if type == "카테고리" {
                let alert = UIAlertController(title: "미설정", message: "카테고리를 설정 해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }else if tf.isEmpty == true {
                let alert = UIAlertController(title: "미설정", message: "제목을 입력해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }else if tfView.isEmpty == true {
                let alert = UIAlertController(title: "미설정", message: "설명을 입력해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }else{
                guard let cartoon = cartoon else { return }
                CartoonService.editCartoon(type: type, cartoonId:cartoon.cartoonId, title:tf, caption: tfView) { newCartoon in
                    self.newCartoon = newCartoon
                    self.delegate?.vcDidFinish(self)
                }
            }
        }
    }
}
extension EditViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartoonCell.identifier, for: indexPath) as! CartoonCell
        cell.imageURL = self.cartoonImageArray[indexPath.row]
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
}
extension EditViewController : UICollectionViewDelegate {
    
}
//MARK: - UITextViewDelegate
extension EditViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        characterLabelCountCheck(textView)
        let count = textView.text.count
        characterLabel.text = "\(count)/100"
    }
}


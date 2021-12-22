//
//  CommentCollectionViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit

class CommentCollectionViewController: UICollectionViewController {
    //MARK: - Properties
    // 댓글 업로드를 위한 인스턴스
    private let cartoon:Cartoon
    private var comments = [Comment]()
    private lazy var commentInput : CommentInputView = {
        let fram = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let inputView = CommentInputView(frame: fram)
        inputView.delegate = self
        return inputView
    }()
    //MARK: - Lifecycle
    init(cartoon:Cartoon) {
        self.cartoon = cartoon
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchComments()
    }
    override var inputAccessoryView: UIView? {
        get { return commentInput }
    }
    //키보드올리고내리고기능
    override var canBecomeFirstResponder: Bool {
        return true
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
    func configureUI(){
        title = "comments"
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.identifier)
        // 스크롤시 키보드 내리기
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    
    //MARK: - API
    func fetchComments(){
        CommentService.fetchComment(forCartoon: cartoon.cartoonId) { comments in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
}

//MARK: - CollectionView DataSource
extension CommentCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
//MARK: - CollectionView Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uid = comments[indexPath.row].uid
        UserService.fetchUser(with: uid) { user in
            let vc = ProfileCollectionViewController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
//MARK: - CollectionViewDelegateFlowLayout
extension CommentCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(with: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
    
}
//MARK: - CommentInputViewDelegate
extension CommentCollectionViewController : CommentInputViewDelegate {
    func inputView(_ inputView: CommentInputView, loadComment comment: String) {
        // 업로드가 완료되면 textView에 text를 지워주고
        // text가 입력되면서 숨겨져있던 placeholderlabel을 다시 뷰에 보이게 만들어주는 method
 
        guard let tab = self.tabBarController as? RootTabBarController else { return }
        guard let currentUser = tab.user else { return }
        self.showLoader(true)
        CommentService.uploadComment(comment: comment, cartoonID: cartoon.cartoonId, user: currentUser) { error in
            self.showLoader(false)
            inputView.allClearComment()
            FeedBackService.uploadFeedBack(toUid: self.cartoon.uid, type: .comment, cartoon: self.cartoon, user: currentUser)
        }
    }
}

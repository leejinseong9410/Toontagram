//
//  CommentInputView.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit
import SnapKit

protocol CommentInputViewDelegate : AnyObject {
    // 댓글을 collection , Database에 업로드 할 delegate method(protocol)
    func inputView(_ inputView : CommentInputView , loadComment comment : String )
}

class CommentInputView : UIView {
    //MARK: - Properties
    
    weak var delegate : CommentInputViewDelegate?
    
    private let commentTextView : InputTextView = {
       let textView = InputTextView()
        textView.placeholderText = "댓글을 입력해주세요."
        textView.font = .systemFont(ofSize: 12, weight: .regular)
        textView.isScrollEnabled = false
        textView.placeholderCenter = true
        return textView
    }()
    private let commentButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        return button
    }()
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 키보드를 올리고 내리고할때 inputView의 위치도 맞게 조정하기
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        addSubview(commentButton)
        commentButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-8)
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
        addSubview(commentTextView)
        commentTextView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalTo(commentButton.snp.left).offset(8)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        let divider = UIView()
        divider.backgroundColor = .lightGray
        addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    //MARK: - @objc Action , Action
    @objc func didTapComment(){
        delegate?.inputView(self, loadComment: commentTextView.text)
    }
    // 업로드가 완료되면 textView에 text를 지워주고
    // text가 입력되면서 숨겨져있던 placeholderlabel을 다시 뷰에 보이게 만들어주는 method
    func allClearComment(){
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
}


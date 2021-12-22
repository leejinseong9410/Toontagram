//
//  CartoonMIDCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import SnapKit
import UIKit

protocol CartoonMIDCellDelegate : AnyObject {
    // 원하는 만화의 CommentVC로 이동 , 보여줄 프로토콜
    func cell(_ cell : CartoonMIDCell,showComments cartoon: Cartoon)
    // 좋아요 프로토콜 함수
    func cell(_ cell : CartoonMIDCell ,didLike cartoon : Cartoon )
    
    func cell(_ cell : CartoonMIDCell ,showProfile uid : String )
}

class CartoonMIDCell : UICollectionReusableView {
    
    static let idenfitier = "CartoonMIDCell"
    
    weak var delegate : CartoonMIDCellDelegate?
    
    var viewModel : CartoonViewModel? {
        didSet { configureData() }
    }
    
    lazy var captionLabel : UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    lazy var likeButton : UIButton = {
       let button = UIButton()
       button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
      button.tintColor = .label
       return button
   }()
   private lazy var commentsButton : UIButton = {
       let button = UIButton()
       button.setImage(UIImage(systemName: "message"), for: .normal)
       button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
       button.tintColor = .label
       return button
   }()
   private lazy var sharedButton : UIButton = {
      let button = UIButton()
       button.setImage(UIImage(systemName: "paperplane"), for: .normal)
       button.tintColor = .label
       return button
   }()
   private let likeLabel : UILabel = {
      let label = UILabel()
       label.font = .systemFont(ofSize: 12, weight: .bold)
       label.textColor = .label
       return label
   }()
   private let dateLabel : UILabel = {
      let label = UILabel()
       label.font = .systemFont(ofSize: 12, weight: .bold)
       label.textAlignment = .right
       label.textColor = .label
       return label
   }()
   private var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configure(){
        addSubview(captionLabel)
        captionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.equalToSuperview()
            make.height.equalTo(20)
        }
        configureButtons()
        
        addSubview(likeLabel)
        likeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(5)
            make.leading.equalTo(self.snp.leading).offset(10)
            make.width.equalTo(120)
            make.height.equalTo(20)
        }
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(120)
            make.height.equalTo(20)
        }
        let topInsetView = UIView()
        topInsetView.backgroundColor = .label
        addSubview(topInsetView)
        topInsetView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
        let bottomInsetView = UIView()
        bottomInsetView.backgroundColor = .label
        addSubview(bottomInsetView)
        bottomInsetView.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    
    //MARK: - button configure && @objc
    func configureButtons(){
        stackView = UIStackView(arrangedSubviews: [likeButton,commentsButton,sharedButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints {(make) in
            make.top.equalTo(captionLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.snp.leading).offset(10)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        let stackTopInsetView = UIView()
        stackTopInsetView.backgroundColor = .label
        addSubview(stackTopInsetView)
        stackTopInsetView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.top)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
        let stackBottomInsetView = UIView()
        stackBottomInsetView.backgroundColor = .label
        addSubview(stackBottomInsetView)
        stackBottomInsetView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    func configureData(){
        guard let viewModel = viewModel else { return }
        captionLabel.text = "\(viewModel.username): \(viewModel.caption)"
        likeLabel.text = "\(viewModel.likes) 좋아요"
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        dateLabel.text = viewModel.timeString
    }
    //MARK: - @objc Method
    @objc func didTapLike(){
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, didLike: viewModel.cartoon)
    }
    @objc func didTapComment(){
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, showComments: viewModel.cartoon)
    }
}

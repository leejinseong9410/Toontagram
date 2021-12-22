//
//  CommentCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit
import SnapKit

class CommentCell: UICollectionViewCell {
    //MARK: - Properties
    static let identifier = "CommentCell"
    
    var viewModel : CommentViewModel? {
        didSet { configure() }
    }
    private let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondaryLabel
        return imageView
    }()
    private let userComment = UILabel()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userComment.numberOfLines = 0
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        profileImageView.layer.cornerRadius = 40 / 2
        addSubview(userComment)
        
        userComment.snp.makeConstraints { (make) in
            // height,width 는 따로 layout을 걸어주기 X
            // 댓글 길이에 따라서 height가 바뀜 (viewModel - func size(with width : CGFloat ) -> CGSize)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configure(){
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        userComment.attributedText = viewModel.commentLabelSetup()
    }
}


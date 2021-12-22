//
//  UserCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SnapKit
import SDWebImage

class UserCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "UserCell"
    
    var viewModel : UserCellViewModel? {
        didSet {
            configure()
        }
    }
    private let searchUserProfileImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    private let searchUserPenname : UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .label
        return label
    }()
    private let searchUserName : UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .secondarySystemBackground
        addSubview(searchUserProfileImageView)
        searchUserProfileImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        searchUserProfileImageView.layer.cornerRadius = 48 / 2
        let stackView = UIStackView(arrangedSubviews: [searchUserPenname,searchUserName])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(searchUserProfileImageView.snp.trailing).offset(8)
            make.width.equalTo(100)
            make.height.equalTo(searchUserProfileImageView.snp.height).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configure(){
        //CollectionView 에서 viewModel 값전달 되면 실행되는 함수
        guard let viewModel = viewModel else { return }
        searchUserProfileImageView.sd_setImage(with: viewModel.profileImageURL)
        searchUserName.text = viewModel.userName
        searchUserPenname.text = viewModel.userPenname
    }
}

//
//  ProfileHeader.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SnapKit
import SDWebImage

protocol ProfileHeaderDelegate : AnyObject {
    func header(_ header : ProfileHeader,didTapButton user : User )
}
class ProfileHeader: UICollectionReusableView {
    //MARK: - identifier
    static let identifier = "ProfileHeader"
    //MARK: - Properties
    var viewModel : ProfileHeaderViewModel? {
        didSet { configureHeader() }
    }
    weak var delegate : ProfileHeaderDelegate?
    
    private let profileImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 120 / 2
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private let profileNameLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    private let profileIntroduction : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    private lazy var editButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.borderColor = UIColor.label.cgColor
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileBackgroundView : UIImageView = {
        // 제스처 추가해야됨
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    // attStartText 함수 돌기전에 정의되서 lazy var 로 선언
    private lazy var cartoonLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var fanLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var starLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        addSubview(profileBackgroundView)
        profileBackgroundView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-40)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
            make.height.equalTo(120)
        }
        addSubview(profileNameLabel)
        profileNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        let stackView = UIStackView(arrangedSubviews: [fanLabel,starLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(profileNameLabel.snp.bottom).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        addSubview(cartoonLabel)
        cartoonLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.leading.equalTo(stackView.snp.leading)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        addSubview(editButton)
        editButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(cartoonLabel.snp.centerY)
            make.leading.equalTo(cartoonLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        addSubview(profileIntroduction)
        profileIntroduction.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.width.equalTo(130)
            make.height.equalTo(20)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader(){
        // viewModel 언랩핑 위에서 풀어도 되는데 여기서 푸는게 오류가 나지 않는다
        guard let viewModel = viewModel else { return }
        profileNameLabel.text = viewModel.penname
        // 프로필 이미지는 URL 로 넘어온다
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        profileBackgroundView.sd_setImage(with: viewModel.backgrounImage)
        editButton.setTitle(viewModel.fanButtonValue, for: .normal)
        editButton.backgroundColor = viewModel.buttonBackgroundColor
        cartoonLabel.attributedText = viewModel.valueOfCartoon
        fanLabel.attributedText = viewModel.valueOfFans
        starLabel.attributedText = viewModel.valueOfStar
        profileIntroduction.attributedText = viewModel.introduction
    }
    
    //MARK: - @objc Method
    @objc private func editProfile(){
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapButton: viewModel.user)
    }
}


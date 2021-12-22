//
//  FeedBackCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SnapKit
import SDWebImage

protocol FeedBackCellDelegate : AnyObject {
    func cell(_ cell : FeedBackCell , fan uid:String)
    func cell(_ cell :FeedBackCell, unFan uid :String)
    func cell(_ cell : FeedBackCell , viewCartoon cartoonId : String)
}

class FeedBackCell : UITableViewCell {
    //MARK: - Properties
    static let identifier = "FeedBackCell"
    
    weak var delegate : FeedBackCellDelegate?
    
    var viewModel : FeedBackViewModel? {
        didSet { configure() }
    }
    private let feedbackProfileImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .red
        return imageView
    }()
    private let feedbackUserPenname : UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    private let feedbackUserName : UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var feedbackCartoonImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    private let feedbackFanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.layer.borderColor = UIColor.label.cgColor
        button.addTarget(self, action: #selector(didTapFan), for: .touchUpInside)
        return button
    }()
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(feedbackProfileImageView)
        feedbackProfileImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        feedbackProfileImageView.layer.cornerRadius = 48 / 2
        contentView.addSubview(feedbackFanButton)
        feedbackFanButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
        contentView.addSubview(feedbackCartoonImageView)
        feedbackCartoonImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        contentView.addSubview(feedbackUserPenname)
        feedbackUserPenname.snp.makeConstraints { (make) in
            make.centerY.equalTo(feedbackProfileImageView.snp.centerY)
            make.left.equalTo(feedbackProfileImageView.snp.right).offset(8)
            make.right.equalTo(feedbackFanButton.snp.left).offset(-8)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configure(){
        guard let viewModel = viewModel else {
            return
        }
        feedbackProfileImageView.sd_setImage(with: viewModel.profileImageUrl)
        feedbackCartoonImageView.sd_setImage(with: viewModel.cartoonsImageUrl)
        feedbackUserPenname.attributedText = viewModel.feedbackMessage
        feedbackFanButton.isHidden = !viewModel.hideCartoonImage
        feedbackCartoonImageView.isHidden = viewModel.hideCartoonImage
        feedbackFanButton.setTitle(viewModel.fanButtonText, for: .normal)
        feedbackFanButton.setTitleColor(viewModel.fanButtonTextColor, for: .normal)
        feedbackFanButton.backgroundColor = viewModel.fanButtonBackgroundColor
    }
    
    //MARK: - @objc Action
    @objc func didTapFan(){
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.feedback.userFan {
            delegate?.cell(self, unFan: viewModel.feedback.uid)
        }else{
            delegate?.cell(self, fan: viewModel.feedback.uid)
        }
    }
    @objc func didTapImageView(){
        guard let cartoonID = viewModel?.feedback.cartoonID else { return }
        delegate?.cell(self, viewCartoon: cartoonID)
    }
}

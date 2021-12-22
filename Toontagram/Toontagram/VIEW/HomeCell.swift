//
//  HomeCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/17.
//

import UIKit
import SDWebImage
import SnapKit

class HomeCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "HomeCell"
    
    var viewModel : CartoonViewModel? {
        didSet { configureData() }
    }
    
    private let imageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .lightGray
        iv.backgroundColor = .darkGray
        return iv
    }()
    private let label : UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.textColor = .label
        return lb
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(130)
        }
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configureData(){
        guard let viewModel = viewModel else { return }
        imageView.sd_setImage(with: viewModel.thumbnail)
        let txt = NSMutableAttributedString(string: "\(viewModel.title)\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.black])
        txt.append(NSAttributedString(string:viewModel.username, attributes: [.font:UIFont.systemFont(ofSize: 12, weight: .bold),.foregroundColor : UIColor.lightGray]))
        label.attributedText = txt
    }
}

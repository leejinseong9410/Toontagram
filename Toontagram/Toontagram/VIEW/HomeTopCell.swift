//
//  HomeTopCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/21.
//

import UIKit
import SnapKit
import SDWebImage

class HomeTopCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "HomeTopCell"
    
    var viewModel : CartoonViewModel? {
        didSet { configureData() }
    }
    
    private let imageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    private let lb : UILabel = {
       let lb = UILabel()
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.backgroundColor = .black.withAlphaComponent(0.6)
        return lb
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        addSubview(lb)
        lb.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Configure
    func configureData(){
        guard let viewModel = viewModel else { return }
        imageView.sd_setImage(with: viewModel.thumbnail)
        let txt = NSMutableAttributedString(string: "\(viewModel.title)\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 24),.foregroundColor : UIColor.white])
        txt.append(NSAttributedString(string:viewModel.caption, attributes: [.font:UIFont.systemFont(ofSize: 16, weight: .bold),.foregroundColor : UIColor.lightGray]))
        lb.attributedText = txt
    }
}


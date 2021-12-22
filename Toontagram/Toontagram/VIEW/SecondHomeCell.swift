//
//  SecondHomeCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/18.
//


import UIKit
import SnapKit
import SDWebImage

class SecondHomeCell : UICollectionViewCell {
    static let identifier = "SecondHomeCell"
    
    var viewModel : CartoonViewModel? {
        didSet { configureData() }
    }
    
    private let recomImageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(recomImageView)
        recomImageView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func configureData() {
       guard let viewModel = viewModel else { return }
       recomImageView.sd_setImage(with: viewModel.thumbnail)
    }
    
}

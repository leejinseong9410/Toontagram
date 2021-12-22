//
//  CartoonCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import SnapKit
import SDWebImage
import UIKit

class CartoonCell : UICollectionViewCell {
    static let identifier = "CartoonCell"
    
    private let cartoonIV : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    var imageURL : URL? {
        didSet { configureData() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(cartoonIV)
        cartoonIV.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureData(){
        cartoonIV.sd_setImage(with: imageURL)
    }
}

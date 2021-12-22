//
//  UploadCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/17.
//

import UIKit
import SnapKit

class UploadCell : UICollectionViewCell {
    static let identifier = "UploadCell"
    
    private let imageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
 
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Configure
    func configure(image:UIImage){
        imageView.image = image
    }
}

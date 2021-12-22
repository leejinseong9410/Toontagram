//
//  SetUpCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SnapKit

class SetUpCell : UICollectionViewCell {
    static let identifier = "SetUpCell"
    
    private let imageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let label : UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 14,weight:.bold)
        lb.textAlignment = .center
        lb.textColor = .label
        return lb
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Configure
    func configure(text:String,image:UIImage){
        imageView.image = image
        label.text = text
    }
}

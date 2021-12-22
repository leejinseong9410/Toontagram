//
//  ProfileCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import SDWebImage

class ProfileCell: UICollectionViewCell {
    //MARK: - identifier
    static let identifier = "ProfileCell"
    //MARK: - Properties
    var viewModel : CartoonViewModel? {
        didSet { configure() }
    }
    private let cartoonImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "background")
        imageView.clipsToBounds = true
        return imageView
    }()
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cartoonImageView)
        cartoonImageView.fillSuperview()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let viewModel = viewModel else { return }
        cartoonImageView.sd_setImage(with: viewModel.thumbnail)
    }
}

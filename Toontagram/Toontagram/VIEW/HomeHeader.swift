//
//  HomeHeader.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/17.
//

import UIKit
import SnapKit

protocol HomeHeaderDelegate : AnyObject {
    func didLoveTab(_ category : String )
    func didActionTab(_ category : String )
    func didDailyTab(_ category : String )
    func didAllTab(_ category : String)
}
class HomeHeader : UICollectionReusableView {
    
    static let identifier = "HomeHeader"
    
    private let allBt : UIButton = {
       let bt = UIButton()
        bt.setTitle("ALL", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        bt.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        return bt
    }()
    private let loveBt : UIButton = {
       let bt = UIButton()
        bt.setTitle("LOVE", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        bt.addTarget(self, action: #selector(didTapLove), for: .touchUpInside)
        return bt
    }()
    private let actionBt : UIButton = {
       let bt = UIButton()
        bt.setTitle("ACTION", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        bt.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        return bt
    }()
    private let dailyBt : UIButton = {
       let bt = UIButton()
        bt.setTitle("DAILY", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        bt.addTarget(self, action: #selector(didTapDaily), for: .touchUpInside)
        return bt
    }()
    weak var delegate : HomeHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .brown
        let stackView = UIStackView(arrangedSubviews: [allBt,loveBt,actionBt,dailyBt])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapLove(){

        delegate?.didLoveTab("LOVE")
    }
    @objc func didTapAction(){

        delegate?.didActionTab("ACTION")
    }
    @objc func didTapDaily(){

        delegate?.didDailyTab("DAILY")
    }
    @objc func didTapAll(){
        delegate?.didAllTab("ALL")
    }
}

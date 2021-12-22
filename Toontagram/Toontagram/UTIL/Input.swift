//
//  Input.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit
import SnapKit

class InputTextView : UITextView {
    
    var placeholderText : String? {
        didSet { placeholderLabel.text = placeholderText }
    }
    
     let placeholderLabel : UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    var placeholderCenter = true {
        didSet {
            // textView에 들어가는 placeholder의 layout은 placeholderCenter if로 두개를 나눠야한다.
            // 이유: upload , input이랑 서로 탑과 바텀의 위치가 달라서
            // 그때 그때 따로 변경하면 되긴 하지만 bool 값 변수 를 만들어서 그때그때 bool값만 넣어주면 center가 잘잡힌다..
            // VC에 코드가 몇줄 더 짧아지고 헷갈리지 않는것 같다
            if placeholderCenter {
                placeholderLabel.anchor(left:leftAnchor,right: rightAnchor,paddingLeft: 8)
                placeholderLabel.centerY(inView: self)
            }else{
                placeholderLabel.anchor(top:topAnchor,left: leftAnchor,paddingTop: 6,paddingLeft: 8)
            }
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addSubview(placeholderLabel)
        NotificationCenter.default.addObserver(self, selector: #selector(didTextChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - NotificationCenter Aciton (텍스트뷰 인풋 값이 들어오면 반응)
    @objc private func didTextChanged(){
        //Text의 비어있음을 가지고 placeholderLabel 의 isHidden 을 변경
        //TextVIew text가 들어오면 placeholderLabel는 보이지않는다
        placeholderLabel.isHidden = !text.isEmpty
    }
}

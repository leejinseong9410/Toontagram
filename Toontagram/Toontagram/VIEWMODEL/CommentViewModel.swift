//
//  CommentViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import UIKit

struct CommentViewModel {
    private let comment:Comment
    
    var profileImageUrl : URL? {
        return URL(string:comment.userProfileImageUrl)
    }
    init(comment:Comment) {
        self.comment = comment
    }
    // 댓글의 텍스트를 설정할 함수
    func commentLabelSetup() -> NSAttributedString {
        let attStr = NSMutableAttributedString(string: "\(comment.userProfilePenname)",attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
        attStr.append(NSAttributedString(string: "\t\(comment.comment)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]))
        return attStr
    }
    // 댓글에 길이에 맞게 label을 사이즈를 수정해야 한다
    func size(with width : CGFloat ) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.comment
        //브레이크모드를 byWordWrapping으로 주게되면 width값의 초과 할 길이 일시 줄바꿈을 알아서 해준다.
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        //return 을 systemLayoutSizeFitting + layoutFittingCompressedSize 으로 압축해서 보내줘야 크러쉬가 나지않음
        // layoutFittingExpandedSize 으로 시도 해봤지만 text가 어느정도의 길이를 벗어나면 짤려서 보여짐..
        // smallSize로 압축해서 리턴해야 된다
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}


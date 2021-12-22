//
//  FeedBackViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
struct FeedBackViewModel {
    
    var feedback : FeedBack
    
    init(feedback : FeedBack) {
        self.feedback = feedback
    }
    var cartoonsImageUrl : URL? { return URL(string: feedback.thumbnailImage ?? "" )}
    var profileImageUrl : URL? { return URL(string: feedback.userProfileImageUrl ) }

    var feedbackMessage : NSAttributedString {
        let name = feedback.userName
        let message = feedback.type.message
        let att = NSMutableAttributedString(string: name, attributes: [.font:UIFont.boldSystemFont(ofSize: 14)])
        att.append(NSAttributedString(string: message, attributes: [.font:UIFont.systemFont(ofSize: 12, weight: .regular)]))
        att.append(NSAttributedString(string: "\(feedback.time.dateValue())", attributes: [.font:UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor : UIColor.lightGray]))
        return att
    }
    var hideCartoonImage : Bool {
        return self.feedback.type == .fan
    }
    var fanButtonText : String {
        return feedback.userFan ? "Subscribed" : "UnSubscribed"
    }
    var fanButtonBackgroundColor : UIColor {
        return feedback.userFan ? .white : .blue
    }
    var fanButtonTextColor : UIColor {
        return feedback.userFan ? .black : .white
    }
}

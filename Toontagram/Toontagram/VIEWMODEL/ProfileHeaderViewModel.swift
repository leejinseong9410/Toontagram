//
//  ProfileHeaderViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//
import UIKit
struct ProfileHeaderViewModel {
    let user : User
    
    var penname : String {
        return user.penname
    }
    var profileImageUrl : URL? {
        // return 은 URL로 주면 코드 한줄 줄어든다!!
        return URL(string: user.profileImageUrl)
    }
    var backgrounImage : URL? {
        return URL(string: user.backgroundImageUrl)
    }
    var introduction : NSAttributedString {
        let introductionStr = NSMutableAttributedString(string: user.introduction, attributes: [.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.black])
        return introductionStr
    }
    var fanButtonValue : String {
        if user.currentUser {
            return "프로필 편집"
        }
        return user.fan ? "Subscribed" : "UnSubscribed"
    }
    var buttonBackgroundColor : UIColor {
        return user.currentUser ? .secondarySystemBackground : .lightGray
    }
    var valueOfFans : NSAttributedString {
        return attStartText(value: user.stats.fanVaue, label: "Subscribed")
    }
    var valueOfStar : NSAttributedString {
        return attStartText(value: user.stats.starValue, label: "Subscribing")
    }
    var valueOfCartoon : NSAttributedString {
        return attStartText(value: user.stats.cartoons, label: "Cartoon")
    }
    init(user:User) {
        self.user = user
    }
    //MARK: fan,star,cartoon Label Setup
    func attStartText(value:Int,label:String) -> NSAttributedString {
        let str = NSMutableAttributedString(string: "\(value)\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.black ])
        str.append(NSAttributedString(string:label, attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .bold),.foregroundColor : UIColor.black]))
        return str
    }
}


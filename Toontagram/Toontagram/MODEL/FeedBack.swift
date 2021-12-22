//
//  FeedBack.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import Firebase
enum FeedBackType : Int {
    case like
    case fan
    case comment
    
    var message : String {
        switch self {
        case .like : return "좋아요를 보냈어요!"
        case .comment: return "댓글이 달렸어요!"
        case .fan: return "팬이 생겼어요!"
        }
    }
}
struct FeedBack {
    let uid : String
    let cartoonID : String?
    let thumbnailImage : String?
    let time : Timestamp
    let type : FeedBackType
    let id : String
    let userProfileImageUrl : String
    let userName : String
    var userFan = false
    
    init(dictinary: [String:Any] ) {
        self.time = dictinary["time"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictinary["id"] as? String ?? ""
        self.uid = dictinary["uid"] as? String ?? ""
        self.cartoonID = dictinary["cartoonID"] as? String ?? ""
        self.thumbnailImage = dictinary["thumbnailImage"] as? String ?? ""
        self.type = FeedBackType(rawValue: dictinary["type"] as? Int ?? 0) ?? .like
        self.userProfileImageUrl = dictinary["userProfileImageUrl"] as? String ?? ""
        self.userName = dictinary["userName"] as? String ?? ""
    }
}

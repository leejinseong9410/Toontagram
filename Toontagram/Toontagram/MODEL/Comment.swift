//
//  Comment.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import Firebase

struct Comment {
    let uid : String
    let userProfilePenname : String
    let userProfileImageUrl : String
    let time : Timestamp
    let comment : String

    init(dictionary : [String:Any] ) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.userProfilePenname = dictionary["userProfilePenname"] as? String ?? ""
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.time = dictionary["time"] as? Timestamp ?? Timestamp(date: Date())
        self.comment = dictionary["comment"] as? String ?? ""
    }
}

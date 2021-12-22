//
//  Cartoon.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/15.
//

import UIKit
import Firebase
struct Section : Hashable {
    let items : [Cartoon]
    let type : String
    let id: Int
    let title: String
    let subtitle: String
}
struct HeaderCartoon {
    let caption : String
    let image : String
    let cartoonId : String
    
    init(cartoonId : String , image : String , caption : String ) {
        self.cartoonId = cartoonId
        self.image = image
        self.caption = caption
    }
}
struct Cartoon : Hashable {
    var title : String
    let username: String
    var thumbnailImage : String
    var page1 : String
    var page2 : String
    var page3 : String
    var page4 : String
    var like : Int
    var uid : String
    var time : Timestamp
    let cartoonId : String
    var type : String
    var caption : String
    var userProfileImageUrl : String
    var didLike = false
    
    // 지금 login한 user의 uid와 fetch로 가져온 uid 가 같으면 현재 사용자 이기 때문에
    // search -> ProfileVC 입장시 Header에 editButton Title을 수정해야됨
    //
    var currentUser : Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(cartoonId:String , dictionary : [String:Any] ) {
        self.title = dictionary["title"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.thumbnailImage = dictionary["thumbnailImage"] as? String ?? ""
        self.page1 = dictionary["page1"] as? String ?? ""
        self.page2 = dictionary["page2"] as? String ?? ""
        self.page3 = dictionary["page3"] as? String ?? ""
        self.page4 = dictionary["page4"] as? String ?? ""
        self.like = dictionary["like"] as? Int ?? 0
        self.uid = dictionary["uid"] as? String ?? ""
        self.time = dictionary["time"] as? Timestamp ?? Timestamp(date: Date())
        self.cartoonId = cartoonId
        self.type = dictionary["type"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
       }
}

//
//  User.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/14.
//
import Firebase

// Firebase Data UserService 에서 fetch 해주자
/*
 email
 name
 penname
 profileImageUrl
 uid
 */
struct User{
    
    let email : String
    let penname : String
    let name : String
    let profileImageUrl : String
    let backgroundImageUrl : String
    let introduction : String
    let uid : String
    var fan = false
    var stats : UserStats!
    
    // 지금 login한 user의 uid와 fetch로 가져온 uid 가 같으면 현재 사용자 이기 때문에
    // search -> ProfileVC 입장시 Header에 editButton Title을 수정해야됨
    //
    var currentUser : Bool { return Auth.auth().currentUser?.uid == uid }
    
    
    //Data 가져올때마다 옵셔널 언랩핑 하기 귀찮아서 만든 init
    init(dictionary: [String:Any] ) {
        self.email = dictionary["email"] as? String ?? ""
        self.penname = dictionary["penname"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.stats = UserStats(fanVaue: 0, starValue: 0,cartoons: 0)
        self.backgroundImageUrl = dictionary["profileBackImageUrl"] as? String ?? ""
        self.introduction = dictionary["introduction"] as? String ?? ""
    }
}
struct UserStats {
    let fanVaue : Int
    let starValue : Int
    let cartoons : Int
}

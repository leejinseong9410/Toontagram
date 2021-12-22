//
//  UserService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/14.
//

import Firebase
typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    //MARK: - User data Fetch
    //User Model  형으로 반환 해줌
    static func fetchUser(with uid :String ,completion:@escaping (User) -> Void){
        COLLECTION_USER.document(uid).getDocument { snapshot, error in
            guard let dictinary = snapshot?.data() else { return }
            print("DEBUG = User Snapshot \(dictinary)😀")
            let user = User(dictionary: dictinary)
            completion(user)
        }
    }
    //MARK: - Users data Fetch
    static func fetchUsers(completion:@escaping ([User]) -> Void) {
        COLLECTION_USER.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            let users = snapshot.documents.map( { User(dictionary: $0.data())} )
            completion(users)
        }
    }
    static func fanUsers(uid:String , completion : @escaping(FirestoreCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_STAR.document(currentUid).collection("user_star").document(uid).setData([:]) { error in
            COLLECTION_FANS.document(uid).collection("user_fan").document(currentUid).setData([:],completion: completion)
        }
    }
    static func antiFanUser(uid:String , completion : @escaping(FirestoreCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_STAR.document(currentUid).collection("user_star").document(uid).delete { error in
            COLLECTION_FANS.document(uid).collection("user_fan").document(currentUid).delete(completion: completion)
        }
    }
    static func checkUserFans(uid:String,completion:@escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_STAR.document(currentUid).collection("user_star").document(uid).getDocument { (snapshot,error) in
            guard let fans = snapshot?.exists else { return }
            completion(fans)
        }
    }
    static func fetchUserStats(uid:String,completion:@escaping (UserStats) -> Void) {
        COLLECTION_FANS.document(uid).collection("user_fan").getDocuments { (snapshot, _) in
            let fans = snapshot?.documents.count ?? 0
            COLLECTION_STAR.document(uid).collection("user_star").getDocuments { (snapshot, _) in
                let stars = snapshot?.documents.count ?? 0
                
                COLLECTION_CARTOON.whereField("uid", isEqualTo: uid).getDocuments { (snapshot, _) in
                    let cartoonsCount = snapshot?.documents.count ?? 0
                    completion(UserStats(fanVaue: fans, starValue: stars,cartoons: cartoonsCount))
                }
            }
        }
    }
    static func editUserData(user:User,profile:UIImage,backImage:UIImage,intro:String , completion : @escaping (Bool) -> Void){
        ImageService.editUserProfileImage(profileImage: profile, profileBackImage: backImage) { str in
            COLLECTION_USER.document(user.uid).updateData(["profileImageUrl":str[0],
                                                           "profileBackImageUrl" : str[1],
                                                           "introduction" :intro
                                                          ])
            completion(true)
        }
    }
}

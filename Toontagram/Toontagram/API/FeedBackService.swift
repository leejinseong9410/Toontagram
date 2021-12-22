//
//  FeedBackService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//
import Firebase

struct FeedBackService {
    static func uploadFeedBack(toUid uid : String ,type : FeedBackType , cartoon : Cartoon? = nil , user : User){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        let ref = COLLECTION_FEEDBACK.document(uid).collection("user-feedback").document()
        var data : [String:Any] = ["time":Timestamp(date: Date()),"uid":user.uid,"type":type.rawValue,"id":ref.documentID,"userProfileImageUrl" : user.profileImageUrl,"userName" : user.penname]
        if let cartoon = cartoon {
            data["cartoonID"] = cartoon.cartoonId
            data["thumbnailImage"] = cartoon.thumbnailImage
        }
        ref.setData(data)
    }
    static func fetchFeedBack(completion:@escaping ([FeedBack]) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_FEEDBACK.document(uid).collection("user-feedback").order(by: "time", descending: true)
        query.getDocuments { (snapshot, _) in
            guard let doc = snapshot?.documents else { return }
            let feedbacks = doc.map({ FeedBack(dictinary: $0.data() )})
            completion(feedbacks)
        }
    }
}

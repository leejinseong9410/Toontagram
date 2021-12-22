//
//  CommentService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/19.
//

import Firebase

struct CommentService {
    static func uploadComment(comment:String,cartoonID:String,user:User,completion:@escaping (FirestoreCompletion) ){
        let data : [String:Any] = ["uid":user.uid,"comment":comment,"time":Timestamp(date: Date()),"userProfilePenname": user.penname,"userProfileImageUrl": user.profileImageUrl]
        COLLECTION_CARTOON.document(cartoonID).collection("comments").addDocument(data: data,completion:completion)
    }
    static func fetchComment(forCartoon cartoonID:String,completion:@escaping ([Comment]) -> Void ){
        var comments = [Comment]()
        let query = COLLECTION_CARTOON.document(cartoonID).collection("comments").order(by: "time", descending: true)
        // firebase의 addSnapshotListener 을 사용
        // 이유: user 혹은 내가 댓글을 업로드 하였을때 수동으로 데이터를 reload하거나 로직을 구성하지 않아도 리스너를 달면 바로 UI업데이트가 된다
        query.addSnapshotListener { (snapshot,error) in
            snapshot?.documentChanges.forEach({ changed in
                if changed.type == .added {
                    let data = changed.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            completion(comments)
        }
    }
}

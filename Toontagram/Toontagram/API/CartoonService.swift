//
//  CartoonService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit
import Firebase

struct CartoonService {
    
    static func uploadCartoon(title:String,caption:String,image:[UIImage],user:User,type:String,completion:@escaping (FirestoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ImageService.imageUpload(page1: image[1], page2: image[2], page3: image[3], page4: image[4], thumb: image[0] ,title : title) { url in
            let data = ["title":title,
                        "time":Timestamp(date: Date()),
                        "like":0,
                        "uid":uid,
                        "thumbnailImage" : url[0],
                        "page1" : url[1],
                        "page2" : url[2],
                        "page3" : url[3],
                        "page4" : url[4],
                        "type" : type,
                        "username" : user.name,
                        "caption":caption,
                        "userProfileImageUrl" : user.profileImageUrl]
                as [String:Any]
            let ref = COLLECTION_CARTOON.addDocument(data: data,completion:completion)
            self.updateMainUserAfterCartoon(cartoonID: ref.documentID)
        }
    }
    
    static func fetchCartoons(completion:@escaping ([Cartoon]) -> Void){
        // order <- firebase filter중 하나
        // time 즉 Timestamp 값으로 가장 먼저 업로드 된 순서대로 가지고 온다.
        COLLECTION_CARTOON.order(by: "time", descending: true).getDocuments { (snapshot,error) in
            guard let documents = snapshot?.documents else { return }
            let cartoons = documents.map({ Cartoon(cartoonId: $0.documentID, dictionary: $0.data())})
            completion(cartoons)
        }
    }
    
    //time으로 필터된 uid필드가 currentUser의 uid와 동일한
    //만화들만 가지고온다.
    static func fetchCartoons(id uid:String,completion:@escaping  ([Cartoon]) -> Void ) {
        let order = COLLECTION_CARTOON.whereField("uid", isEqualTo: uid)
        order.getDocuments { (snapshot,error) in
            guard let documents = snapshot?.documents else { return }
            var cartoons = documents.map({ Cartoon(cartoonId: $0.documentID, dictionary: $0.data())})
            cartoons.sort(by: { $0.time.seconds > $1.time.seconds})
            completion(cartoons)
        }
    }
    static func fetchCartoon(withCartoonID cartoonID:String,completion:@escaping (Cartoon) -> Void) {
        COLLECTION_CARTOON.document(cartoonID).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return}
            guard let data = snapshot.data() else { return }
            let cartoonData = Cartoon(cartoonId: snapshot.documentID, dictionary: data)
            completion(cartoonData)
        }
    }
    
    
    /*
     like unLike 는 먼저 데이터베이스에 좋아요의 선택과 해제를 하고자 하는 cartoon에 like의 값을 먼저 변경해야 에러가 나지않는다.
     아니면 에러가남.. 왜나는지 아직은 잘 모르겠다..
     그이후에 그 만화 안에 또다른 컬렉션을 만들고 currentUser의 uid를 넣으면 된다
     그리고 좋아요를 누른 사람의 데이터베이스에도 좋아요한 만화의id를 저장하면 된다. unLike는 반대로 하면되는줄 알았지만
     user 좋아요 value를 fetch 하지 않은 상태라 unLike가 실행이 되지 않았다
     그래서 MainVC 31번 라인에서 checkUserLikeCartoon() 을 한번 실행시켜 like의 값을 받아오니 실행 성공
     */
    static func likeCartoon(cartoon:Cartoon,completion:@escaping (FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_CARTOON.document(cartoon.cartoonId).updateData(["like":cartoon.like + 1])
        
        COLLECTION_CARTOON.document(cartoon.cartoonId).collection("cartoon-likes").document(uid).setData([:]) { _ in
            COLLECTION_USER.document(uid).collection("user-likes").document(cartoon.cartoonId).setData([:], completion: completion)
        }
    }
    static func unLikeCartoon(cartoon:Cartoon,completion:@escaping (FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard cartoon.like > 0 else { return }
        COLLECTION_CARTOON.document(cartoon.cartoonId).updateData(["like":cartoon.like - 1])
        COLLECTION_CARTOON.document(cartoon.cartoonId).collection("cartoon-likes").document(uid).delete { _ in
            COLLECTION_USER.document(uid).collection("user-likes").document(cartoon.cartoonId).delete(completion: completion)
        }
    }
    static func checkUserLikeCartoon(cartoon:Cartoon,completion:@escaping (Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USER.document(uid).collection("user-likes").document(cartoon.cartoonId).getDocument { (snapshot,error) in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    static func fetchCartoonFeed(completion:@escaping ([Cartoon]) -> Void ){
        var cartoons = [Cartoon]()
        // 자신이 올린 글만 보게하는 로직 (1)
//        COLLECTION_USER.document(uid).collection("user-feed").getDocuments { snapshot,error in
//            snapshot?.documents.forEach({ document in
//                fetchCartoon(withCartoonID: document.documentID) { cartoon in
//                    if cartoons.contains(cartoon) == false {
//                        cartoons.append(cartoon)
//                        cartoons.sort(by: { $0.time.seconds > $1.time.seconds})
//                    }
//                    completion(cartoons)
//                }
//            })
//        }
        // 데이터베이스에 있는 모든 만화를 받아오는 로직
        // 이 로직 사용시 firebaseStorage 데이터 소모량이 많아서 테스트 중에는 1번 로직으로 사용했다.
        COLLECTION_CARTOON.getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                fetchCartoon(withCartoonID: document.documentID) { cartoon in
                    if cartoons.contains(cartoon) == false {
                        cartoons.append(cartoon)
                        cartoons.sort(by: { $0.time.seconds > $1.time.seconds})
                    }
                    completion(cartoons)
                }
            })
        }
    }
    static func updateMainUserAfterFan(user:User,didFan : Bool ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
         let order = COLLECTION_CARTOON.whereField("uid", isEqualTo: user.uid)
         order.getDocuments { (snapshot, error) in
             guard let documents = snapshot?.documents else { return }
             let docID = documents.map{( $0.documentID)}
             docID.forEach { doc in
                 if didFan {
                     COLLECTION_USER.document(uid).collection("user-feed").document(doc).setData([:])
                 }else{
                     COLLECTION_USER.document(uid).collection("user-feed").document(doc).delete()
                 }
                 
             }
         }
    }
    static func updateMainUserAfterCartoon(cartoonID:String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FANS.document(uid).collection("user_fan").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            docs.forEach { doc in
                COLLECTION_USER.document(doc.documentID).collection("user-feed").document(cartoonID).setData([:])
            }
            COLLECTION_USER.document(uid).collection("user-feed").document(cartoonID).setData([:])
        }
    }
    static func editCartoon(type:String,cartoonId:String,title:String,caption:String,completion:@escaping (Cartoon) -> Void){
        COLLECTION_CARTOON.document(cartoonId).updateData(["title":title,"type":type,"caption":caption])
        self.fetchCartoon(withCartoonID: cartoonId) { cartoon in
            completion(cartoon)
        }
    }
    static func deleteCartoon(cartoon:Cartoon,completion:@escaping (Bool) -> Void) {
        COLLECTION_CARTOON.document(cartoon.cartoonId).delete { error in
            if error == nil {
                completion(true)
                print("데이터베이스 성공")
            }else{
                print("데이터베이스 실패")
                return
            }
        }
    }
}

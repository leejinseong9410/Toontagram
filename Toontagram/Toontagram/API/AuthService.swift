//
//  AuthService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/14.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email:String
    let password:String
    let name:String
    let penname:String
    let profileImage:UIImage
    let profileBackgroundImage : UIImage
    let introduction : String
}
struct AuthService {
    static func logInUser(with email:String , password : String ,completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    static func userRegister(with credentials : AuthCredentials , completion:@escaping (Error?) -> Void ) {
        ImageService.uploadimages(profileImage: credentials.profileImage, profileBackImage: credentials.profileBackgroundImage ,user:credentials.email) { images in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (results,error) in
                if error != nil {
                    print("DEBUG = createUser\(String(describing: error?.localizedDescription))")
                    return
                }else{
                    guard let uid = results?.user.uid else { return }
                    let data : [String : Any ] =
                    ["email":credentials.email,"name":credentials.name,"penname":credentials.penname,
                     "profileImageUrl":images[0],"profileBackImageUrl":images[1],"uid":uid,"introduction" : credentials.introduction]
                    COLLECTION_USER.document(uid).setData(data, completion: completion)
                }
            }
        }
    }
    static func resetPassword(with email: String ,completion: SendPasswordResetCallback? ) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}


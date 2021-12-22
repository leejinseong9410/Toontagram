//
//  ImageService.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/14.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation

struct ImageService {
    static func imageUpload(page1: UIImage,page2:UIImage,page3:UIImage,page4:UIImage,thumb:UIImage,title:String,completion:@escaping ([String]) -> Void) {
        guard let page1Data = page1.jpegData(compressionQuality: 0.8),
              let page2Data = page2.jpegData(compressionQuality: 0.8),
              let page3Data = page3.jpegData(compressionQuality: 0.8),
              let page4Data = page4.jpegData(compressionQuality: 0.8),
              let thumbData = thumb.jpegData(compressionQuality: 0.8)
        else{ return }
        let fileName = title
        let storageRef = Storage.storage().reference(withPath: "cartoon_images").child(fileName)
        let thumb = storageRef.child("thumbnail")
        let ref1 = storageRef.child("page1")
        let ref2 = storageRef.child("page2")
        let ref3 = storageRef.child("page3")
        let ref4 = storageRef.child("page4")
        thumb.putData(thumbData,metadata: nil) { metaData,error in
            if error != nil {
                print("DEBUG = upload\(String(describing: error?.localizedDescription))")
                return
            }else{
                ref1.putData(page1Data,metadata: nil) { ref1Meta , error in
                    if error != nil {
                        print("DEBUG = upload\(String(describing: error?.localizedDescription))")
                        return
                    }else{
                        ref2.putData(page2Data,metadata: nil) { ref2Meta , error in
                            if error != nil {
                                print("DEBUG = upload\(String(describing: error?.localizedDescription))")
                                return
                            }else{
                                ref3.putData(page3Data,metadata: nil) { ref3Meta , error in
                                    if error != nil {
                                        print("DEBUG = upload\(String(describing: error?.localizedDescription))")
                                        return
                                    }else{
                                        ref4.putData(page4Data,metadata: nil) { ref4Meta , error in
                                            var refs = [String]()
                                            thumb.downloadURL { (url,error) in
                                                ref1.downloadURL { (url1,error1) in
                                                    ref2.downloadURL { (url2,error2) in
                                                        ref3.downloadURL { (url3,error3) in
                                                            ref4.downloadURL { (url4,error4) in
                                                                guard let thumbStr = url?.absoluteString,
                                                                      let page1Str = url1?.absoluteString,
                                                                      let page2Str = url2?.absoluteString,
                                                                      let page3Str = url3?.absoluteString,
                                                                      let page4Str = url4?.absoluteString
                                                                else {return }
                                                                refs.append(thumbStr)
                                                                refs.append(page1Str)
                                                                refs.append(page2Str)
                                                                refs.append(page3Str)
                                                                refs.append(page4Str)
                                                                completion(refs)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    static func editUserProfileImage(profileImage:UIImage,profileBackImage:UIImage,completion:@escaping ([String]) -> Void ){
        guard let img = profileImage.jpegData(compressionQuality: 0.8),let image = profileBackImage.jpegData(compressionQuality: 0.8) else { return }
        let fileName = UUID().uuidString
        let ref1 = Storage.storage().reference(withPath: "profile_new_images").child(fileName).child("userProfileImage")
        let ref2 = Storage.storage().reference(withPath: "profile_new_images").child(fileName).child("userBackImage")
        DispatchQueue.main.async {
            ref1.putData(img, metadata: nil) { metaData, error in
                if error != nil {
                    print("DEBUG = upload - ref1 pudata \(String(describing: error?.localizedDescription))")
                    return
                }else{
                    ref2.putData(image, metadata: nil) { backMeta, err in
                        if err != nil {
                            print("DEBUG = upload - ref2 pudata  \(String(describing: err?.localizedDescription))")
                            return
                        }else{
                            var refs = [String]()
                            ref1.downloadURL { (url,error) in
                                ref2.downloadURL { (urls,errors) in
                                    guard let profileUrl = url?.absoluteString else { return }
                                    guard let backUrl = urls?.absoluteString else { return }
                                    refs.append(profileUrl)
                                    refs.append(backUrl)
                                    completion(refs)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    static func uploadimages(profileImage:UIImage,profileBackImage:UIImage,user:String,completion:@escaping ([String]) -> Void) {
        guard let imageData = profileImage.jpegData(compressionQuality: 0.8),
              let backImageData = profileBackImage.jpegData(compressionQuality: 0.8) else{ return }
        let fileName = UUID().uuidString
        let ref1 = Storage.storage().reference(withPath: "profile_images").child(fileName).child("userProfileImage")
        let ref2 = Storage.storage().reference(withPath: "profile_images").child(fileName).child("userBackImage")
        DispatchQueue.main.async {
            ref1.putData(imageData, metadata: nil) { metaData, error in
                if error != nil {
                    print("DEBUG = upload - ref1 pudata \(String(describing: error?.localizedDescription))")
                    return
                }else{
                    ref2.putData(backImageData, metadata: nil) { backMeta, err in
                        if err != nil {
                            print("DEBUG = upload - ref2 pudata  \(String(describing: err?.localizedDescription))")
                            return
                        }else{
                            var refs = [String]()
                            ref1.downloadURL { (url,error) in
                                ref2.downloadURL { (urls,errors) in
                                    guard let profileUrl = url?.absoluteString else { return }
                                    guard let backUrl = urls?.absoluteString else { return }
                                    refs.append(profileUrl)
                                    refs.append(backUrl)
                                    completion(refs)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

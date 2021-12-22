//
//  COLLECTION.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//
import FirebaseFirestore

// 자주 사용할꺼 같아 상수 선언
let COLLECTION_USER = Firestore.firestore().collection("users")
let COLLECTION_FANS = Firestore.firestore().collection("fans")
let COLLECTION_STAR = Firestore.firestore().collection("star")
let COLLECTION_CARTOON = Firestore.firestore().collection("cartoons")
let COLLECTION_FEEDBACK = Firestore.firestore().collection("feedback")

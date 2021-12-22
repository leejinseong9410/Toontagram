//
//  CartoonViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit

struct CartoonViewModel {
    
    var cartoon : Cartoon
    
    var title : String {
        return cartoon.title
    }
    
    var username: String {
        return cartoon.username
    }
    
    var thumbnail : URL? {
        return URL(string: cartoon.thumbnailImage)
    }
    
    var page1 : URL? {
        return URL(string: cartoon.page1)
    }
    
    var page2 : URL? {
        return URL(string: cartoon.page2)
    }
    
    var page3 : URL? {
        return URL(string: cartoon.page3)
    }
    
    var page4 : URL? {
        return URL(string: cartoon.page4)
    }
    var likes : Int {
        return cartoon.like
    }
    var caption : String {
        return cartoon.caption
    }
    var likeButtonTintColor : UIColor {
        return cartoon.didLike ? .red : .label
    }
    var likeButtonImage : UIImage? {
        let image = cartoon.didLike ? "heart.fill" : "hand.thumbsup"
        return UIImage(systemName: image)
    }
    var userProfileImageUrl : URL? {
        return URL(string: cartoon.userProfileImageUrl)
    }
    var timeString : String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day,.month,.year]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: cartoon.time.dateValue() , to: Date()) ?? ""
    }
    
    init(cartoon:Cartoon) {
        self.cartoon = cartoon
    }
}
struct HeaderViewModel {
    var header : HeaderCartoon
    
    var img : URL? {
        return URL(string: header.image)
    }
    var cap : String {
        return header.caption
    }
    
    init(header : HeaderCartoon ){
        self.header = header
    }
}

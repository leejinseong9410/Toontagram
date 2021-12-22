//
//  UserCellViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit

// UserCell 에서 받을 ViewModel
struct UserCellViewModel {
    private let user : User
    
    var profileImageURL : URL?{
        return URL(string: user.profileImageUrl)
    }
    var userName : String {
        return user.name
    }
    var userPenname : String {
        return user.penname
    }
    init(user:User) {
        self.user = user
    }
}


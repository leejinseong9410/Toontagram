//
//  SetUpViewModel.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit

class SetUpViewModel {
    var setup : SetUp
    
    init(setup : SetUp) {
        self.setup = setup
    }
    var imageView : UIColor { return setup.image }
}


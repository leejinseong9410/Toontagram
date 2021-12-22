//
//  SetUp.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import UIKit

enum DrawSection {
    case THUMBNAIL
    case PAGEONE
    case PAGETWO
    case PAGETHREE
    case PAGEFOUR
}
class SetUp{
    let image : UIColor
    let type : DrawSection
    init(image:UIColor,type:DrawSection) {
        self.image = image
        self.type = type
    }
}

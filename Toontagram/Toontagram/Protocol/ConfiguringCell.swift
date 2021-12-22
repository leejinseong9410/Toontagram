//
//  ConfiguringCell.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with cartoon: Cartoon)
}

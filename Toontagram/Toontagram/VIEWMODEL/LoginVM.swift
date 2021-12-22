//
//  RegisterVM.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/14.
//

import Foundation
import Combine

class LoginVM {
    @Published var emailInput : String = ""
    @Published var passwordnput : String = ""
    
    lazy var isEmpty : AnyPublisher<Bool,Never> = Publishers.CombineLatest($emailInput,$passwordnput).map { (email:String,password:String) in
        if password.isEmpty == false && email.isEmpty == false {
            return true
        }else{
            return false
        }
    }.eraseToAnyPublisher()
}

class SignInVM {
    @Published var emailInput : String = ""
    @Published var passwordnput : String = ""
    @Published var pennameInput : String = ""
    @Published var nameInput : String = ""
    
    lazy var emptyVaild : AnyPublisher<Bool,Never> = Publishers.CombineLatest4($emailInput,$passwordnput,$pennameInput,$nameInput).map { (email:String,password:String,penname:String,name:String) in
        if email.isEmpty == false && password.isEmpty == false && penname.isEmpty == false && name.isEmpty == false {
            return true
        }else {
            return false
        }
    }.eraseToAnyPublisher()
}

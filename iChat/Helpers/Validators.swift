//
//  Validators.swift
//  iChat
//
//  Created by Alexandr on 20.05.2021.
//

import Foundation

class Validators {
    
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password, let confirmPassword = confirmPassword, let email = email, password != "", confirmPassword != "", email != "" else { return false }
        return true
    }
    
    static func isFilled(username: String?, descrption: String?, sex: String?) -> Bool {
        guard let username = username, let descrption = descrption, let sex = sex, username != "", descrption != "", sex != "" else { return false }
        return true
    }
    
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegEx)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
}

//
//  MUser.swift
//  iChat
//
//  Created by Alexandr on 18.05.2021.
//

import UIKit
import Firebase

struct MUser: Hashable, Decodable {
    let username: String
    var avatarStringURL: String
    let email: String
    let description: String
    let sex: String
    let id: String
    
    init(username: String, avatarStringURL: String, email: String, description: String, sex: String, id: String) {
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data() 
        guard let username = data["username"] as? String else { return nil }
        guard let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        guard let email = data["email"] as? String else { return nil }
        guard let description = data["description"] as? String else { return nil }
        guard let sex = data["sex"] as? String else { return nil }
        guard let id = data["uid"] as? String else { return nil }
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let username = data["username"] as? String else { return nil }
        guard let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        guard let email = data["email"] as? String else { return nil }
        guard let description = data["description"] as? String else { return nil }
        guard let sex = data["sex"] as? String else { return nil }
        guard let id = data["uid"] as? String else { return nil }
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    var representation: [String: Any] {
        var representation: [String : Any] = ["username" : username]
        representation["avatarStringURL"] = avatarStringURL
        representation["email"] = email
        representation["description"] = description
        representation["sex"] = sex
        representation["uid"] = id
        return representation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
}

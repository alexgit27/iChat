//
//  MChat.swift
//  iChat
//
//  Created by Alexandr on 18.05.2021.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    let friendUsername: String
    let friendAvatarStringURL: String
    let lastMessageContent: String
    let friendId: String

    init(friendUsername: String, friendAvatarStringURL: String, lastMessageContent: String, friendId: String) {
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let friendUsername = data["friendUsername"] as? String else { return nil }
        guard let friendAvatarStringURL = data["friendAvatarStringURL"] as? String else { return nil }
        guard let lastMessageContent = data["lastMessage"] as? String else { return nil }
        guard let friendId = data["friendId"] as? String else { return nil }

        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let friendUsername = data["friendUsername"] as? String else { return nil }
        guard let friendAvatarStringURL = data["friendAvatarStringURL"] as? String else { return nil }
        guard let lastMessageContent = data["lastMessage"] as? String else { return nil }
        guard let friendId = data["friendId"] as? String else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }

    var representation: [String : Any] {
        var representation: [String : Any] = ["friendUsername" : friendUsername]
        representation["friendAvatarStringURL"] = friendAvatarStringURL
        representation["lastMessage"] = lastMessageContent
        representation["friendId"] = friendId
        return representation
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }

    static func ==(lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}

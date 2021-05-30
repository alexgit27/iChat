//
//  MMessage.swift
//  iChat
//
//  Created by Alexandr on 24.05.2021.
//

import Foundation
import FirebaseFirestore
import MessageKit

struct CustomSender: SenderType {
    var senderId: String
    var displayName: String
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct MMessage: Hashable, MessageType {
    
    var sender: SenderType
    var content: String
    var sentDate: Date
    var id: String?
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }

    init(user: MUser, content: String) {
        self.sender = CustomSender(senderId: user.id, displayName: user.username)
        self.content = content
        self.sentDate = Date()
        self.id = nil
    }
    
    init(user: MUser, image: UIImage) {
        self.sender = CustomSender(senderId: user.id, displayName: user.username)
        self.content = ""
        self.sentDate = Date()
        self.image = image
        self.id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let senderUsername = data["senderUsername"] as? String else { return nil }

        self.id = document.documentID
        self.sentDate = sentDate.dateValue()
        self.sender = CustomSender(senderId: senderId, displayName: senderUsername)
        
        if let content = data["content"] as? String {
            self.content = content
            self.downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    var representation: [String : Any] {
        var representation: [String : Any] = ["created" : sentDate]
        representation["senderId"] = sender.senderId
        representation["senderUsername"] = sender.displayName
        
        if let url = downloadURL {
            representation["url"] = url.absoluteString
        } else {
            representation["content"] = content
        }
        return representation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func ==(lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

// MARK: - Comparable
extension MMessage: Comparable {
    static func <(lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

//
//  FirestoreService.swift
//  iChat
//
//  Created by Alexandr on 20.05.2021.
//

import Foundation
import FirebaseFirestore
import Firebase

class FirestoreService {
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    private var requestChatRef: CollectionReference {
        return db.collection(["users", currentUser.id, "requestChats"].joined(separator: "/"))
    }
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    private var currentUser: MUser!
    
    // MARK: - Save Profile
    
    func saveProfileWith(id: String, email: String, username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        guard Validators.isFilled(username: username, descrption: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        guard avatarImage != #imageLiteral(resourceName: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var mUser = MUser(username: username!, avatarStringURL: "not exist", email: email, description: description!, sex: sex!, id: id)
        
        StorageService.shared.uploadImage(photo: avatarImage!) { (result) in
            switch result {
            case .success(let url):
                mUser.avatarStringURL = url.absoluteString
                
                self.usersRef.document(mUser.id).setData(mUser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(mUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
      
    }
    
    // MARK: - Get User Data
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                self.currentUser = mUser
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    // MARK: - Create Chats
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        // Fatal Error bescause when user register currentUser is nil!!!
        let messageReference = reference.document(currentUser.id).collection("messages")

        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username, friendAvatarStringURL: currentUser.avatarStringURL, lastMessageContent: message.content, friendId: currentUser.id)
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            messageReference.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(Void()))
            }
        }
    }
    
    func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for message in messages {
                messageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    func createRequestChat(message: String,  receiverUser: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let chat = MChat(friendUsername: receiverUser.username, friendAvatarStringURL: receiverUser.avatarStringURL, lastMessageContent: message, friendId: receiverUser.id)
        
        requestChatRef.document(receiverUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                completion(.success(Void()))
            }
        }
    }
    
    // MARK: - Delete Chats
    
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteWaitingChatMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteActiveChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        activeChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteActiveChatMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteRequestChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        requestChatRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(Void()))
        }
    }
    
    
    func deleteActiveChats(completion: @escaping (Result<Void, Error>) -> Void) {
        getActiveChats { (result) in
            switch result {
            case .success(let chats):
                for chat in chats {
                    let chatId = chat.friendId
                    self.activeChatsRef.document(chatId).delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        self.deleteActiveChat(chat: chat) { (result) in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteWaitingChats(completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChats { (result) in
            switch result {
            case .success(let chats):
                for chat in chats {
                    let chatId = chat.friendId
                    self.waitingChatsRef.document(chatId).delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        self.deleteWaitingChat(chat: chat) { (result) in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteRequestsChat(completion: @escaping (Result<Void, Error>) -> Void) {
        getRequests { (result) in
            switch result {
            case .success(let requests):
                for request in requests {
                    let requestId = request.friendId
                    self.requestChatRef.document(requestId).delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        self.deleteRequestsChat { (result) in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Delete Messsages From Chats
    
    func deleteWaitingChatMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageReference = reference.document(documentId)
                    messageReference.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteActiveChatMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = activeChatsRef.document(chat.friendId).collection("messages")
        
        getActiveChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageReference = reference.document(documentId)
                    messageReference.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

// MARK: - Get Messages From Chats
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func getActiveChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = activeChatsRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    // MARK: - Get Chats
    
    func getActiveChats(completion: @escaping (Result<[MChat], Error>) -> Void) {
    var chats = [MChat]()
        usersRef.document(currentUser.id).collection("activeChats").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }
            if let querySnapshot = querySnapshot, querySnapshot.isEmpty {
                completion(.success(chats))
                return
            }
            for document in querySnapshot!.documents {
                guard let chat = MChat(document: document) else { return }
                chats.append(chat)
            }
                completion(.success(chats))
        }

    }
    
    func getWaitingChats(completion: @escaping (Result<[MChat], Error>) -> Void) {
    var chats = [MChat]()
        usersRef.document(currentUser.id).collection("waitingChats").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let querySnapshot = querySnapshot, querySnapshot.isEmpty {
                completion(.success(chats))
                return
            }
            for document in querySnapshot!.documents {
                guard let chat = MChat(document: document) else { return }
                chats.append(chat)
            }
            completion(.success(chats))
        }
    }
    
    func getRequests(completion: @escaping (Result<[MChat], Error>) -> Void) {
        var requests = [MChat]()
        requestChatRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let querySnapshot = querySnapshot, querySnapshot.isEmpty {
                completion(.success(requests))
                return
            }
            for document in querySnapshot!.documents {
                guard let request = MChat(document: document) else { return }
                requests.append(request)
            }
            completion(.success(requests))
        }
    }
    
// MARK: - Change Chat To Active
    
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
 // MARK: - Send Message
    
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        let chatForFriend = MChat(friendUsername: currentUser.username,
                                  friendAvatarStringURL: currentUser.avatarStringURL,
                                  lastMessageContent: message.content,
                                  friendId: currentUser.id)
        
        friendRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            friendMessageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    // MARK: - Delete User
    
    func deletUser(userPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {

        self.deleteActiveChats { (result) in
            switch result {
            case .success():
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }

        self.deleteWaitingChats { (result) in
            switch result {
            case .success():
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }

        self.deleteRequestsChat { (result) in
            switch result {
            case .success():
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }

        usersRef.document(Auth.auth().currentUser!.uid).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                let user = Auth.auth().currentUser
                let credential: AuthCredential = EmailAuthProvider.credential(withEmail: user!.email!, password: userPassword)
                user?.reauthenticate(with: credential, completion: { (result, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    user?.delete(completion: { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    })
                })
            }
        }
    }
    
    // MARK: Checking the send request
    
    func chekRequest(receiverUser: MUser, completion: @escaping (Bool) -> Void) {
        
        requestChatRef.document(receiverUser.id).getDocument { (document, error) in
            if let _ = error {
                return
            }
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}


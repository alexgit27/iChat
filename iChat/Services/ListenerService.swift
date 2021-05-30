//
//  ListenerService.swift
//  iChat
//
//  Created by Alexandr on 22.05.2021.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ListenerService {
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func usersObserve(users: [MUser], completion: @escaping (Result<[MUser], Error>) -> Void) -> ListenerRegistration? {
        var users = users
        let usersListener = usersRef.addSnapshotListener { (qeuerySnapshot, error) in
            guard let snapshot = qeuerySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (documentChange) in
                guard let mUser = MUser(document: documentChange.document) else { return }
                
                switch documentChange.type {
                case .added:
//                    guard !users.contains(mUser) else { return }
                    guard mUser.id != self.currentUserId else { return }
                    users.append(mUser)
                case .modified:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users[index] = mUser
                case .removed:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users.remove(at: index)
                }
            }
            
            completion(.success(users))
        }
        
        return usersListener
    }
    
    func waitingChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatRefference = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))

        let chatsListener = chatRefference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }

            snapshot.documentChanges.forEach { (difference) in
                guard let mChat = MChat(document: difference.document) else { return }

                switch difference.type {
                case .added:
                    guard !chats.contains(mChat) else { return }
                    chats.append(mChat)
                case .modified:
                    guard let index = chats.firstIndex(of: mChat) else { return }
                    chats[index] = mChat
                case .removed:
                    guard let index = chats.firstIndex(of: mChat) else { return }
                    chats.remove(at: index)
                }
            }

            completion(.success(chats))
        }
        return chatsListener
    }

    func activeChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatRefference = db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))

        let chatsListener = chatRefference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }

            snapshot.documentChanges.forEach { (difference) in
                guard let mChat = MChat(document: difference.document) else { return }

                switch difference.type {
                case .added:
//                    guard !chats.contains(mChat) else { return }
                    chats.append(mChat)
                case .modified:
                    guard let index = chats.firstIndex(of: mChat) else { return }
                    chats[index] = mChat
                case .removed:
                    guard let index = chats.firstIndex(of: mChat) else { return }
                    chats.remove(at: index)
                }
            }

            completion(.success(chats))
        }
        return chatsListener
    }
    
    func messageObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        let refference = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        
        let messageListener = refference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { (documentChange) in
                guard let message = MMessage(document: documentChange.document) else { return }
                switch documentChange.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messageListener
    }
}

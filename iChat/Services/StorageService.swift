//
//  StorageService.swift
//  iChat
//
//  Created by Alexandr on 22.05.2021.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    
    let storageRef = Storage.storage().reference()
    
    private var avatarRef: StorageReference {
        return storageRef.child("Avatars")
    }
    
    private var chatsRef: StorageReference {
        return storageRef.child("Chats")
    }
    
    private var userId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func uploadImage(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        avatarRef.child(userId).putData(imageData, metadata: metaData) { (metaData, error) in
            guard let _ = metaData else {
                completion(.failure(error!))
                return
            }
            
            self.avatarRef.child(self.userId).downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(downloadUrl))
            }
        }
    }
    
    func uploadImageMessage(photo: UIImage, to chat: MChat, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
//        let currentUser = Auth.auth().currentUser!
//        let chatName = [chat.friendUsername, currentUser.email!].joined()
        let chatName = [chat.friendUsername, userId].joined()
        
        self.chatsRef.child(chatName).child(imageName).putData(imageData, metadata: metaData) { (storageMetadata, error) in
            guard let _ = storageMetadata else {
                completion(.failure(error!))
                return
            }
            self.chatsRef.child(chatName).child(imageName).downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(downloadUrl))
            }
        }
        
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            completion(.success(UIImage(data: imageData)))
        }
    }
}

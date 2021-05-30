//
//  WaitingChatsNavigation.swift
//  iChat
//
//  Created by Alexandr on 24.05.2021.
//

import Foundation

protocol WaitingChatsNavigation: class {
    func removeWaitingChat(chat: MChat)
    func moveChatToActive(chat: MChat)
}

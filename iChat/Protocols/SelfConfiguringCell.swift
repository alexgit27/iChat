//
//  SelfConfiguringCell.swift
//  iChat
//
//  Created by Alexandr on 16.05.2021.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}

//
//  UILabel + Extension.swift
//  iChat
//
//  Created by Alexandr on 10.05.2021.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
}

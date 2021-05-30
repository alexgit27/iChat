//
//  MainTabBarController.swift
//  iChat
//
//  Created by Alexandr on 13.05.2021.
//

import UIKit

class MainTabBarController: UITabBarController {
   private let currentUser: MUser
    
    init(currentUser: MUser = MUser(username: "Default", avatarStringURL: "Default", email: "Default", description: "Default", sex: "Default", id: "Default")) {
        self.currentUser = currentUser
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 0.5568627451, green: 0.3529411765, blue: 0.968627451, alpha: 1)
        
        let peopleVC = PeopleViewController(currentUser: currentUser)
        let listVC = ListViewController(currentUser: currentUser)
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig)
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)
        
        viewControllers = [generateNavigationVC(rootViewController: peopleVC, title: "People", image: peopleImage!), generateNavigationVC(rootViewController: listVC, title: "Conversations", image: convImage!)]
    }
    
    private func generateNavigationVC(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}

//
//  ProfileViewController.swift
//  iChat
//
//  Created by Alexandr on 18.05.2021.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    let containerView = UIView()
    let imageView = UIImageView(image: #imageLiteral(resourceName: "human6"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Sara", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "Info about me", font: .systemFont(ofSize: 16, weight: .light))
    let myTextField = InsertableTextField()
    private let user: MUser
    
    init(user: MUser) {
        self.user = user
        self.nameLabel.text = user.username
        self.aboutMeLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardWillShow()
        keyboardWillHide()
        configureTF()
        
        setupConstraints()
        customizeElements()
        
    }
    
    private func customizeElements() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0
        
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
        
        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    @objc func sendMessage() {
        guard let message = myTextField.text, message != " " else { return }
        FirestoreService.shared.chekRequest(receiverUser: self.user) { (condition) in
            if condition {
                UIApplication.getTopViewController()?.showAlertController(with: "U can't send message", and: "Message was sended before!")
                self.myTextField.text = ""
            } else {
        self.dismiss(animated: true) {
            FirestoreService.shared.createWaitingChat(message: message, receiver: self.user) { (result) in
                switch result {
                case .success():
                    FirestoreService.shared.createRequestChat(message: message, receiverUser: self.user) { (result) in
                        switch result {
                        case .success():
                            UIApplication.getTopViewController()?.showAlertController(with: "Success", and: "Message for user \(self.user.username) was sended! and saved")
                        case .failure(let error):
                            UIApplication.getTopViewController()?.showAlertController(with: "Error", and: error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAlertController(with: "Error", and: error.localizedDescription)
                }
            }
        }
    }
}
}

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        print("ProfileViewController")
    }
}

// MARK: -Setup Constraints
extension ProfileViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(myTextField)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

// MARK: -Notification Center
extension ProfileViewController {
    func keyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHandler), name: UIResponder.keyboardWillShowNotification, object: nil)
        let gestureResignFirstResponder = UITapGestureRecognizer(target: self, action: #selector(gestureResignFirstResponderHandler))
        view.addGestureRecognizer(gestureResignFirstResponder)
    }
    
   private func keyboardWillHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideHandler), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func gestureResignFirstResponderHandler() {
        myTextField.resignFirstResponder()
        view.frame.origin.y = 0
    }
    
    @objc private func keyboardWillShowHandler(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            view.frame.origin.y = -kbFrameSize.height + 60
    }
    
    
    
    @objc private func keyboardWillHideHandler() {
        view.frame.origin.y = 0
    }
    
}

// MARK: -Setup TextField
extension ProfileViewController: UITextFieldDelegate {
    private func configureTF() {
        myTextField.delegate = self
        
        keyboardWillShow()
        keyboardWillHide()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - SwiftUI
//import SwiftUI
//
//struct ProfileViewControllerProvider: PreviewProvider {
//    static var previews: some View {
//        ContainerView().edgesIgnoringSafeArea(.all)
//    }
//    
//    struct ContainerView: UIViewControllerRepresentable {
//        let viewController = ProfileViewController()
//        
//        func makeUIViewController(context: Context) -> ProfileViewController {
//            return viewController
//        }
//        
//        func updateUIViewController(_ uiViewController: ProfileViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProfileViewControllerProvider.ContainerView>) {
//            
//        }
//    }
//}

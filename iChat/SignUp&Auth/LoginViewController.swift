//
//  LoginViewController.swift
//  iChat
//
//  Created by Alexandr on 12.05.2021.
//

import UIKit



class LoginViewController: UIViewController {
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    let loginWithLabel = UILabel(text: "Login with")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    

    let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark())
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    
    weak var delegate: AuthNavigatingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupConstraints()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        needAnAccountLabel.minimumScaleFactor = 0.5
        needAnAccountLabel.allowsDefaultTighteningForTruncation = true
    }
    
   @objc private func loginButtonTapped() {
    AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { (result) in
        switch result {
        case .success(let user):
            self.showAlertController(with: "Success!", and: "You succes sign in!", functionFrom: "loginButtonTapped") {
                FirestoreService.shared.getUserData(user: user) { (result) in
                switch result {
                case .success(let mUser):
                    let mainTabBar = MainTabBarController(currentUser: mUser)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true, completion: nil)
                case .failure(_):
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            }}
        case .failure(let error):
            self.showAlertController(with: "Error!", and: error.localizedDescription, functionFrom: "loginButtonTapped case 2")
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true, completion: {
            self.delegate?.toSignUpVC()
        })
     }
}

// MARK: - Setup Constraints
extension LoginViewController {
    private func setupConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, loginButton], axis: .vertical, spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
//            welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(lessThanOrEqualTo: welcomeLabel.bottomAnchor, constant: 70),
//            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - SwiftUI
import SwiftUI

struct LoginViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let viewController = LoginViewController()
        
        func makeUIViewController(context: Context) -> LoginViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: LoginViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<LoginViewControllerProvider.ContainerView>) {
            
        }
    }
}

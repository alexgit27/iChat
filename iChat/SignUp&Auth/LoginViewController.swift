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
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    
    let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark())
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    weak var delegate: AuthNavigatingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardWillShow()
        keyboardWillHide()
        configureTF()
        
        view.backgroundColor = .white
        setupConstraints()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        needAnAccountLabel.minimumScaleFactor = 0.5
        needAnAccountLabel.allowsDefaultTighteningForTruncation = true
    }
    
    // MARK: Selectors for buttons
   @objc private func loginButtonTapped() {
    AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { (result) in
        switch result {
        case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (result) in
                switch result {
                case .success(let mUser):
                    let mainTabBar = MainTabBarController(currentUser: mUser)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true, completion: nil)
                case .failure(_):
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            }
        case .failure(let error):
            self.showAlertController(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true, completion: {
            self.delegate?.toSignUpVC()
        })
     }
    
    
    deinit {
        // remove observers for keyboard
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: -Setup Constraints
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
            welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 100),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(lessThanOrEqualTo: welcomeLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -40)
        ])
    }
}

// MARK: -Notification Center
extension LoginViewController {
   private func keyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHandler), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let gestureResignFirstResponder = UITapGestureRecognizer(target: self, action: #selector(gestureResignFirstResponderHandler))
        view.addGestureRecognizer(gestureResignFirstResponder)
    }
    
   private func keyboardWillHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideHandler), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Selector for UITapGestureRecognizer
    @objc private func gestureResignFirstResponderHandler() {
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        view.frame.origin.y = 0
    }
    
    // Selector for keyboard when will show
    @objc private func keyboardWillShowHandler(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        view.frame.origin.y = -kbFrameSize.height + 120
        view.frame.origin.y = -kbFrameSize.height / 2
    }
    
    // Selector for keyboard when will hide
    @objc private func keyboardWillHideHandler() {
        view.frame.origin.y = 0
    }
}

// MARK: -Setup TextField
extension LoginViewController: UITextFieldDelegate {
    private func configureTF() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        
        emailTextField.tag = 1
        passwordTextField.tag = 2
        
        keyboardWillShow()
        keyboardWillHide()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
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

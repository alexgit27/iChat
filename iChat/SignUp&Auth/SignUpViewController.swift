//
//  SignUpViewController.swift
//  iChat
//
//  Created by Alexandr on 12.05.2021.
//

import UIKit

class SignUpViewController: UIViewController {
    
    let welcomeLabel = UILabel(text: "Good to see you", font: .avenir26())
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let confirmPasswordLabel = UILabel(text: "Confirm password")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    let signUpButton  = UIButton(title: "Sign Up", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    let confirmPasswordTextField = OneLineTextField(font: .avenir20())
    
    weak var delegate: AuthNavigatingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        configureTF()
      
        view.backgroundColor = .white
        
        setupConstraints()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc func signUpButtonTapped() {
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlertController(with: "Success!", and: "You register!", completion: {
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                })
            case .failure(let error):
                self.showAlertController(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    @objc func loginButtonTapped() {
        dismiss(animated: true, completion: {
            self.delegate?.toLoginVC()
        })
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Setup Constraints
extension SignUpViewController {
    private func setUpStacks() {
        
    }
    
    private func setupConstraints(keyboardIsShow: Bool = false, keyboardSize: CGRect? = nil) {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, confirmPasswordStackView, signUpButton], axis: .vertical, spacing: 40)
        if self.view.frame.size.height <=  568 {
            stackView.spacing = 10
        }
        loginButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnboardLabel, loginButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        //stackView.backgroundColor = .orange
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
    
        if keyboardIsShow {
            view.addSubview(welcomeLabel)
            view.addSubview(stackView)
            view.addSubview(bottomStackView)
              NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
          //  bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
            self.updateViewConstraints()
        } else {
            
            NSLayoutConstraint.activate([
                welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
//                welcomeLabel.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 20),
                welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 100),
//                stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 80),
//                stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            ])
            
            NSLayoutConstraint.activate([
                bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
                bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
            ])
        }
        
    }
}

extension SignUpViewController {
    
}

// MARK: - Notification Center
extension SignUpViewController {
    func keyboardDidShow() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboaedDidShowHandler), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowHandler), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideHandler), name: UIResponder.keyboardWillHideNotification, object: nil)
        print(#function)
    }
    
    @objc private func keyboardDidShowHandler(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        NSLayoutConstraint.activate([ welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: -100), welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
//        alreadyOnboardLabel.isHidden = true
        view.frame.origin.y = -(kbFrameSize.height + 110) / 2
//        view.frame.origin.y = -kbFrameSize.height + 200
//        view.frame.origin.y = -kbFrameSize.height
//        NSLayoutConstraint.activate([signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -kbFrameSize.height)])
//        NSLayoutConstraint.activate([alreadyOnboardLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)])
    }
    
    @objc private func keyboardWillHideHandler(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
//        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        NSLayoutConstraint.activate([signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -kbFrameSize.height)])
        view.frame.origin.y = 0
    }
}

// MARK: - Setup TextField
extension SignUpViewController: UITextFieldDelegate {
    private func configureTF() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        emailTextField.tag = 1
        passwordTextField.tag = 2
        confirmPasswordTextField.tag = 3
        
        keyboardDidShow()
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

struct SignUpViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let viewController = SignUpViewController()
        
        func makeUIViewController(context: Context) -> SignUpViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: SignUpViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SignUpViewControllerProvider.ContainerView>) {
            
        }
    }
}

extension UIViewController {
    func showAlertController(with title: String, and message: String, completion: @escaping () -> Void = {} ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
          completion()
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

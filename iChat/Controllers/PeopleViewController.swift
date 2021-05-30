//
//  PeopleViewController.swift
//  iChat
//
//  Created by Alexandr on 13.05.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class PeopleViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case users
        
        func description(usersCount: Int) -> String {
            return "\(usersCount) people nearby"
        }
    }
    
    var users = [MUser]()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MUser>!
    
    private let currentUser: MUser
     
    private var usersListener: ListenerRegistration?
    
    init(currentUser: MUser) {
         self.currentUser = currentUser
         
         super.init(nibName: nil, bundle: nil)
        
         title = currentUser.username.uppercased()
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        usersListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete Account", style: .plain, target: self, action: #selector(deleteAccount))
        
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            switch result {
            
            case .success(let users):
                self.users = users
                self.reloadData(with: nil)
            case .failure(let error):
                // HERE!
                print("")
//                self.showAlertController(with: "Error!", and: error.localizedDescription)
 
            }
        })
        
      
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
    }
    
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are u sure u want to Log Out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
                self.usersListener?.remove()
            } catch {
                print("Cannot sign out \(error.localizedDescription)")
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)t
        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func deleteAccount() {
//        let alertController = UIAlertController(title: nil, message: "Delet Account?", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
//        let okAction = UIAlertAction(title: "Delete", style: .default) { _ in
            
            let passwordController = UIAlertController(title: nil, message: "Input Password!", preferredStyle: .alert)
            let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction2 = UIAlertAction(title: "Delete", style: .default) { _ in
                print("hi")
                FirestoreService.shared.deletUser(userPassword: (passwordController.textFields?.first?.text)!) { (result) in
                    switch result {
                    case .success():
//                        try!  Auth.auth().signOut()
                        UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            passwordController.addTextField(configurationHandler: nil)
            passwordController.addAction(cancelAction2)
            passwordController.addAction(okAction2)
            UIApplication.getTopViewController()?.present(passwordController, animated: true, completion: nil)
//            self.present(passwordController, animated: true, completion: nil)
        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(okAction)
//        UIApplication.getTopViewController()?.present(alertController, animated: true, completion: nil)
//    }
}

// MARK: - Search Bar
extension PeopleViewController: UISearchBarDelegate {
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

// MARK: - Data Source
extension PeopleViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = {(collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Cann't create new section header")
            }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            sectionHeader.configure(title: section.description(usersCount: items.count), font: .systemFont(ofSize: 36, weight: .light), textColor: .label)
            
            return sectionHeader
        }
    }
    
    private func reloadData(with searchText: String?) {
        let filteredUsers = users.filter{ user -> Bool in
            user.contains(filter: searchText)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filteredUsers, toSection: .users)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Setup Layout
extension PeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
          
            guard let section = Section(rawValue: sectionIndex) else { fatalError("Unknown section") }
            
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    private func createUsersSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6))
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
//            .horizontal(layoutSize: groupSize, subitems: [item])
        let spacing = CGFloat(15)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 15, bottom: 0, trailing: 15)
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
}

// MARK: - UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else { return }
        let profileVC = ProfileViewController(user: user)
        present(profileVC, animated: true, completion: nil)
    }
}

// MARK: - SwiftUI
import SwiftUI

struct PeopleViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let viewController = MainTabBarController()
        
        func makeUIViewController(context: Context) -> MainTabBarController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: PeopleViewControllerProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<PeopleViewControllerProvider.ContainerView>) {
            
        }
    }
}

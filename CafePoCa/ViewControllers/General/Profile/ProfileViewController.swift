//
//  ProfileViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/10/25.
//

import UIKit

class ProfileViewController: UIViewController {

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
    }
}


// MARK: - Extension: navigationBar Setup
extension ProfileViewController {
    
    private func setupNavigationBar() {
        navigationItem.backBarButtonItem?.isHidden = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let backButtonImage = UIImage(systemName: "arrow.backward.square", withConfiguration: config)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.title = "Profile"
        
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}


//
//  KeywordSearchViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/10/25.
//

import UIKit

class KeywordSearchViewController: UIViewController {
    
    // MARK: - Variable
    private var keyword: String = ""
    private var shouldActivateSearch: Bool = true
    
    
    // MARK: - UI Component
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: resultsViewController)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search"
        return controller
    }()
    
    private let resultsViewController = KeywordResultsViewController()
    
    
    // MARK: - Init
    init(with keyword: String) {
        super.init(nibName: nil, bundle: nil)
        self.keyword = keyword
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchControllerSetup()
        setupNavigationBar()
        
        searchController.searchBar.text = keyword
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldActivateSearch {
            shouldActivateSearch = false // 한 번만 실행되도록 방지
            searchController.isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.searchController.searchBar.becomeFirstResponder()
                self.resultsViewController.updateResults(for: self.keyword)
            }
        }
    }
    
    
    // MARK: - Function
    private func searchControllerSetup() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}


// MARK: - Extension: UISearchResultsUpdating
extension KeywordSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.isEmpty,
              let resultsVC = searchController.searchResultsController as? KeywordResultsViewController else {
            return
        }
        resultsVC.updateResults(for: query)
    }
}


// MARK: - Extension: NavigaitonBar Setup
extension KeywordSearchViewController {
    
    private func setupNavigationBar() {
        navigationItem.backBarButtonItem?.isHidden = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let backButtonImage = UIImage(systemName: "arrow.backward.square", withConfiguration: config)
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Search"
        
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

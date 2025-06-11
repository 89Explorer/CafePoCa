//
//  KeywordResultsViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/10/25.
//

import UIKit

class KeywordResultsViewController: UIViewController {
    
    
    // MARK: - Variable
    private var dummyData: [String] = ["스타벅스", "메가커피", "컴포즈커피", "카페베네", "할리스커피"]
    private var results: [String] = []
    
    
    // MARK: - UI Component
    private var tableView: UITableView = UITableView()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewSetup()
    }
    
    
    // MARK: - Function
    private func tableViewSetup() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
    }
    
    func updateResults(for query: String) {
        print("🔍 검색어: \(query)")
        results = dummyData.filter { $0.localizedCaseInsensitiveContains(query)}
        tableView.reloadData()
    }
}


// MARK: - Extension: UITableViewDataSource
extension KeywordResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
}

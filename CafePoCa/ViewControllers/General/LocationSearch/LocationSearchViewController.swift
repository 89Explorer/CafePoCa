//
//  LocationSearchViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/9/25.
//

import UIKit
import CoreLocation

class LocationSearchViewController: UIViewController {
    
    // MARk: - Variable
    weak var delegate: LocationSearchDelegate?
    
    // MARK: - UI Components
    private let searchCurrentLocationButton: UIButton = UIButton(type: .system)
    private let cancelButton: UIButton = UIButton(type: .system)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        handleSearchCurrentLocation()
    }
    
    
    // MARK: - Function
    private func setupUI() {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .systemBackground
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        config.image = UIImage(systemName: "location.circle")
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.title = "현재 위치로 찾기"
        
        searchCurrentLocationButton.configuration = config
        searchCurrentLocationButton.layer.borderColor = UIColor.systemGray4.cgColor
        searchCurrentLocationButton.layer.borderWidth = 1
        searchCurrentLocationButton.layer.cornerRadius = 8
        searchCurrentLocationButton.clipsToBounds = true
        
        var configCancel = UIButton.Configuration.filled()
        configCancel.baseBackgroundColor = .systemBackground
        configCancel.baseForegroundColor = .systemRed
        configCancel.cornerStyle = .medium
        configCancel.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        configCancel.title = "닫기"
        
        cancelButton.configuration = configCancel
        //cancelButton.titleLabel?.textColor = .systemRed
        cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 8
        cancelButton.clipsToBounds = true
        
        view.addSubview(searchCurrentLocationButton)
        view.addSubview(cancelButton)
        searchCurrentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchCurrentLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchCurrentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchCurrentLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            searchCurrentLocationButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.leadingAnchor.constraint(equalTo: searchCurrentLocationButton.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: searchCurrentLocationButton.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: searchCurrentLocationButton.bottomAnchor, constant: 8),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func handleSearchCurrentLocation() {
        searchCurrentLocationButton.addTarget(self, action: #selector(didTappedSearchCurrentLocationButton), for: .touchUpInside)
        
        cancelButton.addTarget(self, action: #selector(didTappedCancelButton), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    @objc private func didTappedSearchCurrentLocationButton() {
        print("✅ 현재위치 확인 버튼 눌림")
        LocationManagerService.shared.setHandlers(
            onUpdate: {[weak self] address, coordinate in
                self?.delegate?.checkCurrentLocation(with: address, coordinate: coordinate)
                self?.dismiss(animated: true)
            },
            onFail: { message in
                print("❌ \(message)")
                self.dismiss(animated: true)
            }
        )
        LocationManagerService.shared.startUpdatingLocation()
    }
    
    @objc private func didTappedCancelButton() {
        dismiss(animated: true)
    }
    
}


// MARK: - Protocol
protocol LocationSearchDelegate: AnyObject {
    func checkCurrentLocation(with address: String, coordinate: CLLocationCoordinate2D)
}

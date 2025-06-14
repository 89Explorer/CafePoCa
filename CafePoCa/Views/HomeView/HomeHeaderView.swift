//
//  HomeHeaderView.swift
//  CafePoCa
//
//  Created by 권정근 on 6/5/25.
//

import UIKit

class HomeHeaderView: UIView {
    
    // MARK: - Variable
    weak var delegate: HomeHeaderViewDelegate?
        
    
    // MARK: - UI Component
    private let profileImageView: UIImageView = UIImageView()
    private let locationLabel: UILabel = UILabel()
    private let locationImageView: UIImageView = UIImageView()
    private let currentLocationLabel: UILabel = UILabel()
    private let currentLocationImageView: UIImageView = UIImageView()
    private let searchButton: UIButton = UIButton()
    let searchTextField: UITextField = UITextField()
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemYellow
        layer.cornerRadius = 28
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        setupUI()
        setupGesture()
        self.searchTextField.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    private func setupUI() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24)
        let profileImage = UIImage(systemName: "person.circle", withConfiguration: imageConfig)
        profileImageView.image = profileImage
        profileImageView.tintColor = .label
        profileImageView.layer.cornerRadius = 12
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        locationLabel.text = "현재 위치"
        locationLabel.font = .systemFont(ofSize: 14, weight: .light)
        locationLabel.textColor = .label
        
        currentLocationLabel.textColor = .label
        currentLocationLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        currentLocationLabel.numberOfLines = 1
        
        currentLocationImageView.image = UIImage(systemName: "chevron.down")
        currentLocationImageView.tintColor = .label
        currentLocationImageView.isUserInteractionEnabled = true
        
        let currentStack: UIStackView = UIStackView(arrangedSubviews: [currentLocationLabel, currentLocationImageView])
        currentStack.axis = .horizontal
        currentStack.spacing = 12
        currentStack.alignment = .center
        currentStack.distribution = .fill
        
        let locationStack: UIStackView = UIStackView(arrangedSubviews: [locationLabel, currentStack])
        locationStack.axis = .vertical
        locationStack.spacing = 4
        locationStack.alignment = .center
       
        searchTextField.placeholder = "Search"
        searchTextField.backgroundColor = .systemGray6
        searchTextField.layer.cornerRadius = 12
        searchTextField.clipsToBounds = true
        searchTextField.autocapitalizationType = .none
        searchTextField.returnKeyType = .done
        searchTextField.setLeftPaddingPoints(14)
        
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        searchButton.setImage(searchImage, for: .normal)
        searchButton.layer.cornerRadius = 12
        searchButton.clipsToBounds = true
        searchButton.tintColor = .label
        searchButton.backgroundColor = .systemGray6
        
        addSubview(profileImageView)
        addSubview(locationStack)
        addSubview(searchTextField)
        addSubview(searchButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            
            locationStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            locationStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            locationStack.heightAnchor.constraint(equalToConstant: 40),
            
            searchTextField.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 0),
            searchTextField.trailingAnchor.constraint(equalTo: locationStack.trailingAnchor, constant: 0),
            searchTextField.topAnchor.constraint(equalTo: locationStack.bottomAnchor, constant: 16),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            
            searchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            searchButton.topAnchor.constraint(equalTo: searchTextField.topAnchor, constant: 0),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
    
    
    // MARK: - Function
    func configure(with currentLocationLabel: String) {
        self.currentLocationLabel.text = currentLocationLabel
    }
}


// MARK: - Extension: TextField Padding helper
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}


// MARK: - Extension: Profile, Location, Search TapGesture Setting
extension HomeHeaderView {
    
    private func setupGesture() {
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        profileImageView.addGestureRecognizer(profileTapGesture)
        
        let locationTapGesture = UITapGestureRecognizer(target: self, action: #selector(locationImageViewTapped))
        currentLocationImageView.addGestureRecognizer(locationTapGesture)
        
        searchButton.addTarget(self, action: #selector(didTappedSearchButton), for: .touchUpInside)
    }
    
    
    @objc private func profileImageViewTapped() {
        delegate?.didTappedProfileImage()
    }
    
    @objc private func locationImageViewTapped() {
        delegate?.didTappedLocationImage()
    }
    
    @objc private func didTappedSearchButton() {
        let keyword = searchTextField.text ?? ""
        delegate?.didTappedSearchButton(with: keyword)
    }
}


// MARK: - Extension: UITextFieldDelegate
extension HomeHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.searchTextField {
            let keyword = searchTextField.text ?? ""
            delegate?.didTappedSearchButton(with: keyword)
        }
        return true
    }
}



// MARK: - Protocol: Profile, Location, Search
protocol HomeHeaderViewDelegate: AnyObject {
    func didTappedProfileImage()
    func didTappedLocationImage()
    func didTappedSearchButton(with keyword: String)
}

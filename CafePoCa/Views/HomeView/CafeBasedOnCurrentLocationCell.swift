//
//  CafeBasedOnCurrentLocationCell.swift
//  CafePoCa
//
//  Created by 권정근 on 6/12/25.
//

import UIKit
import SDWebImage


class CafeBasedOnCurrentLocationCell: UICollectionViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "CafeBasedOnCurrentLocationCell"
    
    
    // MARK: - UI Component
    private let imageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let addressLabel: UILabel = UILabel()
    private let moreButton: UIButton = UIButton()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.systemGray.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8.0
        layer.masksToBounds = false
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    private func setupUI() {
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        //titleLabel.textAlignment = .left
        
        addressLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 1
        //addressLabel.textAlignment = .left
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        textStack.axis = .vertical
        //textStack.backgroundColor = .secondarySystemBackground
        //textStack.isLayoutMarginsRelativeArrangement = true
        //textStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        //textStack.layer.cornerRadius = 8
        textStack.alignment = .fill
        textStack.spacing = 8
        
        moreButton.layer.cornerRadius = 8
        moreButton.layer.masksToBounds = true
        moreButton.setTitle("더보기", for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        moreButton.setTitleColor(.label, for: .normal)
        moreButton.backgroundColor = .secondarySystemBackground
        
        let totalStack = UIStackView(arrangedSubviews: [textStack, moreButton])
        totalStack.axis = .horizontal
        totalStack.spacing = 16
        totalStack.alignment = .fill
        totalStack.distribution = .fill
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        //contentView.addSubview(totalStack)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //totalStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -12)
            
//            totalStack.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 12),
//            totalStack.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -12),
//            totalStack.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
//            totalStack.heightAnchor.constraint(equalToConstant: 60),
//            
//            moreButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func configure(with item: CafeListInfo) {
        if let imageURLString = item.imageURL,
           let url = URL(string: imageURLString) {
            imageView.sd_setImage(with: url, completed: nil)
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        titleLabel.text = item.title
        addressLabel.text = item.address
    }
    
}

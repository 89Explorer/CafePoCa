//
//  CategoryCell.swift
//  CafePoCa
//
//  Created by 권정근 on 6/12/25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "CategoryCell"
    
    
    // MARK: - UI Component
    private let categoryLabel: BasePaddingLabel = BasePaddingLabel()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray3
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryLabel.text = nil
    }
    
    
    // MARK: - Function
    private func setupUI() {
        categoryLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        categoryLabel.textColor = .label
        categoryLabel.textAlignment = .center
        categoryLabel.numberOfLines = 1
        
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with category: RegionCodeInfo) {
        let categoryString = category.name 
        categoryLabel.text = categoryString
    }
}

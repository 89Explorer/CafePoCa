//
//  SectionHeaderView.swift
//  CafePoCa
//
//  Created by 권정근 on 6/12/25.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "SectionHeaderView"
    
    
    // MARK: - UI Component
    private let title: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    private func setupUI() {
        let separator: UIView = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .quaternaryLabel
        
        title.textColor = .label
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 22, weight: .bold))
        title.textAlignment = .left
        
//        subTitle.textColor = .secondaryLabel
//        subTitle.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        
        let stackView = UIStackView(arrangedSubviews: [separator, title])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            separator.heightAnchor.constraint(equalToConstant: 2),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
        
        //stackView.setCustomSpacing(10, after: separator)
    }
    
    func configure(with main: String) {
        title.text = main
    }
}

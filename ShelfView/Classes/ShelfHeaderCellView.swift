//
//  ShelfHeaderCellView.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 28/12/2018.
//

import UIKit

class ShelfHeaderCellView: UICollectionReusableView {
    let header = UIImageView()
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        header.image = Utils().loadImage(name: "header")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        header.contentMode = .scaleToFill
        headerLabel.textAlignment = .center
        headerLabel.shadowColor = .brown
        headerLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        addSubview(header)
        addSubview(headerLabel)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.topAnchor.constraint(equalTo: topAnchor),
            header.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

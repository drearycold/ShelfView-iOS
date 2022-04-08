//
//  ShelfCellView.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 11/09/2017.
//  Copyright © 2017 Adeyinka Adediji. All rights reserved.
//

import UIKit

class ShelfCellView: UICollectionViewCell {
    let shelfBackground = UIImageView()
    let bookBackground = UIView()
    
    var bookCover = UIImageView()
    let indicator = UIActivityIndicatorView()
    let spine = UIImageView()
    let options = UIButton()
    let progress = UILabel()
    let refresh = UIButton()
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(shelfBackground)
        addSubview(bookBackground)
        
        bookBackground.addSubview(bookCover)
        bookBackground.addSubview(spine)
        bookBackground.addSubview(indicator)
        bookBackground.addSubview(options)
        bookBackground.addSubview(progress)
        bookBackground.addSubview(refresh)
        
        bookCover.layer.shadowColor = UIColor.black.cgColor
        bookCover.layer.shadowRadius = 10
        bookCover.layer.shadowOffset = CGSize(width: 0, height: 0)
        bookCover.layer.shadowOpacity = 0.7
        
        indicator.color = .magenta
        spine.image = Utils().loadImage(name: "spine")
        spine.isHidden = true
        
        options.setImage(Utils().loadImage(name: "options"), for: .normal)
        options.imageView?.contentMode = .scaleAspectFit
        options.isHidden = false

        refresh.imageView?.contentMode = .scaleAspectFit
        refresh.isHidden = false
        refresh.layer.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3).cgColor
        refresh.layer.cornerRadius = 4
        refresh.layer.masksToBounds = true
        
        progress.textAlignment = .right
        progress.adjustsFontSizeToFitWidth = false
        progress.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        progress.adjustsFontForContentSizeCategory = true
        progress.baselineAdjustment = .alignCenters
        progress.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        progress.isHidden = false
        progress.layer.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.4).cgColor
        progress.layer.cornerRadius = 8
        progress.layer.masksToBounds = true
        
        shelfBackground.translatesAutoresizingMaskIntoConstraints = false
        shelfBackground.contentMode = .scaleToFill
        bookBackground.translatesAutoresizingMaskIntoConstraints = false
        
        bookCover.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                shelfBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
                shelfBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
                shelfBackground.topAnchor.constraint(equalTo: topAnchor),
                shelfBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
            ] + [
                bookBackground.heightAnchor.constraint(equalTo: heightAnchor, constant: -Dimens.bookBackgroundMargin),
                bookBackground.centerXAnchor.constraint(equalTo: shelfBackground.centerXAnchor),
                bookBackground.centerYAnchor.constraint(equalTo: shelfBackground.centerYAnchor)
            ] + [
                bookCover.heightAnchor.constraint(equalTo: bookBackground.heightAnchor, constant: -Dimens.bookCoverMargin),
                bookCover.widthAnchor.constraint(equalTo: bookCover.heightAnchor, multiplier: Dimens.bookCoverAspect),
                bookCover.centerXAnchor.constraint(equalTo: shelfBackground.centerXAnchor),
                bookCover.centerYAnchor.constraint(equalTo: shelfBackground.centerYAnchor)
            ]
        )
        
        spine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spine.topAnchor.constraint(equalTo: bookCover.topAnchor),
            spine.heightAnchor.constraint(equalTo: bookCover.heightAnchor),
            spine.leadingAnchor.constraint(equalTo: bookCover.leadingAnchor),
            spine.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        progress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                progress.trailingAnchor.constraint(equalTo: bookCover.trailingAnchor, constant: -4),
                progress.topAnchor.constraint(equalTo: bookCover.topAnchor, constant: 4),
                progress.widthAnchor.constraint(equalToConstant: 36),
                progress.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        refresh.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            refresh.leadingAnchor.constraint(equalTo: bookCover.leadingAnchor, constant: 12),
            refresh.bottomAnchor.constraint(equalTo: bookCover.bottomAnchor, constant: -4),
            refresh.widthAnchor.constraint(equalToConstant: 20),
            refresh.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        options.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            options.trailingAnchor.constraint(equalTo: bookCover.trailingAnchor, constant: 16),
            options.bottomAnchor.constraint(equalTo: bookCover.bottomAnchor, constant: -4),
            options.widthAnchor.constraint(equalToConstant: 64),
            options.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: bookCover.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: bookCover.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 50),
            indicator.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}

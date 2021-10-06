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
        refresh.layer.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6).cgColor
        refresh.layer.cornerRadius = 8
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
        
        shelfBackground.isUserInteractionEnabled = true
        bookCover.isUserInteractionEnabled = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}

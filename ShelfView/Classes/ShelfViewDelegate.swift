//
//  ShelfViewDelegate.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 14/09/2017.
//  Copyright © 2017 Adeyinka Adediji. All rights reserved.
//

import Foundation
import UIKit

public protocol PlainShelfViewDelegate: AnyObject {
    func onBookClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String)
    
    func onBookLongClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect)

    func onBookOptionsClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookRefreshClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookProgressClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect)
}

public protocol SectionShelfViewDelegate: AnyObject {
    func onBookClicked(_ shelfView: SectionShelfView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String)
    
    func onBookLongClicked(_ shelfView: SectionShelfView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookOptionsClicked(_ shelfView: SectionShelfView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookRefreshClicked(_ shelfView: SectionShelfView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
}

public protocol SectionShelfCompositionalViewDelegate: AnyObject {
    func onBookClicked(_ shelfView: SectionShelfCompositionalView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String)
    
    func onBookLongClicked(_ shelfView: SectionShelfCompositionalView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookOptionsClicked(_ shelfView: SectionShelfCompositionalView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
    
    func onBookRefreshClicked(_ shelfView: SectionShelfCompositionalView, section: Int, index: Int, sectionId: String, sectionTitle: String, bookId: String, bookTitle: String, frame inShelfView: CGRect)
}

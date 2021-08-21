//
//  BookModel.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 11/09/2017.
//  Copyright © 2017 Adeyinka Adediji. All rights reserved.
//

import Foundation

public struct BookModel {
    var bookCoverSource: String
    var bookId: String
    var bookTitle: String
    var bookProgress: Int

    public init(bookCoverSource: String, bookId: String, bookTitle: String, bookProgress: Int) {
        self.bookCoverSource = bookCoverSource
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookProgress = bookProgress
        if self.bookProgress < 0 {
            self.bookProgress = 0
        }
        if self.bookProgress > 100 {
            self.bookProgress = 100
        }
        if bookCoverSource.isEmpty {
            fatalError("bookCoverSource must not be empty")
        }
        if bookId.isEmpty {
            fatalError("bookId must not be empty")
        }
        if bookTitle.isEmpty {
            fatalError("bookTitle must not be empty")
        }
    }
}

public struct BookModelSection {
    var sectionName: String
    var sectionId: String
    var sectionBooks: [BookModel]

    public init(sectionName: String, sectionId: String, sectionBooks: [BookModel]) {
        self.sectionName = sectionName
        self.sectionId = sectionId
        self.sectionBooks = sectionBooks
    }
}

struct ShelfModel {
    var bookCoverSource: String
    var bookId: String
    var bookTitle: String
    var bookProgress: Int

    var show: Bool
    var type: String

    public init(bookCoverSource: String, bookId: String, bookTitle: String, bookProgress: Int, show: Bool, type: String) {
        self.bookCoverSource = bookCoverSource
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookProgress = bookProgress
        if self.bookProgress < 0 {
            self.bookProgress = 0
        }
        if self.bookProgress > 100 {
            self.bookProgress = 100
        }
        
        self.show = show
        self.type = type
    }
}

struct ShelfModelSection {
    var sectionName: String
    var sectionId: String
    var sectionShelf: [ShelfModel]

    public init(sectionName: String, sectionId: String, sectionShelf: [ShelfModel]) {
        self.sectionName = sectionName
        self.sectionId = sectionId
        self.sectionShelf = sectionShelf
    }
}

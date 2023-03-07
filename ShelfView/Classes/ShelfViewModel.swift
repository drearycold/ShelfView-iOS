//
//  BookModel.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 11/09/2017.
//  Copyright © 2017 Adeyinka Adediji. All rights reserved.
//

import Foundation

public struct BookModel {
    public enum BookStatus: String {
        case READY
        case NOCONNECT
        case HASUPDATE
        case UPDATING
        case DOWNLOADING
        case LOCAL
    }
    
    var bookCoverSource: String
    var bookId: String
    var bookTitle: String
    var bookProgress: Int
    var bookStatus: BookStatus

    public init(bookCoverSource: String, bookId: String, bookTitle: String, bookProgress: Int, bookStatus: BookStatus) {
        self.bookCoverSource = bookCoverSource
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookProgress = bookProgress
        self.bookStatus = bookStatus
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

public struct ShelfModel: Hashable {
    var bookCoverSource: String
    var bookId: String
    var bookTitle: String
    var bookProgress: Int
    var bookStatus: BookModel.BookStatus
    var sectionId: String
    
    public var show: Bool
    public var type: ShelfViewTileType

    public func hash(into hasher: inout Hasher) {
        hasher.combine(bookId)
        hasher.combine(sectionId)
    }
    
    public static func == (lhs: ShelfModel, rhs: ShelfModel) -> Bool {
        lhs.bookId == rhs.bookId && lhs.sectionId == rhs.sectionId
    }
    
    public init() {
        bookCoverSource = ""
        bookId = ""
        bookTitle = ""
        bookProgress = 0
        bookStatus = .READY
        sectionId = ""

        show = false
        type = .center
    }
    
    public init(bookId: String, sectionId: String, show: Bool, type: ShelfViewTileType) {
        self.bookId = bookId
        self.show = show
        self.type = type
        self.sectionId = sectionId

        bookCoverSource = ""
        bookTitle = ""
        bookProgress = 0
        bookStatus = .READY
    }
    
    public init(bookCoverSource: String, bookId: String, bookTitle: String, bookProgress: Int, bookStatus: BookModel.BookStatus, sectionId: String, show: Bool = true, type: ShelfViewTileType = .center) {
        self.bookCoverSource = bookCoverSource
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookProgress = bookProgress
        self.bookStatus = bookStatus
        self.sectionId = sectionId
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

public struct ShelfModelSection: Hashable {
    public var sectionName: String
    public var sectionId: String
    public var sectionShelf: [ShelfModel]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sectionId)
    }
    
    public static func == (lhs: ShelfModelSection, rhs: ShelfModelSection) -> Bool {
        lhs.sectionId == rhs.sectionId
    }
    
    public init(sectionName: String, sectionId: String, sectionShelf: [ShelfModel]) {
        self.sectionName = sectionName
        self.sectionId = sectionId
        self.sectionShelf = sectionShelf
    }
}

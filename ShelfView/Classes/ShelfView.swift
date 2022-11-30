//
//  ShelfView.swift
//  ShelfView
//
//  Created by Peter on 2022/11/29.
//

import Foundation

public class ShelfView: UIView {
    static let sectionHeaderElementKind = "section-header-element-kind"

    let indicatorWidth = Double(50)
    let bookCoverMargin = Double(10)
    let spineWidth = CGFloat(8)
    let bookBackgroundMarignTop = Double(23)
    let headerReferenceSizeHeight = CGFloat(50)

    var numberOfTilesPerRow: Int!
    var numberOfRowsPerScreen: Int!
    var shelfHeight: Int!
    var shelfWidth: Int!
    let gridItemWidth = Dimens.gridItemWidth
    let gridItemHeight = Dimens.gridItemHeight
    var shelfView: UICollectionView!
    var trueGridItemWidth: Double!
    
    var bookSource = ShelfViewBookSource.url
    var shelfModelSection = [ShelfModelSection]()
    public var selectedBookIds = Set<String>()

    let utils = Utils()

    var viewHasBeenInitialized = false
    
    public func setEditing(_ editing: Bool) {
        self.shelfView.isEditing = editing
        
        if editing {
            self.selectedBookIds.removeAll(keepingCapacity: true)
        }
        
        self.shelfView.reloadData()
    }
    
    public override func selectAll(_ sender: Any?) {
        let selectedCount = self.selectedBookIds.count
        
        self.shelfModelSection.forEach { section in
            section.sectionShelf.forEach { book in
                self.selectedBookIds.insert(book.bookId)
            }
        }
        
        if selectedCount != self.selectedBookIds.count {
            self.shelfView.reloadData()
        }
    }
    
    @objc public func clearSelection(_ sender: Any?) {
        if selectedBookIds.isEmpty == false {
            self.selectedBookIds.removeAll(keepingCapacity: true)
            self.shelfView.reloadData()
        }
    }
    
}

public enum ShelfViewBookSource: Int {
    case deviceDocuments
    case deviceLibrary
    case deviceCache
    case url
    case raw
    
    var searchPathDirectory: FileManager.SearchPathDirectory {
        switch self {
        case .deviceCache:
            return .cachesDirectory
        case .deviceLibrary:
            return .libraryDirectory
        case .deviceDocuments:
            return .documentDirectory
        default:
            return .trashDirectory
        }
    }
}

public enum ShelfViewTileType: String {
    case left
    case right
    case center
}

//
//  PlainShelfView.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 11/09/2017.
//  Copyright © 2017 Adeyinka Adediji. All rights reserved.
//

import Kingfisher
import UIKit

public class PlainShelfView: ShelfView {
    
    private var bookModel = [BookModel]()
//    private var shelfModel = [ShelfModel]()
    
    private let layout = UICollectionViewFlowLayout()

    public weak var delegate: PlainShelfViewDelegate!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if Int(frame.width) < gridItemWidth {
            fatalError("ShelfView width cannot be less than \(gridItemWidth)")
        }
        shelfModelSection.append(.init(sectionName: "Default", sectionId: "default", sectionShelf: []))
        initializeShelfView(width: frame.width, height: frame.height)
    }
    
    public convenience init(frame: CGRect, bookModel: [BookModel], bookSource: ShelfViewBookSource) {
        self.init(frame: frame)
        utils.delay(0) {
            self.bookSource = bookSource
            self.bookModel = bookModel
            self.processData()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if viewHasBeenInitialized {
            let width = frame.width
            let height = frame.height
            shelfView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            shelfWidth = Int(shelfView.frame.width)
            shelfHeight = Int(shelfView.frame.height)
            numberOfTilesPerRow = shelfWidth / gridItemWidth
            trueGridItemWidth = Double(shelfWidth) / Double(numberOfTilesPerRow)
            layout.itemSize = CGSize(width: trueGridItemWidth, height: Double(gridItemHeight))
            shelfView.collectionViewLayout.invalidateLayout()
            reloadBooks(bookModel: bookModel)
        }
    }
    
    private func initializeShelfView(width: CGFloat, height: CGFloat) {
        shelfView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: layout)
        shelfView.register(ShelfCellView.self, forCellWithReuseIdentifier: ShelfCellView.identifier)
        shelfView.dataSource = self
        shelfView.delegate = self
        shelfView.alwaysBounceVertical = false
        shelfView.bounces = false
        shelfView.showsVerticalScrollIndicator = false
        shelfView.showsHorizontalScrollIndicator = false
        shelfView.backgroundColor = UIColor("#C49E7A")
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.delaysTouchesBegan = true
        shelfView.addGestureRecognizer(longPressGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.delaysTouchesEnded = true
        shelfView.addGestureRecognizer(tapGestureRecognizer)
        
        addSubview(shelfView)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        shelfWidth = Int(shelfView.frame.width)
        shelfHeight = Int(shelfView.frame.height)
        numberOfTilesPerRow = shelfWidth / gridItemWidth
        trueGridItemWidth = Double(shelfWidth) / Double(numberOfTilesPerRow)
        
        layout.itemSize = CGSize(width: trueGridItemWidth, height: Double(gridItemHeight))
        shelfView.collectionViewLayout.invalidateLayout()
        
        buildShelf(sizeOfModel: 0)
        viewHasBeenInitialized = true
    }
    
    private func loadEmptyShelfBlocks(type: ShelfViewTileType) {
        shelfModelSection[0].sectionShelf.append(ShelfModel(bookCoverSource: "", bookId: "", bookTitle: "", bookProgress: 0, bookStatus: .READY, sectionId: "", show: false, type: type))
    }
    
    private func loadFilledShelfBlocks(bookCoverSource: String, bookId: String, bookTitle: String, bookProgress: Int, bookStatus: BookModel.BookStatus, type: ShelfViewTileType) {
        shelfModelSection[0].sectionShelf.append(ShelfModel(bookCoverSource: bookCoverSource, bookId: bookId, bookTitle: bookTitle, bookProgress: bookProgress, bookStatus: bookStatus, sectionId: "default", show: true, type: type))
    }
    
    public func reloadBooks(bookModel: [BookModel]) {
        self.bookModel = bookModel
        processData()
    }
    
    public func addBooks(bookModel: [BookModel]) {
        self.bookModel = self.bookModel + bookModel
        processData()
    }
    
    private func processData() {
        shelfModelSection[0].sectionShelf.removeAll()
        
        for i in 0 ..< bookModel.count {
            let bookCoverSource = bookModel[i].bookCoverSource
            let bookId = bookModel[i].bookId
            let bookTitle = bookModel[i].bookTitle
            let bookProgress = bookModel[i].bookProgress
            let bookStatus = bookModel[i].bookStatus
            
            var type = ShelfViewTileType.center
            if (i % numberOfTilesPerRow) == 0 {
                type = .left
            } else if (i % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                type = .right
            }
            
            loadFilledShelfBlocks(
                bookCoverSource: bookCoverSource,
                bookId: bookId,
                bookTitle: bookTitle,
                bookProgress: bookProgress,
                bookStatus: bookStatus,
                type: type
            )
        }
        
        buildShelf(sizeOfModel: bookModel.count)
    }
    
    private func buildShelf(sizeOfModel: Int) {
        var numberOfRows = sizeOfModel / numberOfTilesPerRow
        let remainderTiles = sizeOfModel % numberOfTilesPerRow
        
        if remainderTiles > 0 {
            numberOfRows = numberOfRows + 1
            let fillUp = numberOfTilesPerRow - remainderTiles
            for i in 0 ..< fillUp {
                if i == (fillUp - 1) {
                    loadEmptyShelfBlocks(type: .right)
                } else {
                    loadEmptyShelfBlocks(type: .center)
                }
            }
        }
        
        if (numberOfRows * gridItemHeight) < shelfHeight {
            let remainderRowHeight = (shelfHeight - (numberOfRows * gridItemHeight)) / gridItemHeight
            
            if remainderRowHeight == 0 {
                for i in 0 ..< numberOfTilesPerRow {
                    if i == 0 {
                        loadEmptyShelfBlocks(type: .left)
                    } else if i == (numberOfTilesPerRow - 1) {
                        loadEmptyShelfBlocks(type: .right)
                    } else {
                        loadEmptyShelfBlocks(type: .center)
                    }
                }
            } else if remainderRowHeight > 0 {
                let fillUp = numberOfTilesPerRow * (remainderRowHeight + 1)
                for i in 0 ..< fillUp {
                    if (i % numberOfTilesPerRow) == 0 {
                        loadEmptyShelfBlocks(type: .left)
                    } else if (i % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                        loadEmptyShelfBlocks(type: .right)
                    } else {
                        loadEmptyShelfBlocks(type: .center)
                    }
                }
            }
        }
        
        shelfView.reloadData()
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer?) {
        guard let gesture = gesture, gesture.state == .ended else { return }
        print("Tap")
        
        let location = gesture.location(in: shelfView)
        
        guard let indexPath = shelfView.indexPathForItem(at: location),
              let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView
        else { return }
        
        let shelfItem = shelfModelSection[0].sectionShelf[indexPath.row]
        guard shelfItem.show else { return }
        
        let frameInShelfView = cell.options.convert(cell.options.frame, to: shelfView).offsetBy(dx: -8, dy: -cell.options.frame.height*2-16)
        let locationinOption = gesture.location(in: cell.options)
        let locationinRefresh = gesture.location(in: cell.refresh)
        let locationInProgress = gesture.location(in: cell.progress)
        let locationInCover = gesture.location(in: cell.bookCover)
        
        if shelfView.isEditing {
            cell.select.isSelected.toggle()
            if cell.select.isSelected {
                selectedBookIds.insert(shelfItem.bookId)
            } else {
                selectedBookIds.remove(shelfItem.bookId)
            }
            return
        }
        
        if locationinOption.x > cell.options.frame.width / 4,
           locationinOption.x < cell.options.frame.width / 4 * 3,
           locationinOption.y > 0,
           locationinOption.y < cell.options.frame.height {
            delegate.onBookOptionsClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInShelfView)
            return
        }
        
        if locationinRefresh.x > 0,
           locationinRefresh.x < cell.refresh.frame.width,
           locationinRefresh.y > 0,
           locationinRefresh.y < cell.refresh.frame.height {
            delegate.onBookRefreshClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInShelfView)
            return
        }
        
        if locationInProgress.x > 0,
           locationInProgress.x < cell.progress.frame.width,
           locationInProgress.y > 0,
           locationInProgress.y < cell.progress.frame.height {
            delegate.onBookProgressClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInShelfView)
            return
        }
        
        if locationInCover.x > 0,
           locationInCover.x < cell.bookCover.frame.width,
           locationInCover.y > 0,
           locationInCover.y < cell.bookCover.frame.height {
            delegate.onBookClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle)
            return
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer?) {
        guard let gesture = gesture, gesture.state == .began else { return }
        print("Long Pressed")
        let location = gesture.location(in: shelfView)
        if let indexPath = shelfView.indexPathForItem(at: location), let cell = shelfView.cellForItem(at: indexPath) {
            let shelfItem = shelfModelSection[0].sectionShelf[indexPath.row]
            if shelfItem.show {
                let frameInSuperView = shelfView.convert(cell.frame, to: self)
                delegate.onBookLongClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
            }
        }
    }
}

extension PlainShelfView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let position = indexPath.row
        let shelfItem = shelfModelSection[0].sectionShelf[position]
        let bookCover = shelfItem.bookCoverSource.trim()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShelfCellView.identifier, for: indexPath) as! ShelfCellView
        cell.shelfBackground.contentMode = .scaleToFill
        cell.bookTitle.text = shelfItem.bookTitle
        
        cell.shelfBackground.image = utils.loadImage(name: shelfItem.type.rawValue)
        
        cell.bookCover.kf.indicatorType = .none
        cell.indicator.startAnimating()
        
        if shelfItem.show && bookCover != "" {
            switch bookSource {
            case .deviceCache, .deviceLibrary, .deviceDocuments:
                let paths = NSSearchPathForDirectoriesInDomains(bookSource.searchPathDirectory, .userDomainMask, true)
                if let dirPath = paths.first {
                    let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(bookCover)
                    let image = UIImage(contentsOfFile: imageURL.path)
                    cell.bookCover.image = image
                    cell.indicator.stopAnimating()
                    cell.spine.isHidden = false
                }
            case .url:
                let url = URL(string: bookCover)!
                cell.bookCover.kf.setImage(with: url, completionHandler:  { result in
                    cell.indicator.stopAnimating()
                    switch result {
                    case .success:
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                        cell.bookTitle.isHidden = true
                        cell.refresh.setImage(
                            Utils().loadImage(name: "icon-book-\(shelfItem.bookStatus.rawValue.lowercased())")?
                                .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .stretch),
                            for: .normal
                        )
                    case .failure(let error):
                        cell.spine.isHidden = true
                        cell.bookTitle.isHidden = false
                        cell.refresh.setImage(
                            Utils().loadImage(name: "icon-book-\(BookModel.BookStatus.NOCONNECT.rawValue.lowercased())")?
                                .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .stretch),
                            for: .normal
                        )
                        print("Error: \(error)")
                    }
                })
            case .raw:
                cell.bookCover.image = UIImage(named: bookCover)
                cell.indicator.stopAnimating()
                cell.spine.isHidden = false
            }
        }
        
        cell.bookBackground.isHidden = !shelfItem.show

        cell.refresh.setImage(
            Utils().loadImage(name: "icon-book-\(shelfItem.bookStatus.rawValue.lowercased())")?
                .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .stretch),
            for: .normal
        )

        if shelfItem.bookProgress >= 100 {
            cell.progress.text = "FIN"
        } else {
            cell.progress.text = "\(shelfItem.bookProgress)%"
        }
        
        cell.select.isSelected = self.selectedBookIds.contains(shelfItem.bookId)
        cell.select.isHidden = !collectionView.isEditing
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelfModelSection[0].sectionShelf.count
    }
    
    @objc func optionsActionPlain(sender: UIButton) {
        print("optionsActionPlain \(sender.tag)")
        let position = sender.tag
        let indexPath = IndexPath(row: position, section: 0)
        if let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView {
            let shelfItem = shelfModelSection[0].sectionShelf[indexPath.row]
            if shelfItem.show {
                let frameInSuperView = cell.convert(cell.options.frame, to: self)
                delegate.onBookOptionsClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
            }
        }
    }
    
    @objc func refreshActionSection(sender: UIButton) {
        print("refreshActionSection \(sender.tag)")
        let position = sender.tag
        let indexPath = IndexPath(row: position, section: 0)
        if let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView {
            let shelfItem = shelfModelSection[0].sectionShelf[indexPath.row]
            if shelfItem.show {
                let frameInSuperView = cell.convert(cell.options.frame, to: self)
                delegate.onBookRefreshClicked(self, index: indexPath.row, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
            }
        }
    }
}

extension PlainShelfView: UIGestureRecognizerDelegate {
}

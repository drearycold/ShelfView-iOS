//
//  SectionShelfView.swift
//  ShelfView
//
//  Created by Adeyinka Adediji on 27/12/2018.
//

import Kingfisher
import UIKit

public class SectionShelfView: ShelfView {
    private var bookModelSection = [BookModelSection]()
    private var optionsButtonTagMap = [Int:IndexPath]()
    
    private let layout = UICollectionViewFlowLayout()
    
    public weak var delegate: SectionShelfViewDelegate!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if Int(frame.width) < gridItemWidth {
            fatalError("ShelfView width cannot be less than \(gridItemWidth)")
        }
        initializeShelfView(width: frame.width, height: frame.height)
    }
    
    public convenience init(frame: CGRect, bookModelSection: [BookModelSection], bookSource: ShelfViewBookSource) {
        self.init(frame: frame)
        utils.delay(0) {
            self.bookSource = bookSource
            self.bookModelSection = bookModelSection
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
            layout.headerReferenceSize = CGSize(width: shelfView.frame.width, height: headerReferenceSizeHeight)
            shelfView.collectionViewLayout.invalidateLayout()
            reloadBooks(bookModelSection: bookModelSection)
        }
    }
    
    private func initializeShelfView(width: CGFloat, height: CGFloat) {
        shelfView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: layout)
        shelfView.register(ShelfCellView.self, forCellWithReuseIdentifier: ShelfCellView.identifier)
        shelfView.register(ShelfHeaderCellView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShelfHeaderCellView.identifier)
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
        
        addSubview(shelfView)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        shelfWidth = Int(shelfView.frame.width)
        shelfHeight = Int(shelfView.frame.height)
        numberOfTilesPerRow = shelfWidth / gridItemWidth
        trueGridItemWidth = Double(shelfWidth) / Double(numberOfTilesPerRow)
        
        layout.itemSize = CGSize(width: trueGridItemWidth, height: Double(gridItemHeight))
        layout.headerReferenceSize = CGSize(width: shelfView.frame.width, height: headerReferenceSizeHeight)
        shelfView.collectionViewLayout.invalidateLayout()
        
        buildSingleSectionShelf(sizeOfModel: 0)
        viewHasBeenInitialized = true
    }
    
    public func reloadBooks(bookModelSection: [BookModelSection]) {
        self.bookModelSection = bookModelSection
        processData()
    }
    
    public func addBooks(bookModelSection: [BookModelSection]) {
        self.bookModelSection = self.bookModelSection + bookModelSection
        processData()
    }
    
    private func processData() {
        shelfModelSection.removeAll()
        optionsButtonTagMap.removeAll(keepingCapacity: true)
        var cummulativeShelfHeight = 0
        
        for i in 0 ..< bookModelSection.count {
            let sectionItem = bookModelSection[i]
            let sectionName = sectionItem.sectionName
            let sectionId = sectionItem.sectionId
            let sectionBooks = sectionItem.sectionBooks
            let sectionBooksCount = sectionBooks.count
            var shelfModelArray = [ShelfModel]()
            
            for j in 0 ..< sectionBooksCount {
                var shelfModel = ShelfModel(
                    bookCoverSource: sectionBooks[j].bookCoverSource,
                    bookId: sectionBooks[j].bookId,
                    bookTitle: sectionBooks[j].bookTitle,
                    bookProgress: sectionBooks[j].bookProgress,
                    bookStatus: sectionBooks[j].bookStatus,
                    sectionId: sectionId,
                    show: true,
                    type: .center
                )
                
                if (j % numberOfTilesPerRow) == 0 {
                    shelfModel.type = .left
                } else if (j % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                    shelfModel.type = .right
                } else {
                    shelfModel.type = .center
                }
                shelfModelArray.append(shelfModel)
                
                if j == (sectionBooksCount - 1) {
                    var numberOfRows = sectionBooksCount / numberOfTilesPerRow
                    let remainderTiles = sectionBooksCount % numberOfTilesPerRow
                    
                    if remainderTiles > 0 {
                        numberOfRows = numberOfRows + 1
                        let fillUp = numberOfTilesPerRow - remainderTiles
                        for i in 0 ..< fillUp {
                            var shelfModel = ShelfModel()
                            if i == (fillUp - 1) {
                                shelfModel.type = .right
                            } else {
                                shelfModel.type = .center
                            }
                            shelfModelArray.append(shelfModel)
                        }
                    }
                    cummulativeShelfHeight += (numberOfRows * gridItemHeight) + Int(headerReferenceSizeHeight)
                }
            }
            
            if i == (bookModelSection.count - 1) {
                if cummulativeShelfHeight < shelfHeight {
                    let remainderRowHeight = (shelfHeight - cummulativeShelfHeight) / gridItemHeight
                    
                    if remainderRowHeight == 0 {
                        for i in 0 ..< numberOfTilesPerRow {
                            var shelfModel = ShelfModel()
                            if i == 0 {
                                shelfModel.type = .left
                            } else if i == (numberOfTilesPerRow - 1) {
                                shelfModel.type = .right
                            } else {
                                shelfModel.type = .center
                            }
                            shelfModelArray.append(shelfModel)
                        }
                    } else if remainderRowHeight > 0 {
                        let fillUp = numberOfTilesPerRow * (remainderRowHeight + 1)
                        for i in 0 ..< fillUp {
                            var shelfModel = ShelfModel()
                            if (i % numberOfTilesPerRow) == 0 {
                                shelfModel.type = .left
                            } else if (i % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                                shelfModel.type = .right
                            } else {
                                shelfModel.type = .center
                            }
                            shelfModelArray.append(shelfModel)
                        }
                    }
                }
            }
            
            shelfModelSection.append(ShelfModelSection(sectionName: sectionName, sectionId: sectionId, sectionShelf: shelfModelArray))
        }
        
        shelfView.reloadData()
    }
    
    private func buildSingleSectionShelf(sizeOfModel: Int) {
        var numberOfRows = sizeOfModel / numberOfTilesPerRow
        let remainderTiles = sizeOfModel % numberOfTilesPerRow
        var shelfModelArray = [ShelfModel]()
        
        if remainderTiles > 0 {
            numberOfRows = numberOfRows + 1
            let fillUp = numberOfTilesPerRow - remainderTiles
            for i in 0 ..< fillUp {
                var shelfModel = ShelfModel()
                if i == (fillUp - 1) {
                    shelfModel.type = .right
                } else {
                    shelfModel.type = .center
                }
                shelfModelArray.append(shelfModel)
            }
        }
        
        if ((numberOfRows * gridItemHeight) + Int(headerReferenceSizeHeight)) < shelfHeight {
            let remainderRowHeight = (shelfHeight - ((numberOfRows * gridItemHeight) + Int(headerReferenceSizeHeight))) / gridItemHeight
            
            if remainderRowHeight == 0 {
                for i in 0 ..< numberOfTilesPerRow {
                    var shelfModel = ShelfModel()
                    if i == 0 {
                        shelfModel.type = .left
                    } else if i == (numberOfTilesPerRow - 1) {
                        shelfModel.type = .right
                    } else {
                        shelfModel.type = .center
                    }
                    shelfModelArray.append(shelfModel)
                }
            } else if remainderRowHeight > 0 {
                let fillUp = numberOfTilesPerRow * (remainderRowHeight + 1)
                for i in 0 ..< fillUp {
                    var shelfModel = ShelfModel()
                    if (i % numberOfTilesPerRow) == 0 {
                        shelfModel.type = .left
                    } else if (i % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                        shelfModel.type = .right
                    } else {
                        shelfModel.type = .center
                    }
                    shelfModelArray.append(shelfModel)
                }
            }
        }
        
        shelfModelSection.append(ShelfModelSection(sectionName: "", sectionId: "", sectionShelf: shelfModelArray))
        shelfView.reloadData()
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer?) {
        guard let gesture = gesture, gesture.state == .began else { return }
        print("Long Pressed")
        let location = gesture.location(in: shelfView)
        if let indexPath = shelfView.indexPathForItem(at: location), let cell = shelfView.cellForItem(at: indexPath) {
            let sectionItem = shelfModelSection[indexPath.section]
            let shelfItem = sectionItem.sectionShelf[indexPath.item]
            if shelfItem.show {
                let frameInSuperView = shelfView.convert(cell.frame, to: self)
                delegate.onBookLongClicked(self, section: indexPath.section, index: indexPath.row, sectionId: sectionItem.sectionId, sectionTitle: sectionItem.sectionName, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
                
            }
        }
    }
}

extension SectionShelfView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let position = indexPath.row
        let shelfItem = shelfModelSection[section].sectionShelf[position]
        let bookCover = shelfItem.bookCoverSource.trim()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShelfCellView.identifier, for: indexPath) as! ShelfCellView
        cell.shelfBackground.frame = CGRect(x: 0, y: 0, width: trueGridItemWidth, height: Double(gridItemHeight))
        cell.shelfBackground.contentMode = .scaleToFill
        
        cell.shelfBackground.image = utils.loadImage(name: shelfItem.type.rawValue)
        
        cell.bookCover.kf.indicatorType = .none
        cell.bookBackground.frame = CGRect(x: (trueGridItemWidth - Dimens.bookWidth) / 2, y: bookBackgroundMarignTop, width: Dimens.bookWidth, height: Dimens.bookHeight)
        cell.bookCover.frame = CGRect(x: bookCoverMargin / 2, y: bookCoverMargin, width: Dimens.bookWidth - bookCoverMargin, height: Dimens.bookHeight - bookCoverMargin)
        cell.indicator.frame = CGRect(x: (Dimens.bookWidth - indicatorWidth) / 2, y: (Dimens.bookHeight - indicatorWidth) / 2, width: indicatorWidth, height: indicatorWidth)
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
                    switch result {
                    case .success:
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                    case .failure(let error):
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
        cell.spine.frame = CGRect(x: CGFloat(bookCoverMargin) / 2, y: CGFloat(bookCoverMargin), width: spineWidth, height: cell.bookCover.frame.height)
        
        let bookIdHash = shelfItem.bookId.hashValue
        optionsButtonTagMap[bookIdHash] = indexPath

        cell.options.frame = CGRect(x: cell.bookCover.frame.maxX - 48, y: cell.bookCover.frame.maxY - 36, width: 64, height: 32)
        cell.options.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.options.addTarget(self, action: #selector(optionsActionSection(sender:)), for: .touchUpInside)
        cell.options.tag = bookIdHash
        
        cell.refresh.frame = CGRect(x: cell.bookCover.frame.minX + 12, y: cell.bookCover.frame.maxY - 28, width: 20, height: 24)
        cell.refresh.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.refresh.addTarget(self, action: #selector(refreshActionSection(sender:)), for: .touchUpInside)
        cell.refresh.tag = bookIdHash

        cell.refresh.setImage(
            Utils().loadImage(name: "icon-book-\(shelfItem.bookStatus.rawValue.lowercased())")?
                .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .stretch),
            for: .normal)
        
        if shelfItem.bookProgress >= 100 {
            cell.progress.text = "FIN"
        } else {
            cell.progress.text = "\(shelfItem.bookProgress)%"
        }
        cell.progress.frame = CGRect(x: cell.bookCover.frame.maxX - 40, y: cell.bookCover.frame.minY + 4, width: 36, height: 24)

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShelfHeaderCellView.identifier, for: indexPath) as! ShelfHeaderCellView
            
            reusableView.header.frame = CGRect(x: 0, y: 0, width: reusableView.frame.width, height: reusableView.frame.height)
            reusableView.headerLabel.frame = CGRect(x: 0, y: 0, width: reusableView.frame.width, height: reusableView.frame.height)
            reusableView.headerLabel.text = shelfModelSection[indexPath.section].sectionName
            return reusableView
        }
        return UICollectionReusableView()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return shelfModelSection.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelfModelSection[section].sectionShelf.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let position = indexPath.row
        let sectionItem = shelfModelSection[section]
        let shelfItem = sectionItem.sectionShelf[position]
        if shelfItem.show {
            delegate.onBookClicked(self, section: section, index: position, sectionId: sectionItem.sectionId, sectionTitle: sectionItem.sectionName, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle)
        }
    }
    
    @objc func optionsActionSection(sender: UIButton) {
        guard let indexPath = optionsButtonTagMap[sender.tag] else { return }
        print("optionsActionSection \(indexPath)")
        if let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView {
            let sectionItem = shelfModelSection[indexPath.section]
            let shelfItem = sectionItem.sectionShelf[indexPath.item]
            if shelfItem.show {
                let frameInSuperView = cell.convert(cell.options.frame, to: self)
                
                delegate.onBookLongClicked(self, section: indexPath.section, index: indexPath.row, sectionId: sectionItem.sectionId, sectionTitle: sectionItem.sectionName, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
                
            }
        }
    }
    
    @objc func refreshActionSection(sender: UIButton) {
        guard let indexPath = optionsButtonTagMap[sender.tag] else { return }
        print("refreshActionSection \(indexPath)")
        if let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView {
            let sectionItem = shelfModelSection[indexPath.section]
            let shelfItem = sectionItem.sectionShelf[indexPath.item]
            if shelfItem.show {
                let frameInSuperView = cell.convert(cell.options.frame, to: self)
                delegate.onBookRefreshClicked(self, section: indexPath.section, index: indexPath.row, sectionId: sectionItem.sectionId, sectionTitle: sectionItem.sectionName, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle, frame: frameInSuperView)
            }
        }
    }
}
extension SectionShelfView: UIGestureRecognizerDelegate {
}

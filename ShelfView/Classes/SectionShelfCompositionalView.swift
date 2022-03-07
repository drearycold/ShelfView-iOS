//
//  SectionShelfCompositionalView.swift
//  ShelfView
//
//  Created by 京太郎 on 2022/2/27.
//  Created by Adeyinka Adediji on 27/12/2018.
//

import Kingfisher
import UIKit

public class SectionShelfCompositionalView: UIView {
    static let sectionHeaderElementKind = "section-header-element-kind"

    private let indicatorWidth = Double(50)
    private let bookCoverMargin = Double(10)
    private let spineWidth = CGFloat(8)
    private let bookBackgroundMarignTop = Double(23)
    private let headerReferenceSizeHeight = CGFloat(50)
    
    public static let BOOK_SOURCE_DEVICE_DOCUMENTS = 1
    public static let BOOK_SOURCE_DEVICE_LIBRARY = 2
    public static let BOOK_SOURCE_DEVICE_CACHE = 3
    public static let BOOK_SOURCE_URL = 4
    public static let BOOK_SOURCE_RAW = 5
    
    private static let START = "start"
    private static let END = "end"
    private static let CENTER = "center"
    
    private var bookModelSection = [BookModelSection]()
    private var shelfModelSection = [ShelfModelSection]()
    private var optionsButtonTagMap = [Int:IndexPath]()
    
    private var bookSource = BOOK_SOURCE_URL
    
    private var numberOfTilesPerRow: Int!
    private var numberOfRowsPerScreen: Int!
    private var shelfHeight: Int!
    private var shelfWidth: Int!
    private let gridItemWidth = Dimens.gridItemWidth
    private let gridItemHeight = Dimens.gridItemHeight
    private var shelfView: UICollectionView!
    private var shelfViewDataSource: UICollectionViewDiffableDataSource<ShelfModelSection, ShelfModel>! = nil

    private var trueGridItemWidth: Double!
    
    private let utils = Utils()
    public weak var delegate: SectionShelfCompositionalViewDelegate!
    private var viewHasBeenInitialized = false
    
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

            if shelfWidth % gridItemWidth > 0 {
                numberOfTilesPerRow += 1
            }

            numberOfRowsPerScreen = shelfHeight / gridItemHeight
            if shelfHeight % gridItemHeight > 0 {
                numberOfRowsPerScreen += 1
            }
//            layout.itemSize = CGSize(width: trueGridItemWidth, height: Double(gridItemHeight))
//            layout.headerReferenceSize = CGSize(width: shelfView.frame.width, height: headerReferenceSizeHeight)
            shelfView.collectionViewLayout.invalidateLayout()
            reloadBooks(bookModelSection: bookModelSection)
        }
    }
    
    private func initializeShelfView(width: CGFloat, height: CGFloat) {
        shelfView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: createLayout())
//        shelfView.register(ShelfCellView.self, forCellWithReuseIdentifier: ShelfCellView.identifier)
//        shelfView.register(ShelfHeaderCellView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ShelfHeaderCellView.identifier)
    
        //configure data source
        let cellRegistration = UICollectionView.CellRegistration<ShelfCellView, ShelfModel> { [self] cell, indexPath, item in
            let shelfItem = item
            let bookCover = shelfItem.bookCoverSource.trim()
            
            cell.shelfBackground.frame = CGRect(x: 0, y: 0, width: trueGridItemWidth, height: Double(gridItemHeight))
            cell.shelfBackground.contentMode = .scaleToFill
            
            switch shelfItem.type {
            case SectionShelfCompositionalView.START:
                cell.shelfBackground.image = utils.loadImage(name: "left")
                break
            case SectionShelfCompositionalView.END:
                cell.shelfBackground.image = utils.loadImage(name: "right")
                break
            default:
                cell.shelfBackground.image = utils.loadImage(name: "center")
                break
            }
            
            cell.bookCover.kf.indicatorType = .none
            cell.bookBackground.frame = CGRect(x: (trueGridItemWidth - Dimens.bookWidth) / 2, y: bookBackgroundMarignTop, width: Dimens.bookWidth, height: Dimens.bookHeight)
            cell.bookCover.frame = CGRect(x: bookCoverMargin / 2, y: bookCoverMargin, width: Dimens.bookWidth - bookCoverMargin, height: Dimens.bookHeight - bookCoverMargin)
            cell.indicator.frame = CGRect(x: (Dimens.bookWidth - indicatorWidth) / 2, y: (Dimens.bookHeight - indicatorWidth) / 2, width: indicatorWidth, height: indicatorWidth)
            cell.indicator.startAnimating()
            
            switch bookSource {
            case SectionShelfView.BOOK_SOURCE_DEVICE_CACHE:
                if shelfItem.show && bookCover != "" {
                    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
                    if let dirPath = paths.first {
                        let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(bookCover)
                        let image = UIImage(contentsOfFile: imageURL.path)
                        cell.bookCover.image = image
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                    }
                }
                break
            case SectionShelfView.BOOK_SOURCE_DEVICE_LIBRARY:
                if shelfItem.show && bookCover != "" {
                    let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
                    if let dirPath = paths.first {
                        let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(bookCover)
                        let image = UIImage(contentsOfFile: imageURL.path)
                        cell.bookCover.image = image
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                    }
                }
                break
            case SectionShelfView.BOOK_SOURCE_DEVICE_DOCUMENTS:
                if shelfItem.show && bookCover != "" {
                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    if let dirPath = paths.first {
                        let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(bookCover)
                        let image = UIImage(contentsOfFile: imageURL.path)
                        cell.bookCover.image = image
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                    }
                }
                break
            case SectionShelfView.BOOK_SOURCE_URL:
                if shelfItem.show && bookCover != "" {
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
                }
                break
            case SectionShelfView.BOOK_SOURCE_RAW:
                if shelfItem.show && bookCover != "" {
                    cell.bookCover.image = UIImage(named: bookCover)
                    cell.indicator.stopAnimating()
                    cell.spine.isHidden = false
                }
                break
            default:
                if shelfItem.show && bookCover != "" {
                    let url = URL(string: "https://www.packtpub.com/sites/default/files/cover_1.png")!
                    cell.bookCover.kf.setImage(with: url, completionHandler: { result in
                        switch result {
                        case .success:
                            cell.indicator.stopAnimating()
                            cell.spine.isHidden = false
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    })
                }
                break
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

        }
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <ShelfHeaderCellView>(elementKind: SectionShelfCompositionalView.sectionHeaderElementKind) {
            header, elementKind, indexPath in
            header.header.frame = CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height)
            header.headerLabel.frame = CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height)
            header.headerLabel.text = self.shelfModelSection[indexPath.section].sectionName
        }
        shelfViewDataSource = UICollectionViewDiffableDataSource<ShelfModelSection, ShelfModel>(collectionView: shelfView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ShelfModel) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        shelfViewDataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.shelfView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: index)
        }
        shelfView.dataSource = shelfViewDataSource
        
        
//        shelfView.dataSource = self
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
        
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        shelfWidth = Int(shelfView.frame.width)
        shelfHeight = Int(shelfView.frame.height)
        numberOfTilesPerRow = shelfWidth / gridItemWidth
        trueGridItemWidth = Double(shelfWidth) / Double(numberOfTilesPerRow)
        
//        layout.itemSize = CGSize(width: trueGridItemWidth, height: Double(gridItemHeight))
//        layout.headerReferenceSize = CGSize(width: shelfView.frame.width, height: headerReferenceSizeHeight)
        shelfView.collectionViewLayout.invalidateLayout()
        
        buildSingleSectionShelf(sizeOfModel: 0)
        
        
        viewHasBeenInitialized = true
    }
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(CGFloat(Dimens.gridItemHeight))
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(CGFloat(self.trueGridItemWidth)),
                    heightDimension: .absolute(CGFloat(Dimens.gridItemHeight))
                ),
                subitems: [item]
            )
            group.interItemSpacing = .fixed(0.0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .estimated(32))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SectionShelfCompositionalView.sectionHeaderElementKind, alignment: .top)
            
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }
        
        return layout
    }
    public func reloadBooks(bookModelSection: [BookModelSection]) {
        self.bookModelSection = bookModelSection
        
        shelfModelSection.removeAll()
        optionsButtonTagMap.removeAll(keepingCapacity: true)
        
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
                    type: ""
                )
                
                if j == 0 {
                    shelfModel.type = SectionShelfCompositionalView.START
                } else if j == sectionBooksCount - 1 {
                    shelfModel.type = SectionShelfCompositionalView.END
                } else {
                    shelfModel.type = SectionShelfCompositionalView.CENTER
                }
                shelfModelArray.append(shelfModel)
                
//                if j == (sectionBooksCount - 1) {
//                    var numberOfRows = sectionBooksCount / numberOfTilesPerRow
//                    let remainderTiles = sectionBooksCount % numberOfTilesPerRow
//
//                    if remainderTiles > 0 {
//                        numberOfRows = numberOfRows + 1
//                        let fillUp = numberOfTilesPerRow - remainderTiles
//                        for i in 0 ..< fillUp {
//                            var shelfModel = ShelfModel()
//                            if i == (fillUp - 1) {
//                                shelfModel.type = SectionShelfCompositionalView.END
//                            } else {
//                                shelfModel.type = SectionShelfCompositionalView.CENTER
//                            }
//                            shelfModelArray.append(shelfModel)
//                        }
//                    }
//                    cummulativeShelfHeight += (numberOfRows * gridItemHeight) + Int(headerReferenceSizeHeight)
//                }
            }
            
            let cummulativeShelfHeight = (bookModelSection.count * gridItemHeight) + Int(headerReferenceSizeHeight)

            if i == (bookModelSection.count - 1) {
                if cummulativeShelfHeight < shelfHeight {
                    let remainderRowHeight = (shelfHeight - cummulativeShelfHeight) / gridItemHeight
                    
                    if remainderRowHeight == 0 {
                        for i in 0 ..< numberOfTilesPerRow {
                            var shelfModel = ShelfModel()
                            if i == 0 {
                                shelfModel.type = SectionShelfCompositionalView.START
                            } else if i == (numberOfTilesPerRow - 1) {
                                shelfModel.type = SectionShelfCompositionalView.END
                            } else {
                                shelfModel.type = SectionShelfCompositionalView.CENTER
                            }
                            shelfModel.sectionId = sectionId
                            shelfModel.bookId = "remainder-\(i)"
                            shelfModelArray.append(shelfModel)
                        }
                    } else if remainderRowHeight > 0 {
                        let fillUp = numberOfTilesPerRow * (remainderRowHeight + 1)
                        for i in 0 ..< fillUp {
                            var shelfModel = ShelfModel()
                            if (i % numberOfTilesPerRow) == 0 {
                                shelfModel.type = SectionShelfCompositionalView.START
                            } else if (i % numberOfTilesPerRow) == (numberOfTilesPerRow - 1) {
                                shelfModel.type = SectionShelfCompositionalView.END
                            } else {
                                shelfModel.type = SectionShelfCompositionalView.CENTER
                            }
                            shelfModel.sectionId = sectionId
                            shelfModel.bookId = "remainder-\(i)"
                            shelfModelArray.append(shelfModel)
                        }
                    }
                }
            }
            
            shelfModelSection.append(ShelfModelSection(sectionName: sectionName, sectionId: sectionId, sectionShelf: shelfModelArray))
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<ShelfModelSection, ShelfModel>()
        shelfModelSection.forEach { section in
            snapshot.appendSections([section])
            print("snapshot.appendItems(section.sectionShelf) \(section.sectionShelf)")
            snapshot.appendItems(section.sectionShelf)
        }
        shelfViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func buildSingleSectionShelf(sizeOfModel: Int) {
        for row in 0..<(numberOfRowsPerScreen ?? 9) {
            var shelfModelArray = [ShelfModel]()

            let fillUp = numberOfTilesPerRow ?? 9
            for i in 0 ..< fillUp {
                var shelfModel = ShelfModel()
                if i == 0 {
                    shelfModel.type = SectionShelfCompositionalView.START
                } else if i == (fillUp - 1) {
                    shelfModel.type = SectionShelfCompositionalView.END
                } else {
                    shelfModel.type = SectionShelfCompositionalView.CENTER
                }
                shelfModel.bookId = "row-\(row)-\(i)"
                shelfModelArray.append(shelfModel)
            }
            shelfModelSection.append(ShelfModelSection(sectionName: "", sectionId: "section-\(row)", sectionShelf: shelfModelArray))
        }
        
//        shelfView.reloadData()
        var snapshot = NSDiffableDataSourceSnapshot<ShelfModelSection, ShelfModel>()
        shelfModelSection.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.sectionShelf)
        }
        shelfViewDataSource.apply(snapshot, animatingDifferences: true)
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

extension SectionShelfCompositionalView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
extension SectionShelfCompositionalView: UIGestureRecognizerDelegate {
}

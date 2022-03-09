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
    
    private var shelfModelSection = [ShelfModelSection]()
    private var shelfSectionItemWidth = [Double]()
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
    
    private func updateGeo() {
        let width = frame.width
        let height = frame.height
        shelfView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        shelfWidth = Int(shelfView.frame.width)
        shelfHeight = Int(shelfView.frame.height)

        numberOfTilesPerRow = shelfWidth / gridItemWidth
        trueGridItemWidth = Double(gridItemWidth + Dimens.gridSpacing)

        if shelfWidth % gridItemWidth > 0 {
            numberOfTilesPerRow += 1
        }

        numberOfRowsPerScreen = shelfHeight / gridItemHeight
        if shelfHeight % gridItemHeight > 0 {
            numberOfRowsPerScreen += 1
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if viewHasBeenInitialized {
            updateGeo()
            shelfView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public func resize(to size: CGSize) {
        if viewHasBeenInitialized {
            updateGeo()
            
            for sectionIndex in 0..<min(shelfSectionItemWidth.count, shelfModelSection.count) {
                if self.shelfModelSection[sectionIndex].sectionShelf.count * Int(self.trueGridItemWidth ?? 0) < self.shelfWidth {
                    self.shelfSectionItemWidth[sectionIndex] = Double(self.shelfWidth) / Double(self.shelfModelSection[sectionIndex].sectionShelf.count)
                }
            }
            
            shelfView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func initializeShelfView(width: CGFloat, height: CGFloat) {
        shelfView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: createLayout())
    
        //configure data source
        let cellRegistration = UICollectionView.CellRegistration<ShelfCellView, ShelfModel> { [self] cell, indexPath, item in
            let shelfItem = item
            let bookCover = shelfItem.bookCoverSource.trim()
            
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
            
            let bookIdHash = shelfItem.bookId.hashValue
            optionsButtonTagMap[bookIdHash] = indexPath

            cell.options.removeTarget(nil, action: nil, for: .touchUpInside)
            cell.options.addTarget(self, action: #selector(optionsActionSection(sender:)), for: .touchUpInside)
            cell.options.tag = bookIdHash
            
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

        }
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <ShelfHeaderCellView>(elementKind: SectionShelfCompositionalView.sectionHeaderElementKind) {
            header, elementKind, indexPath in
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
        
        shelfWidth = Int(shelfView.frame.width)
        shelfHeight = Int(shelfView.frame.height)
        numberOfTilesPerRow = shelfWidth / gridItemWidth
        trueGridItemWidth = Double(gridItemWidth + Dimens.gridSpacing)
        
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
            
            var itemWidth = self.trueGridItemWidth ?? 0
            if sectionIndex < self.shelfModelSection.count,
               self.shelfModelSection[sectionIndex].sectionShelf.count * Int(itemWidth) < self.shelfWidth {
                itemWidth = Double(self.shelfWidth) / Double(self.shelfModelSection[sectionIndex].sectionShelf.count)
            }
            self.shelfSectionItemWidth[sectionIndex] = itemWidth
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(CGFloat(itemWidth)),
                    heightDimension: .absolute(CGFloat(Dimens.gridItemHeight))
                ),
                subitems: [item]
            )
            group.interItemSpacing = .fixed(0.0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .absolute(32))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: SectionShelfCompositionalView.sectionHeaderElementKind, alignment: .top)
            
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }
        
        return layout
    }
    public func reloadBooks(bookModelSection: [ShelfModelSection]) {
        if shelfSectionItemWidth.count < bookModelSection.count {
            shelfSectionItemWidth.append(contentsOf: Array<Double>(repeating: 0.0, count: bookModelSection.count - shelfSectionItemWidth.count))
        }
        shelfModelSection = bookModelSection
        for i in 0..<shelfModelSection.count {
            shelfModelSection[i].sectionShelf[0].type = SectionShelfCompositionalView.START
            if shelfModelSection[i].sectionShelf.count > 0 {
                shelfModelSection[i].sectionShelf[shelfModelSection[i].sectionShelf.count - 1].type = SectionShelfCompositionalView.END
            }
        }
        
        optionsButtonTagMap.removeAll(keepingCapacity: true)
        
        var snapshot = NSDiffableDataSourceSnapshot<ShelfModelSection, ShelfModel>()

        shelfModelSection.forEach { section in
            snapshot.appendSections([ShelfModelSection(sectionName: section.sectionName, sectionId: section.sectionId, sectionShelf: [])])
            snapshot.appendItems(section.sectionShelf)
        }
        shelfViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func buildSingleSectionShelf(sizeOfModel: Int) {
        let rows = numberOfRowsPerScreen ?? 9
        for row in 0..<(rows) {
            var shelfModelArray = [ShelfModel]()

            let fillUp = rows
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
        shelfSectionItemWidth.append(contentsOf: Array<Double>(repeating: 0.0, count: rows))
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

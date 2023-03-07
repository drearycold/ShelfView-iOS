//
//  SectionShelfCompositionalView.swift
//  ShelfView
//
//  Created by 京太郎 on 2022/2/27.
//  Created by Adeyinka Adediji on 27/12/2018.
//

import Kingfisher
import UIKit

@available(iOS 15.0, *)
public class SectionShelfCompositionalView: ShelfView {
    private var shelfViewDataSource: UICollectionViewDiffableDataSource<ShelfModelSection, ShelfModel>! = nil

    public weak var delegate: SectionShelfCompositionalViewDelegate!
    
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
            
            shelfView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func initializeShelfView(width: CGFloat, height: CGFloat) {
        shelfView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: createLayout())
    
        //configure data source
        let cellRegistration = UICollectionView.CellRegistration<ShelfCellView, ShelfModel> { [self] cell, indexPath, item in
            let shelfItem = item
            let bookCover = shelfItem.bookCoverSource.trim()
            
            cell.shelfBackground.image = utils.loadImage(name: shelfItem.type.rawValue)
            cell.bookTitle.text = shelfItem.bookTitle

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
                    if shelfItem.show && bookCover != "" {
                        let url = URL(string: bookCover)!
                        cell.bookCover.kf.setImage(with: url, completionHandler:  { result in
                            cell.indicator.stopAnimating()
                            switch result {
                            case .success:
                                cell.spine.isHidden = false
                                cell.bookTitle.isHidden = true
                            case .failure(let error):
                                cell.spine.isHidden = true
                                cell.bookTitle.isHidden = false
                                print("Error: \(error)")
                            }
                        })
                    }
                case .raw:
                    if shelfItem.show && bookCover != "" {
                        cell.bookCover.image = UIImage(named: bookCover)
                        cell.indicator.stopAnimating()
                        cell.spine.isHidden = false
                    }
                }
            }
            
            cell.bookBackground.isHidden = !shelfItem.show
            
            cell.refresh.setImage(
                Utils().loadImage(name: "icon-book-\(shelfItem.bookStatus.rawValue.lowercased())")?
                    .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .stretch),
                for: .normal)
            
            if shelfItem.bookProgress >= 100 {
                cell.progress.text = "FIN"
            } else {
                cell.progress.text = "\(shelfItem.bookProgress)%"
            }
            
            cell.refresh.isHidden = true
            cell.progress.isHidden = shelfItem.bookProgress == 0
            cell.options.isHidden = true
            
            cell.select.isSelected = self.selectedBookIds.contains(shelfItem.bookId)
            cell.select.isHidden = !self.shelfView.isEditing
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <ShelfHeaderCellView>(elementKind: SectionShelfCompositionalView.sectionHeaderElementKind) {
            header, elementKind, indexPath in
            header.headerLabel.text = self.shelfViewDataSource.sectionIdentifier(for: indexPath.section)?.sectionName
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
        
        updateGeo()
        
        shelfView.collectionViewLayout.invalidateLayout()
        
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
            if sectionIndex < self.shelfViewDataSource.numberOfSections(in: self.shelfView),
               self.shelfViewDataSource.collectionView(self.shelfView, numberOfItemsInSection: sectionIndex) * Int(itemWidth) < self.shelfWidth {
                itemWidth = Double(self.shelfWidth) / Double(self.shelfViewDataSource.collectionView(self.shelfView, numberOfItemsInSection: sectionIndex))
            }
            
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
        shelfModelSection = bookModelSection

        buildShelf()

        for i in 0..<shelfModelSection.count {
            shelfModelSection[i].sectionShelf[0].type = .left
            shelfModelSection[i].sectionShelf[shelfModelSection[i].sectionShelf.count - 1].type = .right
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<ShelfModelSection, ShelfModel>()

        shelfModelSection.forEach { section in
            snapshot.appendSections([ShelfModelSection(sectionName: section.sectionName, sectionId: section.sectionId, sectionShelf: [])])
            snapshot.appendItems(section.sectionShelf)
        }
        
        shelfViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func buildShelf() {
        guard shelfModelSection.count < numberOfRowsPerScreen ?? 9 else { return }
        
        (shelfModelSection.count..<(numberOfRowsPerScreen ?? 9)).forEach { row in
            shelfModelSection.append(
                ShelfModelSection(
                    sectionName: "",
                    sectionId: "section-\(row)",
                    sectionShelf: (0 ..< (numberOfTilesPerRow ?? 9)).map {
                        var shelfModel = ShelfModel()
                        shelfModel.type = .center
                        shelfModel.bookId = "row-\(row)-\($0)"
                        return shelfModel
                    }
                )
            )
        }
    }
    
    public func applyDataSourceSnapshot(snapshot: NSDiffableDataSourceSnapshot<ShelfModelSection, ShelfModel>) {
        shelfViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer?) {
        guard let gesture = gesture, gesture.state == .began else { return }
        print("Long Pressed")
        let location = gesture.location(in: shelfView)
        
        guard let indexPath = shelfView.indexPathForItem(at: location),
           let cell = shelfView.cellForItem(at: indexPath),
           let sectionItem = self.shelfViewDataSource.sectionIdentifier(for: indexPath.section),
           let shelfItem = self.shelfViewDataSource.itemIdentifier(for: indexPath),
           shelfItem.show
        else {
            return
        }
               
        let frameInSuperView = shelfView.convert(cell.frame, to: self)
        delegate.onBookLongClicked(
            self,
            section: indexPath.section,
            index: indexPath.row,
            sectionId: sectionItem.sectionId,
            sectionTitle: sectionItem.sectionName,
            bookId: shelfItem.bookId,
            bookTitle: shelfItem.bookTitle,
            frame: frameInSuperView
        )
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer?) {
        guard let gesture = gesture, gesture.state == .ended else { return }
        print("Tap")
        
        let location = gesture.location(in: shelfView)
        
        guard let indexPath = shelfView.indexPathForItem(at: location),
              let cell = shelfView.cellForItem(at: indexPath) as? ShelfCellView,
              let sectionItem = self.shelfViewDataSource.sectionIdentifier(for: indexPath.section),
              let shelfItem = self.shelfViewDataSource.itemIdentifier(for: indexPath),
              shelfItem.show
        else {
            return
        }
        
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
        
        if locationInCover.x > 0,
           locationInCover.x < cell.bookCover.frame.width,
           locationInCover.y > 0,
           locationInCover.y < cell.bookCover.frame.height {
            delegate.onBookClicked(self, section: indexPath.section, index: indexPath.row, sectionId: sectionItem.sectionId, sectionTitle: sectionItem.sectionName, bookId: shelfItem.bookId, bookTitle: shelfItem.bookTitle)
            return
        }
    }
}

@available(iOS 15.0, *)
extension SectionShelfCompositionalView: UIGestureRecognizerDelegate {
}

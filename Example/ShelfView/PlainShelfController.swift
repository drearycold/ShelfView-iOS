//
//  PlainShelfController.swift
//  ShelfView
//
//  Created by tdscientist on 09/23/2017.
//  Copyright (c) 2017 tdscientist. All rights reserved.
//

import ShelfView

class PlainShelfController: UIViewController, PlainShelfViewDelegate {
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    var bookModel = [BookModel]()
    var shelfView: PlainShelfView!
    var recentLongPressedIndex = 0
    override var canBecomeFirstResponder: Bool {
        true
    }
    @IBOutlet var motherView: UIView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shelfView.translatesAutoresizingMaskIntoConstraints = false
        shelfView.leftAnchor.constraint(equalTo: motherView.leftAnchor, constant: 0).isActive = true
        shelfView.rightAnchor.constraint(equalTo: motherView.rightAnchor, constant: 0).isActive = true
        shelfView.topAnchor.constraint(equalTo: motherView.topAnchor, constant: 0).isActive = true
        shelfView.bottomAnchor.constraint(equalTo: motherView.bottomAnchor, constant: 0).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bookModel.append(BookModel(bookCoverSource: "http://www.aidanf.net/images/learn-swift/cover-web.png", bookId: "0", bookTitle: "Learn Swift", bookProgress: 10))
        bookModel.append(BookModel(bookCoverSource: "https://images-na.ssl-images-amazon.com/images/I/41bUdNhz6pL._SX346_BO1,204,203,200_.jpg", bookId: "1", bookTitle: "Beginning iOS", bookProgress: 20))
        bookModel.append(BookModel(bookCoverSource: "https://www.packtpub.com/sites/default/files/1414OS_5764_Mastering%20Swift%203%20-%20Linux.jpg", bookId: "2", bookTitle: "Mastering Swift 3 - Linux", bookProgress: 30))
        bookModel.append(BookModel(bookCoverSource: "https://files.kerching.raywenderlich.com/uploads/c7f72825-5849-4d76-ba21-8d9486296119.png", bookId: "3", bookTitle: "iOS Apprentice", bookProgress: 40))

        shelfView = PlainShelfView(frame: CGRect(x: 0, y: statusBarHeight, width: 350, height: 500), bookModel: bookModel, bookSource: PlainShelfView.BOOK_SOURCE_URL)

        delay(3) {
            let books = [
                BookModel(bookCoverSource: "https://www.packtpub.com/sites/default/files/5723cov_.png", bookId: "4", bookTitle: "Learning Xcode 8", bookProgress: 50),
                BookModel(bookCoverSource: "https://files.kerching.raywenderlich.com/uploads/bc41c949-c745-455e-8922-1b196fcf5e80.png", bookId: "5", bookTitle: "iOS Animations", bookProgress: 55),
                BookModel(bookCoverSource: "http://www.appsmith.dk/wp-content/uploads/2014/12/cover-small.jpg", bookId: "6", bookTitle: "Beginning iOS Development", bookProgress: 60)
            ]
            self.shelfView.addBooks(bookModel: books)
        }

        delay(5) {
            let books = [
                BookModel(bookCoverSource: "https://codewithchris.com/img/SwiftCourseThumbnail_v2.jpg", bookId: "7", bookTitle: "How To Make iPhone Apps", bookProgress: 70),
                BookModel(bookCoverSource: "http://whatpixel.com/images/2016/08/learning-swift-book-cover.jpg", bookId: "8", bookTitle: "Learning Swift", bookProgress: 75),
                BookModel(bookCoverSource: "https://www.packtpub.com/sites/default/files/9781785288197.png", bookId: "9", bookTitle: "Learning iOS UI Development", bookProgress: 80)
            ]
            self.shelfView.addBooks(bookModel: books)
        }

        shelfView.delegate = self
        motherView.addSubview(shelfView)
    }

    func onBookClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String) {
        print("I just clicked \"\(bookTitle)\" with bookId \(bookId), at index \(index)")
    }

    func onBookLongClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect) {
        print("I just clicked longer \"\(bookTitle)\" with bookId \(bookId), at index \(index)")
        
        recentLongPressedIndex = index
        let sampleMenuItem = UIMenuItem(title: "SAMPLE", action: #selector(onBookLongClickedSampleMenuItem(_:)))
        UIMenuController.shared.menuItems = [sampleMenuItem]
        UIMenuController.shared.setTargetRect(inShelfView, in: shelfView)
        becomeFirstResponder()
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    @objc func onBookLongClickedSampleMenuItem(_ sender: Any?) {
        print("I just clicked longer menuitem at index \(recentLongPressedIndex)")
    }
    
    func onBookOptionsClicked(_ shelfView: PlainShelfView, index: Int, bookId: String, bookTitle: String, frame inShelfView: CGRect) {
        print("I just clicked options \"\(bookTitle)\" with bookId \(bookId), at index \(index)")
        
        let sampleMenuItem = UIMenuItem(title: "SAMPLE", action: #selector(onBookLongClickedSampleMenuItem(_:)))
        UIMenuController.shared.menuItems = [sampleMenuItem]
        UIMenuController.shared.setTargetRect(inShelfView, in: shelfView)
        becomeFirstResponder()
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}

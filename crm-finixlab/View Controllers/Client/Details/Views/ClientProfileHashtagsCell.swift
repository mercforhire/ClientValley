//
//  ClientProfileHashtagsCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-13.
//

import UIKit

class ClientProfileHashtagsCell: UITableViewCell {
    private var observer: NSObjectProtocol?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightBar: NSLayoutConstraint!
    
    var tags: [String] = [] {
        didSet {
            collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                
                let height: CGFloat = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                self.heightBar.constant = height
                self.setNeedsLayout()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "TagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TagCell")
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 0.0, bottom: 0, right: 0.0)
        bubbleLayout.delegate = self
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
        
        selectionStyle = .none
        
        setupUI()
    }

    func setupUI() {
        collectionView.reloadData()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupUI()
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(tags: [String]) {
        self.tags = tags
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}

extension ClientProfileHashtagsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configureUIAlternate(overrideFontSize: 13.0)
        let tag = tags[indexPath.row]
        cell.lblTitle.text = "#\(tag)"
        return cell
    }
}

extension ClientProfileHashtagsCell: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        guard let themeData = ThemeManager.shared.themeData?.hashTheme else { return .zero }
        
        let title = "#\(tags[indexPath.row])"
        var size = title.size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont(overrideSize: 13.0)!])
        size.width = CGFloat(ceilf(Float(12.0 + size.width + 12.0)))
        size.height = 24.0
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}

//
//  HashtagAddViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-11.
//

import UIKit

protocol HashtagAddViewControllerDelegate: class {
    func addedTag(newTag: String)
}

class HashtagAddViewController: BaseScrollingViewController {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var newtagField: ThemeTextField!
    @IBOutlet weak var hashtagCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    weak var delegate: HashtagAddViewControllerDelegate?
    
    var historyTags: [String] = [] {
        didSet {
            guard hashtagCollectionView != nil else { return }
            
            hashtagCollectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.collectionViewHeight.constant = self?.hashtagCollectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
            }
        }
    }
    
    static func create(historyTags: [String], delegate: HashtagAddViewControllerDelegate) -> UIViewController {
        let vc = StoryboardManager.loadViewController(storyboard: "Misc", viewControllerId: "HashtagAddViewController") as! HashtagAddViewController
        vc.historyTags = historyTags
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
    
    override func setup() {
        super.setup()
  
        hashtagCollectionView.register(UINib(nibName: "TagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TagCell")
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 0.0, bottom: 0, right: 0.0)
        bubbleLayout.delegate = self
        hashtagCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        guard let theme = themeManager.themeData?.navBarTheme, let theme2 = themeManager.themeData?.secondaryButtonTheme else { return }
        
        backButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        addButton.setTitleTextAttributes([.font: theme.barButton.font.toFont()!,
                                           .foregroundColor: UIColor.fromRGBString(rgbString: theme2.textColor)!],
                                          for: .normal)
        
        setupNavBarTheme()
    }
    
    private func setupNavBarTheme() {
        guard let theme = themeManager.themeData?.countryPickerTheme, let viewColor = themeManager.themeData?.viewColor else { return }
        
        navigationController?.navigationBar.backgroundColor = UIColor.fromRGBString(rgbString: viewColor)
        navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.fromRGBString(rgbString: theme.title.textColor)!,
             .font: theme.title.font.toFont()!]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
        setupNavBarTheme()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        guard !(newtagField.text?.isEmpty ?? true) else { return }
        
        delegate?.addedTag(newTag: newtagField.text!.replacingOccurrences(of: "#", with: ""))
        backPressed(backButton)
    }
}

extension HashtagAddViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        let tag = historyTags[indexPath.row]
        cell.configureUI()
        cell.lblTitle.text = "#\(tag)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = historyTags[indexPath.row]
        newtagField.text = "#\(tag)"
    }
}

extension HashtagAddViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return .zero }
        
        let title = "#\(historyTags[indexPath.row])"
        var size = title.size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont()!])
        size.width = CGFloat(ceilf(Float(12.0 + size.width + 12.0)))
        size.height = 30
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}

extension HashtagAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        addButton.isEnabled = !(textField.text?.isEmpty ?? false)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = simpleInputToolbar
        return true
    }
}

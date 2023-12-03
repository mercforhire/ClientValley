//
//  ClientAddStep2ViewController.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-10.
//

import UIKit
import GrowingTextView
import FMPhotoPicker
import RealmSwift

class ClientAddStep2ViewController: BaseScrollingViewController {
    private var tempClient: TempClient! {
        didSet {
            if let avatarData = tempClient.avatar,
               let avatar = UIImage(data: avatarData) {
                image = avatar
            }
            notesTextView.text = tempClient.metadata?.notes
            refreshHashtagCollectionView()
        }
    }
    private var userSettings: UserSettings!
    private var notificationToken: NotificationToken?
    
    @IBOutlet weak var backButton: ThemeBarButton!
    @IBOutlet weak var quitButton: ThemeBarButton!
    
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var notesTextView: GrowingTextView!
    @IBOutlet weak var hashtagCollectionView: UICollectionView!
    @IBOutlet weak var heightBar: NSLayoutConstraint!
    
    private lazy var myCamera = UIImagePickerController()
    
    var image: UIImage? {
        didSet {
            if image == nil {
                let config = AvatarImageConfiguration(image: nil, name: tempClient?.initials)
                avatar.config(configuration: config)
                
                do {
                    try realm.write {
                        tempClient?.avatar = nil
                    }
                } catch(let error) {
                    print("image changed: \(error.localizedDescription)")
                }
            } else {
                let config = AvatarImageConfiguration(image: image, name: "")
                avatar.config(configuration: config)
                
                do {
                    try realm.write {
                        tempClient?.avatar = image!.pngData()
                    }
                } catch(let error) {
                    print("image changed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func setup() {
        super.setup()

        notesTextView.text = ""
        hashtagCollectionView.register(UINib(nibName: "HashTagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HashTagCell")
        hashtagCollectionView.register(UINib(nibName: "AddTagCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AddTagCell")
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10.0
        bubbleLayout.minimumInteritemSpacing = 10.0
        bubbleLayout.sectionInset = .init(top: 0, left: 0.0, bottom: 0, right: 0.0)
        bubbleLayout.delegate = self
        hashtagCollectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        hashtagCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
    
    @IBAction func photoButtonPress(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera), UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera) != nil {
                self.myCamera.sourceType = .camera
                self.myCamera.cameraDevice = .rear
                self.myCamera.delegate = self
                self.myCamera.showsCameraControls = true
                self.myCamera.allowsEditing = true
                self.present(self.myCamera, animated: false, completion: nil)
            }  else {
                showErrorDialog(error: "No camera device found.")
            }
        }
        ac.addAction(cameraAction)
        
        let pickerAction = UIAlertAction(title: "Library", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            let picker = FMPhotoPickerViewController(config: self.photoPickerConfig())
            picker.delegate = self
            self.present(picker, animated: true)
        }
        ac.addAction(pickerAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @IBAction func nextPress(_ sender: UIButton) {
        
    }
    
    @objc private func deleteTagPressed(_ sender: UIButton) {
        guard let tempClient = tempClient else { return }
        
        do {
            try realm.write {
                tempClient.metadata?.hashtags.remove(at: sender.tag)
            }
        } catch(let error) {
            print("deleteTagPressed: \(error.localizedDescription)")
        }
    }
    
    @objc private func addTagPressed(_ sender: UIButton) {
        let vc = HashtagAddViewController.create(historyTags: userSettings?.historyHashtags.sorted() ?? [], delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    private func refreshHashtagCollectionView() {
        hashtagCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            let height: CGFloat = self.hashtagCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.heightBar.constant = height
        }
    }
    
    override func setupRealm() {
        super.setupRealm()
        
        if realm.objects(TempClient.self).isEmpty {
            tempClient = TempClient(partition: UserManager.shared.userPartitionKey)
            do {
                try realm.write {
                    realm.add(tempClient)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            tempClient = realm.objects(TempClient.self).first
        }
        
        if realm.objects(UserSettings.self).isEmpty {
            userSettings = UserSettings(partition: UserManager.shared.userPartitionKey)
            
            do {
                try realm.write {
                    realm.add(userSettings)
                }
            } catch(let error) {
                print("setupRealm \(error.localizedDescription)")
            }
        } else {
            userSettings = realm.objects(UserSettings.self).first
        }
        
        notificationToken = tempClient?.metadata?.hashtags.observe({ [weak self] changes in
            switch changes {
            case .update:
                self?.refreshHashtagCollectionView()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            default:
                break
            }
        })
    }
}

extension ClientAddStep2ViewController: HashtagAddViewControllerDelegate {
    func addedTag(newTag: String) {
        guard let tempClient = tempClient, let metadata = tempClient.metadata else { return }
        
        if metadata.hashtags.filter({ subject in
            return subject == newTag
        }).isEmpty {
            do {
                try realm.write {
                    metadata.hashtags.append(newTag)
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
        
        // add to history
        guard let userSettings = userSettings else { return }
        
//        for tag in userSettings.historyHashtags {
//            if tag.contains(string: "#") {
//                do {
//                    try realm.write {
//                        userSettings.historyHashtags.remove(at: userSettings.historyHashtags.index(of: tag)!)
//                    }
//                } catch(let error) {
//                    print("addedTag: \(error.localizedDescription)")
//                }
//            }
//        }
        
        if userSettings.historyHashtags.filter({ subject in
            return subject == newTag
        }).isEmpty {
            do {
                try realm.write {
                    userSettings.historyHashtags.append(newTag)
                }
            } catch(let error) {
                print("addedTag: \(error.localizedDescription)")
            }
        }
    }
}

extension ClientAddStep2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else { return }
            
            self?.image = image.resizeImage(100, opaque: true)
        }
    }
}

extension ClientAddStep2ViewController: FMPhotoPickerViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        image = photo.resizeImage(100, opaque: true)
        dismiss(animated: true, completion: nil)
    }
    
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        guard let photo = photos.first else { return }
        
        image = photo.resizeImage(100, opaque: true)
        dismiss(animated: true, completion: nil)
    }
}

extension ClientAddStep2ViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = simpleInputToolbar
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let tempClient = tempClient else { return }
        
        do {
            try realm.write {
                tempClient.metadata?.notes = textView.text
            }
        } catch(let error) {
            print("addedTag: \(error.localizedDescription)")
        }
    }
}

extension ClientAddStep2ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (tempClient.metadata?.hashtags.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < (tempClient.metadata?.hashtags.count ?? 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCell", for: indexPath) as! HashTagCell
            let tag = tempClient.metadata?.hashtags[indexPath.row] ?? "tag"
            cell.lblTitle.text = "#\(tag)"
            cell.rightArrow.tag = indexPath.row
            cell.rightArrow.addTarget(self, action: #selector(deleteTagPressed(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTagCell", for: indexPath) as! AddTagCell
            cell.rightArrow.addTarget(self, action: #selector(addTagPressed(_:)), for: .touchUpInside)
            return cell
        }
    }
}

extension ClientAddStep2ViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < (tempClient.metadata?.hashtags.count ?? 0) {
            guard let themeData = themeManager.themeData?.hashTheme else { return .zero }
            
            let tag = tempClient.metadata?.hashtags[indexPath.row] ?? "tag"
            let title = "#\(tag)"
            var size = title.size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont()!])
            size.width = CGFloat(ceilf(Float(12.0 + size.width + 39.0)))
            size.height = 30
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
            
        } else {
            guard let themeData = themeManager.themeData?.secondaryButtonTheme else { return .zero }
            
            var size = "Add".size(withAttributes: [NSAttributedString.Key.font: themeData.font.toFont()!])
            size.width = CGFloat(ceilf(Float(12.0 + size.width + 36.0)))
            size.height = 30
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
        }
    }
}

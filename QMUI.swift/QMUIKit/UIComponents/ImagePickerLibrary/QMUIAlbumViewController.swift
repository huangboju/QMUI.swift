//
//  QMUIAlbumViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 相册预览图的大小默认值
private let QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight: CGFloat = 67
// 相册预览大小（正方形），如果想要跟图片一样高，则设置成跟 QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight 一样的值就好了
private let QMUIAlbumViewControllerDefaultAlbumImageSize: CGFloat = 57
// 相册缩略图的 left，默认 -1，表示和上下一样大
private let QMUIAlbumViewControllerDefaultAlbumImageLeft: CGFloat = -1
// 相册名称的字号默认值
private let QMUIAlbumTableViewCellDefaultAlbumNameFontSize: CGFloat = 16
// 相册资源数量的字号默认值
private let QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize: CGFloat = 16
// 相册名称的 insets 默认值
private let QMUIAlbumTableViewCellDefaultAlbumNameInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)

@objc protocol QMUIAlbumViewControllerDelegate: NSObjectProtocol {
    /// 点击相簿里某一行时，需要给一个 QMUIImagePickerViewController 对象用于展示九宫格图片列表
    @objc optional func imagePickerViewController(for albumViewController: QMUIAlbumViewController) -> QMUIImagePickerViewController

    /**
     *  取消查看相册列表后被调用
     */
    @objc optional func albumViewControllerDidCancel(_ albumViewController: QMUIAlbumViewController)

    /**
     *  即将需要显示 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    @objc optional func albumViewControllerWillStartLoad(_ albumViewController: QMUIAlbumViewController)

    /**
     *  即将需要隐藏 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    @objc optional func albumViewControllerWillFinishLoad(_ albumViewController: QMUIAlbumViewController)
}

class QMUIAlbumTableViewCell: QMUITableViewCell {
    
    var albumImageSize: CGFloat = QMUIAlbumViewControllerDefaultAlbumImageSize // 相册缩略图的 insets
    var albumImageMarginLeft: CGFloat = QMUIAlbumViewControllerDefaultAlbumImageLeft // 相册缩略图的 left
    var albumNameFontSize = QMUIAlbumTableViewCellDefaultAlbumNameFontSize // 相册名称的字号
    var albumAssetsNumberFontSize = QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize // 相册资源数量的字号
    var albumNameInsets = QMUIAlbumTableViewCellDefaultAlbumNameInsets // 相册名称的 insets

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func didInitialized(_ style: UITableViewCell.CellStyle) {
        super.didInitialized(style)

        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        detailTextLabel?.textColor = UIColorGrayDarken
    }

    override func updateCellAppearance(_ indexPath: IndexPath) {
        super.updateCellAppearance(indexPath)
        textLabel?.font = UIFontBoldMake(albumNameFontSize)
        detailTextLabel?.font = UIFontMake(albumAssetsNumberFontSize)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageEdgeTop = contentView.bounds.height.center(albumImageSize)
        let imageEdgeLeft = albumImageMarginLeft == QMUIAlbumViewControllerDefaultAlbumImageLeft ? imageEdgeTop : albumImageMarginLeft
        
        guard let imageView = imageView, let textLabel = textLabel, let detailTextLabel = detailTextLabel else {
            return
        }
        
        imageView.frame = CGRect(x: imageEdgeLeft, y: imageEdgeTop, width: albumImageSize, height: albumImageSize)
        
        textLabel.frame = textLabel.frame.setXY(imageView.frame.maxX + albumNameInsets.left, textLabel.qmui_minYWhenCenterInSuperview)
        
        let textLabelMaxWidth = contentView.bounds.width - textLabel.frame.minX - detailTextLabel.bounds.width - albumNameInsets.right
        if textLabel.bounds.width > textLabelMaxWidth {
            textLabel.frame = textLabel.frame.setWidth(textLabelMaxWidth)
        }
        
        detailTextLabel.frame = detailTextLabel.frame.setXY(textLabel.frame.maxX + albumNameInsets.right, detailTextLabel.qmui_minYWhenCenterInSuperview)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QMUIAlbumViewController: QMUICommonTableViewController {

    var albumTableViewCellHeight: CGFloat = QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight // 相册列表 cell 的高度，同时也是相册预览图的宽高

    weak var albumViewControllerDelegate: QMUIAlbumViewControllerDelegate?

    var contentType = QMUIAlbumContentType.all // 相册展示内容的类型，可以控制只展示照片、视频或音频（仅 iOS 8.0 及以上版本支持）的其中一种，也可以同时展示所有类型的资源，默认展示所有类型的资源。

    var tipTextWhenNoPhotosAuthorization: String?
    var tipTextWhenPhotosEmpty: String?
    /**
     *  加载相册列表时会出现 loading，若需要自定义 loading 的形式，可将该属性置为 NO，默认为 YES。
     *  @see albumViewControllerWillStartLoad: & albumViewControllerWillFinishLoad:
     */
    var shouldShowDefaultLoadingView = true

    private var albumsArray: [QMUIAssetsGroup] = []
    private var imagePickerViewController: QMUIImagePickerViewController?

    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = title ?? "照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem.item(title: "取消", target: self, action: #selector(handleCancelSelectAlbum))
    }

    @objc override func initTableView() {
        super.initTableView()
        tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if QMUIAssetsManager.authorizationStatus == .notAuthorized {
            // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
            var tipString = tipTextWhenNoPhotosAuthorization
            if tipString == nil {
                let mainInfoDictionary = Bundle.main.infoDictionary
                var appName = mainInfoDictionary?["CFBundleDisplayName"]
                if appName == nil {
                    appName = mainInfoDictionary?[kCFBundleNameKey as String]
                }
                tipString = "请在设备的\"设置-隐私-照片\"选项中，允许\(appName!)访问你的手机相册"
            }
            showEmptyViewWith(text: tipString, detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            albumViewControllerDelegate?.albumViewControllerWillStartLoad?(self)
            // 获取相册列表较为耗时，交给子线程去处理，因此这里需要显示 Loading
            if shouldShowDefaultLoadingView {
                showEmptyViewWithLoading()
            }
            DispatchQueue.global().async {
                QMUIAssetsManager.shared.enumerateAllAlbums(withAlbumContentType: self.contentType, usingBlock: {[weak self] resultAssetsGroup in
                    guard let strongSelf = self else {
                        return
                    }
                    // 这里需要对 UI 进行操作，因此放回主线程处理
                    DispatchQueue.main.async {
                        if let asset = resultAssetsGroup {
                            strongSelf.albumsArray.append(asset)
                        } else {
                            strongSelf.refreshAlbumAndShowEmptyTipIfNeed()
                        }
                    }
                })
            }
        }
    }

    func refreshAlbumAndShowEmptyTipIfNeed() {
        if albumsArray.isEmpty {
            let tipString = tipTextWhenPhotosEmpty ?? "空照片"
            showEmptyViewWith(text: tipString, detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            albumViewControllerDelegate?.albumViewControllerWillStartLoad?(self)
            if shouldShowDefaultLoadingView {
                hideEmptyView()
            }
            tableView.reloadData()
        }
    }
    
    /// 在 QMUIAlbumViewController 被放到 UINavigationController 里之后，可通过调用这个方法，来尝试直接进入上一次选中的相册列表
    func pickLastAlbumGroupDirectlyIfCan() {
        let assetsGroup = QMUIImagePickerHelper.assetsGroupOfLastPickerAlbum(with: nil)
        pickAlbumsGroup(assetsGroup, animated: false)
    }
    
    private func pickAlbumsGroup(_ assetsGroup: QMUIAssetsGroup?, animated: Bool) {
        guard let assetsGroup = assetsGroup else {
            return
        }
        
        if imagePickerViewController == nil  {
            imagePickerViewController = albumViewControllerDelegate?.imagePickerViewController?(for: self)
        }
        
        assert(imagePickerViewController != nil, "albumViewControllerDelegate 必须实现 imagePickerViewController(for:) 并返回一个 \(NSStringFromClass(QMUIImagePickerViewController.self)) 对象")
        
        imagePickerViewController?.refresh(with: assetsGroup)
        imagePickerViewController?.title = assetsGroup.name
        navigationController?.pushViewController(imagePickerViewController!, animated: animated)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return albumsArray.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return albumTableViewCellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? QMUIAlbumTableViewCell
        if cell == nil {
            cell = QMUIAlbumTableViewCell(tableView: tableView, style: .subtitle, reuseIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
        }
        let assetsGroup = albumsArray[indexPath.row]
        // 显示相册缩略图

        cell?.imageView?.image = assetsGroup.posterImage(with: CGSize(width: albumTableViewCellHeight, height: albumTableViewCellHeight))
        // 显示相册名称
        cell?.textLabel?.text = assetsGroup.name
        // 显示相册中所包含的资源数量
        cell?.detailTextLabel?.text = "\(assetsGroup.numberOfAssets)"

        cell?.updateCellAppearance(indexPath)

        return cell ?? UITableViewCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickAlbumsGroup(albumsArray[indexPath.row], animated: true)
    }

    @objc func handleCancelSelectAlbum() {
        navigationController?.dismiss(animated: true, completion: {
            self.albumViewControllerDelegate?.albumViewControllerDidCancel?(self)
            self.imagePickerViewController?.selectedImageAssetArray.removeAll()
        })
    }
}

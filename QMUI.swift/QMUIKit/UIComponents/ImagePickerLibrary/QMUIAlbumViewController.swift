//
//  QMUIAlbumViewController.swift
//  QMUI.swift
//
//  Created by 黄伯驹 on 2017/7/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

// 相册预览图的大小默认值
let QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight: CGFloat = 57
// 相册名称的字号默认值
let QMUIAlbumTableViewCellDefaultAlbumNameFontSize: CGFloat = 16
// 相册资源数量的字号默认值
let QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize: CGFloat = 16
// 相册名称的 insets 默认值
let QMUIAlbumTableViewCellDefaultAlbumNameInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 4)

protocol QMUIAlbumViewControllerDelegate: class {
    /// 点击相簿里某一行时，需要给一个 QMUIImagePickerViewController 对象用于展示九宫格图片列表
    func imagePickerViewController(for albumViewController: QMUIAlbumViewController) -> QMUIImagePickerViewController
    
    /**
     *  取消查看相册列表后被调用
     */
    func albumViewControllerDidCancel(_ albumViewController: QMUIAlbumViewController)
    
    /**
     *  即将需要显示 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    func albumViewControllerWillStartLoad(_ albumViewController: QMUIAlbumViewController)

    /**
     *  即将需要隐藏 Loading 时调用
     *
     *  @see shouldShowDefaultLoadingView
     */
    func albumViewControllerWillFinishLoad(_ albumViewController: QMUIAlbumViewController)
}

extension QMUIAlbumViewControllerDelegate {
    func albumViewControllerDidCancel(_ albumViewController: QMUIAlbumViewController) {}

    func albumViewControllerWillStartLoad(_ albumViewController: QMUIAlbumViewController) {}

    func albumViewControllerWillFinishLoad(_ albumViewController: QMUIAlbumViewController) {}
}

class QMUIAlbumTableViewCell: QMUITableViewCell {
    var albumNameFontSize = QMUIAlbumTableViewCellDefaultAlbumNameFontSize // 相册名称的字号
    var albumAssetsNumberFontSize = QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize // 相册资源数量的字号
    var albumNameInsets = QMUIAlbumTableViewCellDefaultAlbumNameInsets // 相册名称的 insets
    
    private let bottomLineLayer = CALayer()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        detailTextLabel?.textColor = UIColorGrayDarken

        
        bottomLineLayer.backgroundColor = UIColorSeparator.cgColor
        // 让分隔线垫在背后
        layer.insertSublayer(bottomLineLayer, at: 0)
    }
    
    override func updateCellAppearance(with indexPath: IndexPath) {
        super.updateCellAppearance(with: indexPath)
        textLabel?.font = UIFontBoldMake(albumNameFontSize)
        detailTextLabel?.font = UIFontMake(albumAssetsNumberFontSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 避免iOS7下seletedBackgroundView会往上下露出1px（以盖住系统分隔线，但我们的分隔线是自定义的）
        selectedBackgroundView?.frame = bounds
        
        let contentViewPaddingRight: CGFloat = 10
        let height = contentView.bounds.height

        imageView?.frame = CGSize(width: height, height: height).rect

        let textLabelFrame = textLabel?.frame ?? .zero

        textLabel?.frame.setXY(imageView?.frame.maxX ?? 0, flat(textLabel?.qmui_minYWhenCenterInSuperview ?? 0))

        let textLabelMaxWidth = contentView.bounds.width - contentViewPaddingRight - (detailTextLabel?.frame.width ?? 0) - albumNameInsets.right - textLabelFrame.minX

        if textLabelFrame.width > textLabelMaxWidth {
            textLabel?.frame.setWidth(textLabelMaxWidth)
        }

        if let label = detailTextLabel {
            detailTextLabel?.frame = label.frame.setXY(textLabelFrame.maxX + albumNameInsets.right, flat(detailTextLabel?.qmui_minYWhenCenterInSuperview ?? 0))
        }

        bottomLineLayer.frame = CGRect(x: 0, y: contentView.bounds.height - PixelOne, width: bounds.width, height: PixelOne)
    }

    override var isHighlighted: Bool {
        didSet {
            bottomLineLayer.isHidden = isHighlighted
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QMUIAlbumViewController : QMUICommonTableViewController {

    public var albumTableViewCellHeight: CGFloat = QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight // 相册列表 cell 的高度，同时也是相册预览图的宽高

    public weak var albumViewControllerDelegate: QMUIAlbumViewControllerDelegate?
    
    public var contentType = QMUIAlbumContentType.all // 相册展示内容的类型，可以控制只展示照片、视频或音频（仅 iOS 8.0 及以上版本支持）的其中一种，也可以同时展示所有类型的资源，默认展示所有类型的资源。
    
    public var tipTextWhenNoPhotosAuthorization: String?
    public var tipTextWhenPhotosEmpty: String?
    /**
     *  加载相册列表时会出现 loading，若需要自定义 loading 的形式，可将该属性置为 NO，默认为 YES。
     *  @see albumViewControllerWillStartLoad: & albumViewControllerWillFinishLoad:
     */
    public var shouldShowDefaultLoadingView = true

    private var _albumsArray: [QMUIAssetsGroup] = []
    private var _imagePickerViewController: QMUIImagePickerViewController?

    override func setNavigationItems(isInEditMode model: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode: model, animated: animated)
        title = title ?? "照片"
        navigationItem.rightBarButtonItem = QMUINavigationButton.barButtonItem(with: .normal, title: "取消", position: .right, target: self, action: #selector(handleCancelSelectAlbum))
    }

    override func initTableView() {
        super.initTableView()
        tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if QMUIAssetsManager.authorizationStatus ==  .notAuthorized {
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
            showEmptyView(text: tipString, detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            albumViewControllerDelegate?.albumViewControllerWillStartLoad(self)
            // 获取相册列表较为耗时，交给子线程去处理，因此这里需要显示 Loading
            if shouldShowDefaultLoadingView {
                showEmptyViewWithLoading()
            }
            DispatchQueue.global().async {
                QMUIAssetsManager.shared.enumerateAllAlbumsWithAlbumContentType(self.contentType, usingBlock: { (resultAssetsGroup) in
                    if let asset = resultAssetsGroup {
                        self._albumsArray.append(asset)
                    } else {
                        self.refreshAlbumAndShowEmptyTipIfNeed()
                    }
                })
            }
        }
    }
    
    func refreshAlbumAndShowEmptyTipIfNeed() {
        if _albumsArray.isEmpty {
            let tipString = tipTextWhenPhotosEmpty ?? "空照片"
            showEmptyView(text: tipString, detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            albumViewControllerDelegate?.albumViewControllerWillStartLoad(self)
            if shouldShowDefaultLoadingView {
                hideEmptyView()
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return _albumsArray.count
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return albumTableViewCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? QMUIAlbumTableViewCell
        if cell == nil {
            cell = QMUIAlbumTableViewCell(tableView: tableView, withStyle: .subtitle, reuseIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
        }
        let assetsGroup = _albumsArray[indexPath.row]
        // 显示相册缩略图

        cell?.imageView?.image = assetsGroup.posterImage(with: CGSize(width: albumTableViewCellHeight, height: albumTableViewCellHeight))
        // 显示相册名称
        cell?.textLabel?.text = assetsGroup.name
        // 显示相册中所包含的资源数量
        cell?.detailTextLabel?.text = "\(assetsGroup.numberOfAssets)"

        cell?.updateCellAppearance(with: indexPath)

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if _imagePickerViewController == nil {
            _imagePickerViewController = albumViewControllerDelegate?.imagePickerViewController(for: self)
        }

        assert(_imagePickerViewController != nil, "albumViewControllerDelegate 必须实现 imagePickerViewControllerForAlbumViewController 并返回一个 \(NSStringFromClass(QMUIImagePickerViewController.self)) 对象")

        let assetsGroup = _albumsArray[indexPath.row]
        _imagePickerViewController?.refreshWithAssetsGroup(assetsGroup)
        _imagePickerViewController?.title = assetsGroup.name
        navigationController?.pushViewController(_imagePickerViewController!, animated: true)
    }

    @objc func handleCancelSelectAlbum() {
        navigationController?.dismiss(animated: true, completion: { 
            self.albumViewControllerDelegate?.albumViewControllerDidCancel(self)
        })
    }
}

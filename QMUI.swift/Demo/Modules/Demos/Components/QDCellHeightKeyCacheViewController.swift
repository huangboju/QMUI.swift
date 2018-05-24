//
//  QDCellHeightKeyCacheViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/5/23.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kCellIdentifier = "cell"

private let kInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 16)
private let kAvatarSize: CGFloat = 30
private let kAvatarMarginRight: CGFloat = 12
private let kAvatarMarginBottom: CGFloat = 6
private let kContentMarginBotom: CGFloat = 10

// 这个 cell 只是为了展示每个 cell 高度不一样，这样才有被 cache 的意义，至于这个 cell 里的代码可以不看
class QDDynamicHeightTableViewCell: QMUITableViewCell {
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage.qmui_image(strokeColor: QDCommonUI.randomThemeColor(), size: CGSize(width: kAvatarSize, height: kAvatarSize), lineWidth: 3, cornerRadius: 6)
        let avatarImageView = UIImageView(image: avatarImage)
        return avatarImageView
    }()
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontBoldMake(16)
        label.textColor = UIColorGray2
        return label
    }()
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMake(17)
        label.textColor = UIColorGray1
        label.textAlignment = .justified
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMake(13)
        label.textColor = UIColorGray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
    }
    
    fileprivate func render(_ nameText: String, contentText: String?) {
        nameLabel.text = nameText
        contentLabel.attributedText = attributeString(contentText ?? "", lineHeight: 26)
        timeLabel.text = "昨天 18:24"
        contentLabel.textAlignment = .justified
        setNeedsLayout()
    }
    
    private func attributeString(_ string: String, lineHeight: CGFloat) -> NSAttributedString? {
        if string.qmui_trim.isEmpty {
            return nil
        }
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle(lineHeight: lineHeight, lineBreakMode: .byTruncatingTail)]
        let attriString = NSAttributedString(string: string, attributes: attributes)
        return attriString
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var resultSize = CGSize(width: size.width, height: 0)
        let contentLabelWidth = size.width - kInsets.horizontalValue
        
        var resultHeight = kInsets.horizontalValue + avatarImageView.bounds.height + kAvatarMarginBottom
        
        if let text = contentLabel.text, text.count > 0 {
            let contentSize = contentLabel.sizeThatFits(CGSize(width: contentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            resultHeight += (contentSize.height + kContentMarginBotom)
        }
        
        if let text = timeLabel.text, text.count > 0 {
            let timeSize = timeLabel.sizeThatFits(CGSize(width: contentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            resultHeight += timeSize.height
        }
        
        resultSize.height = resultHeight
        return resultSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentLabelWidth = contentView.bounds.width - kInsets.horizontalValue
        avatarImageView.frame = avatarImageView.frame.setXY(kInsets.left, kInsets.top)
        
        if let text = nameLabel.text, text.count > 0 {
            let nameLabelWidth = contentLabelWidth - avatarImageView.bounds.width - kAvatarMarginRight
            let nameSize = nameLabel.sizeThatFits(CGSize(width: nameLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            nameLabel.frame = CGRectFlat(avatarImageView.frame.maxX + kAvatarMarginRight, avatarImageView.frame.minY + (avatarImageView.bounds.height - nameSize.height) / 2, nameLabelWidth, nameSize.height)
        }
        if let text = contentLabel.text, text.count > 0 {
            let contentSize = contentLabel.sizeThatFits(CGSize(width: contentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            contentLabel.frame = CGRectFlat(kInsets.left, avatarImageView.frame.maxY + kAvatarMarginBottom, contentLabelWidth, contentSize.height)
        }
        if let text = timeLabel.text, text.count > 0 {
            let timeSize = timeLabel.sizeThatFits(CGSize(width: contentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            timeLabel.frame = CGRectFlat(contentLabel.frame.minX, contentLabel.frame.maxY + kContentMarginBotom, contentLabelWidth, timeSize.height)
        }
    }
}


class QDCellHeightKeyCacheViewController: QDCommonTableViewController {
    
    private var dataSource: QMUIOrderedDictionary<String, String> {
        get {
            let dataSource = QMUIOrderedDictionary(dictionaryLiteral:
                ("张三 的想法", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。"),
                ("李四 的想法", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。"),
                ("王五 的想法", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),
                ("QMUI Team 的想法", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。\nUIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。\n高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),

                ("张三 的想法1", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。"),
                ("李四 的想法1", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。"),
                ("王五 的想法1", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),
                ("QMUI Team 的想法1", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。\nUIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。\n高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),

                ("张三 的想法2", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。"),
                ("李四 的想法2", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。"),
                ("王五 的想法2", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),
                ("QMUI Team 的想法2", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。\nUIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。\n高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),

                ("张三 的想法3", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。"),
                ("李四 的想法3", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。"),
                ("王五 的想法3", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。"),
                ("QMUI Team 的想法3", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。\nUIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。\n高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。")
            )

            return dataSource
        }
    }
    
    override func setupNavigationItems() {
        super.setupNavigationItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .done, target: self, action: #selector(handleRightBarButtonItem))
    }
    
    override func initTableView() {
        super.initTableView()
        
        // 如果需要自动缓存 cell 高度的计算结果，则打开这个属性，然后实现 - [QMUITableViewDelegate qmui_tableView:cacheKeyForRowAtIndexPath:] 方法即可
        // 只要打开这个属性，cell 的 self-sizing 特性也会被开启，所以请保证你的 cell 正确重写了 sizeThatFits: 方法（Auto-Layout 的忽略这句话）
        tableView.estimatedRowHeight = 300 // 注意，QMUI 通过配置表的开关 TableViewEstimatedHeightEnabled，默认在所有 iOS 版本打开 estimatedRowHeight（系统是在 iOS 11 之后默认打开），所以图方便的话这一句也可以不用写。
        tableView.qmui_cacheCellHeightByKeyAutomatically = true
    }
    
    @objc private func handleRightBarButtonItem() {
        // 在 key 没变的情况下，如果要令某个 cell 的高度重新计算，可以参照下方这么写：
        // 如果 key 变化了，则直接调用系统的 reloadRowsAtIndexPaths 就行了，不用手动去 invalidate 缓存的高度
        let indexPathForSpecificRow = IndexPath(item: 2, section: 0)
        if let cacheKeyForSpecificRow = (tableView.delegate as? QMUICellHeightKeyCache_UITableViewDelegate)?.qmui_tableView?(tableView, cacheKeyForRowAt: indexPathForSpecificRow) as? AnyHashable {
            tableView.qmui_currentCellHeightKeyCache?.invalidateHeight(for: cacheKeyForSpecificRow)
            tableView.reloadRows(at: [indexPathForSpecificRow], with: .none)
        }
    }
    
    
    func qmui_tableView(_ tableView: UITableView, cacheKeyForRowAt indexPath: IndexPath) -> AnyObject {
        // 返回一个用于标记当前 cell 高度的 key，只要 key 不变，高度就不会重新计算，所以建议将有可能影响 cell 高度的数据字段作为 key 的一部分（例如 username、content.md5 等），这样当数据发生变化时，只要触发 cell 的渲染，高度就会自动更新
        let keyName = dataSource.allKeys[indexPath.row]
        let contentText = dataSource[keyName] ?? ""
        return contentText.length as AnyObject // 这里简单处理，认为只要长度不同，高度就不同（但实际情况下长度就算相同，高度也有可能不同，要注意）
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as? QDDynamicHeightTableViewCell
        if cell == nil {
            cell = QDDynamicHeightTableViewCell(tableView: tableView, reuseIdentifier: kCellIdentifier)
        }
        cell?.separatorInset = .zero
        let keyName = dataSource.allKeys[indexPath.row]
        cell?.updateCellAppearance(indexPath)
        cell?.render("\(indexPath.row) - \(keyName)", contentText: dataSource[keyName]!)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.qmui_clearsSelection()
    }
}

//
//  QDTableViewCellDynamicHeightViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/18.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

private let kInsets = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 16)
private let kAvatarSize: CGFloat = 30
private let kAvatarMarginRight: CGFloat = 12
private let kAvatarMarginBottom: CGFloat = 6
private let kContentMarginBotom: CGFloat = 10

class QDDynamicTableViewCell: QMUITableViewCell {
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage.qmui_image(strokeColor: QDCommonUI.randomThemeColor(), size: CGSize(width: kAvatarSize, height: kAvatarSize), lineWidth: 3, cornerRadius: 6)
        let avatarImageView = UIImageView(image: avatarImage)
        return avatarImageView
    }()
    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontBoldMake(16)
        label.textColor = UIColorGray2
        return label
    }()
    
    fileprivate var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMake(17)
        label.textColor = UIColorGray1
        label.textAlignment = .justified
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var timeLabel: UILabel = {
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
    
    fileprivate func render(_ nameText: String, contentText: String) {
        nameLabel.text = nameText
        contentLabel.attributedText = attributeString(contentText, lineHeight: 26)
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


class QDTableViewCellDynamicHeightViewController: QDCommonTableViewController {

    private var names:[String] = ["张三 的想法", "李四 的想法", "张三 的想法", "李四 的想法", "张三 的想法", "李四 的想法", "张三 的想法", "李四 的想法", "张三 的想法", "李四 的想法", "张三 的想法"]

    private var contents:[String] = ["全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。", "丰富的 UI 控件：提供丰富且常用的 UI 控件，使用方便灵活，并且支持自定义控件的样式。", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。", "iOS UI 解决方案：QMUI iOS 的设计目的是用于辅助快速搭建一个具备基本设计还原效果的 iOS 项目，同时利用自身提供的丰富控件及兼容处理，让开发者能专注于业务需求而无需耗费精力在基础代码的设计上。不管是新项目的创建，或是已有项目的维护，均可使开发效率和项目质量得到大幅度提升。", "全局 UI 配置：只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。", "UIKit 拓展及版本兼容：拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。", "丰富的 UI 控件：提供丰富且常用的 UI 控件，使用方便灵活，并且支持自定义控件的样式。", "高效的工具方法及宏：提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。", "iOS UI 解决方案：QMUI iOS 的设计目的是用于辅助快速搭建一个具备基本设计还原效果的 iOS 项目，同时利用自身提供的丰富控件及兼容处理，让开发者能专注于业务需求而无需耗费精力在基础代码的设计上。不管是新项目的创建，或是已有项目的维护，均可使开发效率和项目质量得到大幅度提升。"]
    
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return min(names.count, self.contents.count)
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellIdentifier = "cell"
        return self.tableView.qmui_heightForCell(withIdentifier: cellIdentifier, cacheBy: indexPath, configuration: {
            if let cell = $0 as? QDDynamicTableViewCell {
                cell.render(self.names[indexPath.row], contentText: self.contents[indexPath.row])
            }
        })
    }
    
    private func qmui_tableView(_ tableView: UITableView, cellWithIdentifier identifier: String) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? QDDynamicTableViewCell
        if cell == nil {
            cell = QDDynamicTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = qmui_tableView(tableView, cellWithIdentifier: cellIdentifier) as? QDDynamicTableViewCell
        cell?.render(names[indexPath.row], contentText: contents[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.qmui_clearsSelection()
    }
}

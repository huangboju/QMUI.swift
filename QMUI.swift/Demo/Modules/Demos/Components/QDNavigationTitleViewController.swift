//
//  QDNavigationTitleViewController.swift
//  QMUI.swift
//
//  Created by qd-hxt on 2018/4/10.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

import UIKit

class QDNavigationTitleViewController: QDCommonListViewController {

    private lazy var popupMenuView: QMUIPopupMenuView = {
        let popupMenuView = QMUIPopupMenuView()
        popupMenuView.automaticallyHidesWhenUserTap = true// 点击空白地方自动消失
        popupMenuView.preferLayoutDirection = .below
        popupMenuView.maximumWidth = 220
        popupMenuView.items = [QMUIPopupMenuItem(image: UIImageMake("icon_emotion"), title: "分类 1", handler: nil),
                               QMUIPopupMenuItem(image: UIImageMake("icon_emotion"), title: "分类 2", handler: nil),
                               QMUIPopupMenuItem(image: UIImageMake("icon_emotion"), title: "分类 3", handler: nil)]
        popupMenuView.didHideClosure = {[weak self] (hidesByUserTap: Bool) -> Void in
            self?.titleView.isActive = false
        }
        return popupMenuView
    }()
    
    private var horizontalAlignment: UIControlContentHorizontalAlignment = .center
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialized() {
        super.didInitialized()
        titleView.needsLoadingView = true
        titleView.qmui_needsDifferentDebugColor = true
        horizontalAlignment = titleView.contentHorizontalAlignment
    }
    
    deinit {
        titleView.delegate = nil
    }
    
    override func setNavigationItems(_ isInEditMode: Bool, animated: Bool) {
        super.setNavigationItems(isInEditMode, animated: animated)
        title = "主标题"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if popupMenuView.isShowing {
            popupMenuView.layout(with: titleView)
        }
    }
    
    override func initDataSource() {
        dataSource = ["显示左边的 loading",
                      "显示右边的 accessoryView",
                      "显示副标题",
                      "切换为上下两行显示",
                      "水平方向的对齐方式",
                      "模拟标题的 loading 状态切换",
                      "标题搭配浮层使用的示例",
                      "显示 Debug 背景色"]
    }
    
    // MARK: QMUITableViewDataSource, QMUITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 因为有第 6 行的存在，所以每次都要重置一下这几个属性，避免影响其他 Demo 的展示
        titleView.isUserInteractionEnabled = false
        titleView.delegate = nil
        
        switch indexPath.row {
        case 0:
            // 切换 loading 的显示/隐藏
            titleView.loadingViewHidden = !titleView.loadingViewHidden
            break
        case 1:
            // 切换右边的 accessoryType 类型，可支持自定义的 accessoryView
            titleView.accessoryType = titleView.accessoryType == .none ? .disclosureIndicator : .none
            break
        case 2:
            // 切换副标题的显示/隐藏
            if titleView.subtitle == nil {
                titleView.subtitle = "(副标题)"
            } else {
                titleView.subtitle = nil
            }
            break
        case 3:
            // 切换主副标题的水平/垂直布局
            titleView.style = titleView.style == .default ? .subTitleVertical : .default
            titleView.subtitle = titleView.style == .subTitleVertical ? "(副标题)" : titleView.subtitle
            break
        case 4:
            // 水平对齐方式
            let alertController = QMUIAlertController(title: "水平对齐方式", message: nil, preferredStyle: .sheet)
            let action = QMUIAlertAction(title: "左对齐", style: .default) { (_) in
                self.titleView.contentHorizontalAlignment = .left
                self.horizontalAlignment = self.titleView.contentHorizontalAlignment
                self.tableView.reloadData()
            }
            alertController.add(action: action)
            alertController.add(action: QMUIAlertAction(title: "居中对齐", style: .default) { (_) in
                self.titleView.contentHorizontalAlignment = .center
                self.horizontalAlignment = self.titleView.contentHorizontalAlignment
                self.tableView.reloadData()
            })
            alertController.add(action: QMUIAlertAction(title: "右对齐", style: .default) { (_) in
                self.titleView.contentHorizontalAlignment = .right
                self.horizontalAlignment = self.titleView.contentHorizontalAlignment
                self.tableView.reloadData()
            })
            alertController.add(action: QMUIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertController.show(true)
            break
        case 5:
            // 模拟不同状态之间的切换
            titleView.loadingViewHidden = false
            titleView.needsLoadingPlaceholderSpace = false
            titleView.title = "加载中..."
            titleView.subtitle = nil
            titleView.style = .default
            titleView.accessoryType = .none
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.titleView.needsLoadingPlaceholderSpace = true
                self.titleView.loadingViewHidden = true
                self.titleView.title = "微信"
            }
            break
        case 6:
            // 标题搭配浮层的使用示例
            titleView.isUserInteractionEnabled = true // 要titleView支持点击，需要打开它的 userInteractionEnabled，这个属性默认是 NO
            titleView.title = "点我展开分类"
            titleView.accessoryType = .disclosureIndicator
            titleView.delegate = self // 要监听 titleView 的点击事件以及状态切换，需要通过 delegate 的形式
            break
        case 7:
            // Debug 背景色
            titleView.qmui_shouldShowDebugColor = true
            break
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (super.tableView(tableView, cellForRowAt: indexPath) as? QMUITableViewCell) else {
            return UITableViewCell()
        }
        cell.accessoryType = .none
        cell.detailTextLabel?.text = nil
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = titleView.loadingViewHidden ? "显示左边的 loading" : "隐藏左边的 loading"
            break
        case 1:
            cell.textLabel?.text = titleView.accessoryType == .none ? "显示右边的 accessoryView" : "去掉右边的 accessoryView"
            break
        case 2:
            cell.textLabel?.text = titleView.subtitle != nil ? "去掉副标题" : "显示副标题"
            break
        case 3:
            cell.textLabel?.text = titleView.style == .default ? "切换为上下两行显示" : "切换为水平一行显示"
            break
        case 4:
            var text: String?
            if horizontalAlignment == .left {
                text = "左对齐"
            } else if horizontalAlignment == .right {
                text = "右对齐"
            } else {
                text = "居中对齐"
            }
            cell.detailTextLabel?.text = text
            break
        default:
            break
        }
        return cell
    }
    
    
}

extension QDNavigationTitleViewController: QMUINavigationTitleViewDelegate {
    
    func didChanged(_ active: Bool, for titleView: QMUINavigationTitleView) {
        if active {
            popupMenuView.layout(with: titleView)
            popupMenuView.show(with: true)
        }
    }
}

//
//  QMUISegmentedControl.swift
//  QMUI.swift
//
//  Created by 伯驹 黄 on 2017/5/10.
//  Copyright © 2017年 伯驹 黄. All rights reserved.
//

/*
 * QMUISegmentedControl，继承自 UISegmentedControl
 * 如果需要更大程度地修改样式，比如说字体大小，选中的 segment 的文字颜色等等，可以使用下面的第一个方法来做
 * QMUISegmentedControl 也同样支持使用图片来做样式，需要五张图片。
 */
public class QMUISegmentedControl: UISegmentedControl {

    var _items: [Any]?

    override init(items: [Any]?) {
        super.init(items: items)
        _items = items
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _items = []
    }

    /**
     * 重新渲染 UISegmentedControl 的 UI，可以比较大程度地修改样式。比如 tintColor，selectedTextColor 等等。
     *
     * @param tintColor             Segmented 的 tintColor，作用范围包括字体颜色和按钮 border
     * @param selectedTextColor     Segmented 选中状态的字体颜色
     * @param fontSize              Segmented 上字体的大小
     */
    func updateSegmentedUI(with tintColor: UIColor, selectedTextColor: UIColor, fontSize: UIFont) {
        self.tintColor = tintColor
        setTitleTextAttributes(with: tintColor, selectedTextColor: selectedTextColor, fontSize: fontSize)
    }

    /**
     * 用图片而非 tintColor 来渲染 UISegmentedControl 的 UI
     *
     * @param normalImage               Segmented 非选中状态的背景图
     * @param selectedImage             Segmented 选中状态的背景图
     * @param devideImage00             Segmented 在两个没有选中按钮 item 之间的分割线
     * @param devideImage01             Segmented 在左边没选中右边选中两个 item 之间的分割线
     * @param devideImage10             Segmented 在左边选中右边没选中两个 item 之间的分割线
     * @param textColor                 Segmented 的字体颜色
     * @param selectedTextColor         Segmented 选中状态的字体颜色
     * @param fontSize                  Segmented 的字体大小
     */
    func setBackground(with normalImage: UIImage, selectedImage: UIImage, devideImage00: UIImage, devideImage01: UIImage, devideImage10: UIImage, textColor: UIColor, selectedTextColor: UIColor, fontSize: UIFont) {
        setTitleTextAttributes(with: textColor, selectedTextColor: selectedTextColor, fontSize: fontSize)
        setBackground(with: normalImage, selectedImage: selectedImage, devideImage00: devideImage00, devideImage01: devideImage01, devideImage10: devideImage10)
    }

    private func setTitleTextAttributes(with textColor: UIColor, selectedTextColor: UIColor, fontSize: UIFont) {
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: fontSize,
        ], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: selectedTextColor,
            NSAttributedString.Key.font: fontSize,
        ], for: .selected)
    }

    private func setBackground(with normalImage: UIImage, selectedImage: UIImage, devideImage00: UIImage, devideImage01: UIImage, devideImage10: UIImage) {
        let devideImageWidth = devideImage00.size.width

        setBackgroundImage(normalImage.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)), for: .normal, barMetrics: .default)
        setBackgroundImage(selectedImage.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)), for: .selected, barMetrics: .default)
        setDividerImage(devideImage00.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        setDividerImage(devideImage10.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: devideImageWidth / 2, bottom: 12, right: devideImageWidth / 2)), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)

        setDividerImage(devideImage01.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: devideImageWidth / 2, bottom: 12, right: devideImageWidth / 2)), forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)

        setContentPositionAdjustment(UIOffset(horizontal: -(12 - devideImageWidth) / 2, vertical: 0), forSegmentType: .left, barMetrics: .default)
        setContentPositionAdjustment(UIOffset(horizontal: (12 - devideImageWidth) / 2, vertical: 0), forSegmentType: .right, barMetrics: .default)
    }

    // MARK: - Copy Items
    public override func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        super.insertSegment(withTitle: title, at: segment, animated: animated)
        _items?.insert(title as Any, at: segment)
    }

    public override func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) {
        super.insertSegment(with: image, at: segment, animated: animated)
        _items?.insert(image as Any, at: segment)
    }

    public override func removeSegment(at segment: Int, animated: Bool) {
        super.removeSegment(at: segment, animated: animated)
        _items?.remove(at: segment)
    }

    public override func removeAllSegments() {
        super.removeAllSegments()
        _items?.removeAll()
        _items = nil
    }

    /// 获取当前的所有 segmentItem，可能包括 NSString 或 UIImage。
    public var segmentItems: [Any]? {
        return _items
    }
}

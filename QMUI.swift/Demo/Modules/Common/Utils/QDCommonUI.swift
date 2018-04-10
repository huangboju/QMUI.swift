//
//  QDCommonUI.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//


let QDSelectedThemeClassName = "selectedThemeClassName"

let QDButtonSpacingHeight: CGFloat = 72

// MARK: Colors
let UIColorGray1 = UIColorMake(53, 60, 70)
let UIColorGray2 = UIColorMake(73, 80, 90)
let UIColorGray3 = UIColorMake(93, 100, 110)
let UIColorGray4 = UIColorMake(113, 120, 130)
let UIColorGray5 = UIColorMake(133, 140, 150)
let UIColorGray6 = UIColorMake(153, 160, 170)
let UIColorGray7 = UIColorMake(173, 180, 190)
let UIColorGray8 = UIColorMake(196, 200, 208)
let UIColorGray9 = UIColorMake(216, 220, 228)

let UIColorTheme1 = UIColorMake(239, 83, 98) // Grapefruit
let UIColorTheme2 = UIColorMake(254, 109, 75) // Bittersweet
let UIColorTheme3 = UIColorMake(255, 207, 71) // Sunflower
let UIColorTheme4 = UIColorMake(159, 214, 97) // Grass
let UIColorTheme5 = UIColorMake(63, 208, 173) // Mint
let UIColorTheme6 = UIColorMake(49, 189, 243) // Aqua
let UIColorTheme7 = UIColorMake(90, 154, 239) // Blue Jeans
let UIColorTheme8 = UIColorMake(172, 143, 239) // Lavender
let UIColorTheme9 = UIColorMake(238, 133, 193) // Pink Rose

class QDCommonUI {
    
    static func renderGlobalAppearances() {
        QDUIHelper.customMoreOperationAppearance()
        QDUIHelper.customAlertControllerAppearance()
        QDUIHelper.customDialogViewControllerAppearance()
        QDUIHelper.customEmotionViewAppearance()
    }
    
    
}

// MARK: ThemeColor
extension QDCommonUI {
    
    static let themeColors = [
        UIColorTheme1,
        UIColorTheme2,
        UIColorTheme3,
        UIColorTheme4,
        UIColorTheme5,
        UIColorTheme6,
        UIColorTheme7,
        UIColorTheme8,
        UIColorTheme9]
    static func randomThemeColor() -> UIColor {
        let index = Int(arc4random_uniform(UInt32(themeColors.count)))
        return themeColors[index]
    }
}

// MARK: Layer
extension QDCommonUI {
    static func generateSeparatorLayer() -> CALayer {
        let layer = CALayer()
        layer.qmui_removeDefaultAnimations()
        layer.backgroundColor = UIColorSeparator.cgColor
        return layer
    }
}



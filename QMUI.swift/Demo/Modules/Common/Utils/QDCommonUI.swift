//
//  QDCommonUI.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/6.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

// MARK: Colors
let UIColorGray1 = UIColor(r: 53, g: 60, b: 70)
let UIColorGray2 = UIColor(r: 73, g: 80, b: 90)
let UIColorGray3 = UIColor(r: 93, g: 100, b: 110)
let UIColorGray4 = UIColor(r: 113, g: 120, b: 130)
let UIColorGray5 = UIColor(r: 133, g: 140, b: 150)
let UIColorGray6 = UIColor(r: 153, g: 160, b: 170)
let UIColorGray7 = UIColor(r: 173, g: 180, b: 190)
let UIColorGray8 = UIColor(r: 196, g: 200, b: 208)
let UIColorGray9 = UIColor(r: 216, g: 220, b: 228)

let UIColorTheme1 = UIColor(r: 239, g: 83, b: 98) // Grapefruit
let UIColorTheme2 = UIColor(r: 254, g: 109, b: 75) // Bittersweet
let UIColorTheme3 = UIColor(r: 255, g: 207, b: 71) // Sunflower
let UIColorTheme4 = UIColor(r: 159, g: 214, b: 97) // Grass
let UIColorTheme5 = UIColor(r: 63, g: 208, b: 173) // Mint
let UIColorTheme6 = UIColor(r: 49, g: 189, b: 243) // Aqua
let UIColorTheme7 = UIColor(r: 90, g: 154, b: 239) // Blue Jeans
let UIColorTheme8 = UIColor(r: 172, g: 143, b: 239) // Lavender
let UIColorTheme9 = UIColor(r: 238, g: 133, b: 193) // Pink Rose

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



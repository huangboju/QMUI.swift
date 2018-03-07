//
//  QDUIHelper.swift
//  QMUI.swift
//
//  Created by TonyHan on 2018/3/7.
//  Copyright © 2018年 伯驹 黄. All rights reserved.
//

class QDUIHelper {

    class func forceInterfaceOrientationPortrait() {
        
    }
    
}

// MARK: - UITabBarItem
extension QDUIHelper {
    
    public class func tabBarItem(title: String?, image: UIImage?, selectedImage: UIImage?, tag: Int) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        tabBarItem.selectedImage = selectedImage
        return tabBarItem
    }
}

extension QDUIHelper {
    
}

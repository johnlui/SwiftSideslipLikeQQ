//
//  Common.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/4/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

struct Common {
    // Swift 中， static let 才是真正可靠好用的单例模式
    static let screenWidth = UIScreen.main.applicationFrame.maxX
    static let screenHeight = UIScreen.main.applicationFrame.maxY
    static let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
    static let contactsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Contacts") 
}

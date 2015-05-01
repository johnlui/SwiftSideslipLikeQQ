//
//  MainTabBarController.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/5/2.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        switch item.tag {
        case 0:
            Common.contactsVC.view.removeFromSuperview()
        case 1:
            Common.rootViewController.mainTabBarController.view.addSubview(Common.contactsVC.view)
            Common.rootViewController.mainTabBarController.view.bringSubviewToFront(Common.rootViewController.mainTabBarController.tabBar)
        case 2:
            println("Just like case 1 ↑")
        default:
            break
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

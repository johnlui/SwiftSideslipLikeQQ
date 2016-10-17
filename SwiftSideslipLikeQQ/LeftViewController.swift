//
//  LeftViewController.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/4/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

// 侧滑菜单 View Controller
class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let titlesDictionary = ["开通会员", "QQ钱包", "网上营业厅", "个性装扮", "我的收藏", "我的相册", "我的文件"]

    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var heightLayoutConstraintOfSettingTableView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.tableFooterView = UIView()
        
        heightLayoutConstraintOfSettingTableView.constant = Common.screenHeight < 500 ? Common.screenHeight * (568 - 221) / 568 : 347
        self.view.frame = CGRect(x: 0, y: 0, width: 320 * 0.78, height: Common.screenHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 处理点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = Common.rootViewController
        viewController.homeViewController.titleOfOtherPages = titlesDictionary[(indexPath as NSIndexPath).row]
        viewController.homeViewController.performSegue(withIdentifier: "showOtherPages", sender: self)
        Common.contactsVC.view.removeFromSuperview()
        viewController.mainTabBarController.tabBar.isHidden = true
        viewController.mainTabBarController.selectedIndex = 0
        viewController.showHome()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leftViewCell", for: indexPath) 
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.text = titlesDictionary[(indexPath as NSIndexPath).row]
        
        return cell
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

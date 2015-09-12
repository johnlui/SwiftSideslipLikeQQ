//
//  HomeViewController.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

// 主页
class HomeViewController: UIViewController {
    
    var titleOfOtherPages = ""

    @IBOutlet var panGesture: UIPanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置中间 segmentView 视图
        let segmentView = UISegmentedControl(items: ["消息", "电话"])
        segmentView.selectedSegmentIndex = 0
        segmentView.setWidth(60, forSegmentAtIndex: 0)
        segmentView.setWidth(60, forSegmentAtIndex: 1)
        self.navigationItem.titleView = segmentView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOtherPages" {
            if let a = segue.destinationViewController as? OtherPageViewController {
                a.PageTitle = titleOfOtherPages
            }
        }
    }
    

}

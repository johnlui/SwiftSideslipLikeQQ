//
//  ViewController.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

// 此 View Controller 为根容器，本身并不包含任何 UI 元素
class ViewController: UIViewController {
    
    // 该 TabBar Controller 不是传统意义上的容器，在此只负责提供 UITabBar 这个 UI 组件
    var mainTabBarController: MainTabBarController!
    
    // 主界面点击手势，用于在菜单划出状态下点击主页后自动关闭菜单
    var tapGesture: UITapGestureRecognizer!
    
    // 首页的 Navigation Bar 的提供者，是首页的容器
    var homeNavigationController: UINavigationController!
    // 首页中间的主要视图的来源
    var homeViewController: HomeViewController!
    // 侧滑菜单视图的来源
    var leftViewController: LeftViewController!
    
    // 构造主视图，实现 UINavigationController.view 和 HomeViewController.view 一起缩放
    var mainView: UIView!
    
    // 侧滑所需参数
    var distance: CGFloat = 0
    let FullDistance: CGFloat = 0.78
    let Proportion: CGFloat = 0.77
    var centerOfLeftViewAtBeginning: CGPoint!
    var proportionOfLeftView: CGFloat = 1
    var distanceOfLeftView: CGFloat = 50
    
    // 侧滑菜单黑色半透明遮罩层
    var blackCover: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给根容器设置背景
        let imageView = UIImageView(image: UIImage(named: "back"))
        imageView.frame = UIScreen.main.bounds
        self.view.addSubview(imageView)
        
        // 通过 StoryBoard 取出左侧侧滑菜单视图
        leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        // 适配 4.7 和 5.5 寸屏幕的缩放操作，有偶发性小 bug
        if Common.screenWidth > 320 {
            proportionOfLeftView = Common.screenWidth / 320
            distanceOfLeftView += (Common.screenWidth - 320) * FullDistance / 2
        }
        leftViewController.view.center = CGPoint(x: leftViewController.view.center.x - 50, y: leftViewController.view.center.y)
        leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        
        // 动画参数初始化
        centerOfLeftViewAtBeginning = leftViewController.view.center
        // 把侧滑菜单视图加入根容器
        self.view.addSubview(leftViewController.view)
        
        // 在侧滑菜单之上增加黑色遮罩层，目的是实现视差特效
        blackCover = UIView(frame: self.view.frame.offsetBy(dx: 0, dy: 0))
        blackCover.backgroundColor = UIColor.black
        self.view.addSubview(blackCover)
        
        // 初始化主视图，即包含 TabBar、NavigationBar和首页的总视图
        mainView = UIView(frame: self.view.frame)
        // 初始化 TabBar
        let nibContents = Bundle.main.loadNibNamed("MainTabBarController", owner: nil, options: nil)
        mainTabBarController = nibContents?.first as! MainTabBarController
        // 取出 TabBar Controller 的视图加入主视图
        let tabBarView = mainTabBarController.view
        mainView.addSubview(tabBarView!)
        // 从 StoryBoard 取出首页的 Navigation Controller
        homeNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
        // 从 StoryBoard 初始化而来的 Navigation Controller 会自动初始化他的 Root View Controller，即 HomeViewController
        // 我们将其（指针）取出，赋给容器 View Controller 的成员变量 homeViewController
        homeViewController = homeNavigationController.viewControllers.first as! HomeViewController
        // 分别将 Navigation Bar 和 homeViewController 的视图加入 TabBar Controller 的视图
        tabBarView?.addSubview(homeViewController.navigationController!.view)
        tabBarView?.addSubview(homeViewController.view)
        
        // 在 TabBar Controller 的视图中，将 TabBar 视图提到最表层
        tabBarView?.bringSubview(toFront: mainTabBarController.tabBar)
        
        // 将主视图加入容器
        self.view.addSubview(mainView)
        
        // 分别指定 Navigation Bar 左右两侧按钮的事件
        homeViewController.navigationItem.leftBarButtonItem?.action = #selector(ViewController.showLeft)
        homeViewController.navigationItem.rightBarButtonItem?.action = #selector(ViewController.showRight)
        
        // 给主视图绑定 UIPanGestureRecognizer
        let panGesture = homeViewController.panGesture
        panGesture?.addTarget(self, action: #selector(ViewController.pan(_:)))
        mainView.addGestureRecognizer(panGesture!)
        
        // 生成单击收起菜单手势
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.showHome))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 响应 UIPanGestureRecognizer 事件
    func pan(_ recongnizer: UIPanGestureRecognizer) {
        let x = recongnizer.translation(in: self.view).x
        let trueDistance = distance + x // 实时距离
        let trueProportion = trueDistance / (Common.screenWidth*FullDistance)
        
        // 如果 UIPanGestureRecognizer 结束，则激活自动停靠
        if recongnizer.state == UIGestureRecognizerState.ended {

            if trueDistance > Common.screenWidth * (Proportion / 3) {
                showLeft()
            } else if trueDistance < Common.screenWidth * -(Proportion / 3) {
                showRight()
            } else {
                showHome()
            }
            
            return
        }

        // 计算缩放比例
        var proportion: CGFloat = recongnizer.view!.frame.origin.x >= 0 ? -1 : 1
        proportion *= trueDistance / Common.screenWidth
        proportion *= 1 - Proportion
        proportion /= FullDistance + Proportion/2 - 0.5
        proportion += 1
        if proportion <= Proportion { // 若比例已经达到最小，则不再继续动画
            return
        }
        // 执行视差特效
        blackCover.alpha = (proportion - Proportion) / (1 - Proportion)
        // 执行平移和缩放动画
        recongnizer.view!.center = CGPoint(x: self.view.center.x + trueDistance, y: self.view.center.y)
        recongnizer.view!.transform = CGAffineTransform.identity.scaledBy(x: proportion, y: proportion)
        
        // 执行左视图动画
        let pro = 0.8 + (proportionOfLeftView - 0.8) * trueProportion
        leftViewController.view.center = CGPoint(x: centerOfLeftViewAtBeginning.x + distanceOfLeftView * trueProportion, y: centerOfLeftViewAtBeginning.y - (proportionOfLeftView - 1) * leftViewController.view.frame.height * trueProportion / 2 )
        leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: pro, y: pro)
    }
    
    // 封装三个方法，便于后期调用
    
    // 展示左视图
    func showLeft() {
        // 给首页 加入 点击自动关闭侧滑菜单功能
        mainView.addGestureRecognizer(tapGesture)
        // 计算距离，执行菜单自动滑动动画
        distance = self.view.center.x * (FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "left")
        homeNavigationController.popToRootViewController(animated: true)
    }
    // 展示主视图
    func showHome() {
        // 从首页 删除 点击自动关闭侧滑菜单功能
        mainView.removeGestureRecognizer(tapGesture)
        // 计算距离，执行菜单自动滑动动画
        distance = 0
        doTheAnimate(1, showWhat: "home")
    }
    // 展示右视图
    func showRight() {
        // 给首页 加入 点击自动关闭侧滑菜单功能
        mainView.addGestureRecognizer(tapGesture)
        // 计算距离，执行菜单自动滑动动画
        distance = self.view.center.x * -(FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "right")
    }
    // 执行三种动画：显示左侧菜单、显示主页、显示右侧菜单
    func doTheAnimate(_ proportion: CGFloat, showWhat: String) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            // 移动首页中心
            self.mainView.center = CGPoint(x: self.view.center.x + self.distance, y: self.view.center.y)
            // 缩放首页
            self.mainView.transform = CGAffineTransform.identity.scaledBy(x: proportion, y: proportion)
            if showWhat == "left" {
                // 移动左侧菜单的中心
                self.leftViewController.view.center = CGPoint(x: self.centerOfLeftViewAtBeginning.x + self.distanceOfLeftView, y: self.leftViewController.view.center.y)
                // 缩放左侧菜单
                self.leftViewController.view.transform = CGAffineTransform.identity.scaledBy(x: self.proportionOfLeftView, y: self.proportionOfLeftView)
            }
            // 改变黑色遮罩层的透明度，实现视差效果
            self.blackCover.alpha = showWhat == "home" ? 1 : 0

            // 为了演示效果，在右侧菜单划出时隐藏漏出的左侧菜单，并无实际意义
            self.leftViewController.view.alpha = showWhat == "right" ? 0 : 1
            }, completion: nil)
    }

}


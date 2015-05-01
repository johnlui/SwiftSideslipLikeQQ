//
//  ViewController.swift
//  SwiftSideslipLikeQQ
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var mainTabBarController: MainTabBarController!
    var tapGesture: UITapGestureRecognizer!
    
    var homeNavigationController: UINavigationController!
    var homeViewController: HomeViewController!
    var leftViewController: LeftViewController!
    var mainView: UIView! // 构造主视图。实现 UINavigationController.view 和 HomeViewController.view 一起缩放。
    var distance: CGFloat = 0
    
    let FullDistance: CGFloat = 0.78
    let Proportion: CGFloat = 0.77
    
    var blackCover: UIView!
    
    var centerOfLeftViewAtBeginning: CGPoint!
    var proportionOfLeftView: CGFloat = 1
    var distanceOfLeftView: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给主视图设置背景
        let imageView = UIImageView(image: UIImage(named: "back"))
        imageView.frame = UIScreen.mainScreen().bounds
        self.view.addSubview(imageView)
        
        // 通过 StoryBoard 取出 LeftViewController
        leftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController
        if Common.screenWidth > 320 {
            proportionOfLeftView = Common.screenWidth / 320
            distanceOfLeftView += (Common.screenWidth - 320) * FullDistance / 2
        }
        leftViewController.view.center = CGPointMake(leftViewController.view.center.x - 50, leftViewController.view.center.y)
        leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)
        
        centerOfLeftViewAtBeginning = leftViewController.view.center
        
        self.view.addSubview(leftViewController.view)
        
        // 增加黑色遮罩层，实现视差特效
        blackCover = UIView(frame: CGRectOffset(self.view.frame, 0, 0))
        blackCover.backgroundColor = UIColor.blackColor()
        self.view.addSubview(blackCover)
        
        // 通过 StoryBoard 取出 HomeViewController 的 view，放在背景视图上面
        mainView = UIView(frame: self.view.frame)
        
        let nibContents = NSBundle.mainBundle().loadNibNamed("MainTabBarController", owner: nil, options: nil)
        mainTabBarController = nibContents.first as! MainTabBarController
        
        let tabBarView = mainTabBarController.view
        mainView.addSubview(tabBarView)
        
        homeNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
        homeViewController = homeNavigationController.viewControllers.first as! HomeViewController
        tabBarView.addSubview(homeViewController.navigationController!.view)
        tabBarView.addSubview(homeViewController.view)
        
        tabBarView.bringSubviewToFront(mainTabBarController.tabBar)
        
        self.view.addSubview(mainView)
        
        homeViewController.navigationItem.leftBarButtonItem?.action = Selector("showLeft")
        homeViewController.navigationItem.rightBarButtonItem?.action = Selector("showRight")
        
        // 绑定 UIPanGestureRecognizer
        let panGesture = homeViewController.panGesture
        panGesture.addTarget(self, action: Selector("pan:"))
        mainView.addGestureRecognizer(panGesture)
        
        // 生成单击收起菜单手势
        tapGesture = UITapGestureRecognizer(target: self, action: "showHome")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 响应 UIPanGestureRecognizer 事件
    func pan(recongnizer: UIPanGestureRecognizer) {
        let x = recongnizer.translationInView(self.view).x
        let trueDistance = distance + x // 实时距离
        let trueProportion = trueDistance / (Common.screenWidth*FullDistance)
        
        // 如果 UIPanGestureRecognizer 结束，则激活自动停靠
        if recongnizer.state == UIGestureRecognizerState.Ended {

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
        recongnizer.view!.center = CGPointMake(self.view.center.x + trueDistance, self.view.center.y)
        recongnizer.view!.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
        
        // 执行左视图动画
        let pro = 0.8 + (proportionOfLeftView - 0.8) * trueProportion
        leftViewController.view.center = CGPointMake(centerOfLeftViewAtBeginning.x + distanceOfLeftView * trueProportion, centerOfLeftViewAtBeginning.y - (proportionOfLeftView - 1) * leftViewController.view.frame.height * trueProportion / 2 )
        leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, pro, pro)
    }
    
    // 封装三个方法，便于后期调用
    
    // 展示左视图
    func showLeft() {
        mainView.addGestureRecognizer(tapGesture)
        distance = self.view.center.x * (FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "left")
        homeNavigationController.popToRootViewControllerAnimated(true)
    }
    // 展示主视图
    func showHome() {
        mainView.removeGestureRecognizer(tapGesture)
        distance = 0
        doTheAnimate(1, showWhat: "home")
    }
    // 展示右视图
    func showRight() {
        mainView.addGestureRecognizer(tapGesture)
        distance = self.view.center.x * -(FullDistance*2 + Proportion - 1)
        doTheAnimate(self.Proportion, showWhat: "right")
    }
    // 执行三种试图展示
    func doTheAnimate(proportion: CGFloat, showWhat: String) {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.mainView.center = CGPointMake(self.view.center.x + self.distance, self.view.center.y)
            self.mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
            if showWhat == "left" {
                self.leftViewController.view.center = CGPointMake(self.centerOfLeftViewAtBeginning.x + self.distanceOfLeftView, self.leftViewController.view.center.y)
                self.leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.proportionOfLeftView, self.proportionOfLeftView)
            }
            self.blackCover.alpha = showWhat == "home" ? 1 : 0
            self.leftViewController.view.alpha = showWhat == "right" ? 0 : 1
            }, completion: nil)
    }

}


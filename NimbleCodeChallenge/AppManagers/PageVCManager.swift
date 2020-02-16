//
//  PagerManager.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 14/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

class PageVCManager {
    
    private var totalPageCount = 0
    
    public let invalidIndex = -1
    
    public func setTotalPageCount(count: Int) {
        self.totalPageCount = count
    }
    
    /// function to get next visible survey vc
    /// - Parameters:
    ///   - previousIndex: previous visible survey index
    ///   - isAfter: if transition is forward
    public func nextPageIndex(with previousIndex: Int, isAfter: Bool = true) -> Int {
        let nextPageIndex = isAfter ? previousIndex + 1 : previousIndex - 1
        if nextPageIndex >= self.totalPageCount || nextPageIndex < 0 {
            return invalidIndex
        }
        return nextPageIndex
    }
    
    
    /// intialize SurveyDetailVC next to be visible
    /// - Parameter index: index in uipagerview
    public func initiateNextVC(for index: Int, with data: SurveyModel) -> SurveyDetailVC {
        let vc = SurveyDetailVC.instantiate(from: .Main)
        vc.index = index
        vc.surveyModel = data
        return vc
    }
    
}


extension MainPageVC: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let previousVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        
        let previousIndex: Int = previousVC.index
        let nextPageIndex = self.pageManager.nextPageIndex(with: previousIndex, isAfter: false)
        return self.setUpNextVC(pageIndex: nextPageIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previousVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        
        let previousIndex: Int = previousVC.index
        let nextPageIndex = self.pageManager.nextPageIndex(with: previousIndex)
        if let currentVC = self.setUpNextVC(pageIndex: nextPageIndex) {
            self.loadNewDataFromServer(index: currentVC.index)
            return currentVC
        }
        
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentVC = pageViewController.viewControllers?.first as? SurveyDetailVC else {
            return
        }
        
        self.pageControl.currentPage = currentVC.index
    }
}


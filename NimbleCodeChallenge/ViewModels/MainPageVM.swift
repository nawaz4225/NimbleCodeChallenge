//
//  MainPageVM.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import UIKit

class MainPageVM {
    let perPageLimit: Int = 7
    // load new data when reach 3rd last item
    let loadDataThreshold: Int = 3
    var surveysData: [SurveyModel] = [SurveyModel]()
    var isAutoLoadNext: Bool = false
    
    
    // get surveys from server
    func loadSurveyFromServer(isRefresh: Bool = false,
                              _ completion:  ((Error?)->Void)? = nil){
        
        if APIClient.sharedManager.isLoading && !isRefresh {
            return
        }
        
        let params = ["page": self.nextPageNumber(isRefresh: isRefresh),
                      "per_page": self.perPageLimit]
        APIClient.sharedManager.makeApiRequest(requestMethod: .get, strURL: surveysURL,parameter: params) { [weak self] (responseData, error) in
            guard let strongSelf = self else {
                return
            }
            if let resposeError = error {
                completion?(resposeError)
                return
            }
            if let responseData = responseData {
                let decoder = JSONDecoder()
                if let serverData = try? decoder.decode([SurveyModel].self, from: responseData) {
                    
                    if isRefresh {
                        strongSelf.surveysData.removeAll()
                    }
                    
                    strongSelf.surveysData.append(contentsOf: serverData)
                    
                    completion?(nil)
                }
                
            }
        }
    }
    
    /// index of next page to load
    /// - Parameter isRefresh: if refresh load first page (index = 0)
    func nextPageNumber(isRefresh: Bool = false) -> Int {
        return isRefresh ? 0 : (self.surveysData.count / self.perPageLimit)
    }
    
    /// check if user has scrolled to 3rd last item
    /// - Parameter index: index of last visible page
    func isLoadNewDataRequired(index: Int) -> Bool {
        return (index >= self.surveysData.count - self.loadDataThreshold)
    }
    
    /// function to get next visible survey vc
    /// - Parameters:
    ///   - previousIndex: previous visible survey index
    ///   - isAfter: if transition is forward
    func nextPageVC(previousIndex: Int, isAfter: Bool = true) -> SurveyDetailVC? {
        
        let nextPageIndex = isAfter ? previousIndex + 1 : previousIndex - 1
        if nextPageIndex >= self.surveysData.count || nextPageIndex < 0 {
            return nil
        }
        
        
        return self.initiateNextVC(for: nextPageIndex)
            
    }
    
    /// intialize SurveyDetailVC next to be visible
    /// - Parameter index: index in uipagerview
    func initiateNextVC(for index: Int) -> SurveyDetailVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SurveyDetailVC") as? SurveyDetailVC
        vc?.index = index
        vc?.surveyModel = self.surveysData[index]
        return vc
    }
}



extension MainPageVC: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let previousVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        let previousIndex = previousVC.index
        return self.viewModel.nextPageVC(previousIndex: previousIndex, isAfter: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previousVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        
        let previousIndex: Int = previousVC.index
        if let currentVC = self.viewModel.nextPageVC(previousIndex: previousIndex) {
            // load new data from server if user at 3rd last page
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

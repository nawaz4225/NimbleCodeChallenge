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
    let perPageLimit: Int = 5
    // load new data when reach 2rd last item
    let loadDataThreshold: Int = 2
    var surveysData: [SurveyModel] = [SurveyModel]()
    
    typealias fetchSurveysCompletion =  ((Error?)->Void)
    
    // get surveys from server
    func loadSurveyFromServer(with isRefresh: Bool = false,
                              _ completion: @escaping fetchSurveysCompletion){
        
        let params = ["page": self.nextPageNumber(with: isRefresh),
                      "per_page": self.perPageLimit]
        APIClient.sharedManager.makeApiRequest(requestMethod: .get, strURL: surveysURL,parameter: params) { [weak self] (responseData, error) in
            
            guard let strongSelf = self else {
                return
            }
            if let resposeError = error {
                completion(resposeError)
                return
            }
            if let responseData = responseData {
                let decoder = JSONDecoder()
                if let serverData = try? decoder.decode([SurveyModel].self, from: responseData), serverData.count > 0 {
                    if isRefresh {
                        strongSelf.surveysData.removeAll()
                    }
                    strongSelf.surveysData.append(contentsOf: serverData)
                    completion(nil)
                }
            }
        }
    }
    
    /// index of next page to load
    /// - Parameter isRefresh: if refresh load first page (index = 0)
    func nextPageNumber(with isRefresh: Bool = false) -> Int {
        return isRefresh ? 0 : (self.surveysData.count / self.perPageLimit)
    }
    
    /// check if user has scrolled to 2rd last item
    /// - Parameter index: index of last visible page
    func isLoadNewDataRequired(index: Int) -> Bool {
        
        let dataCount = self.surveysData.count
        
        /// load data if perPagaLimit is full
        if (dataCount % self.perPageLimit) == 0 {
            return (index >= self.surveysData.count - self.loadDataThreshold)
        }
        
        // already have complete data from server
        return false
    }
    
    /// function to get next visible survey vc
    /// - Parameters:
    ///   - previousIndex: previous visible survey index
    ///   - isAfter: if transition is forward
    func nextPageVC(with previousIndex: Int, isAfter: Bool = true) -> SurveyDetailVC? {
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
        
        let previousIndex: Int = previousVC.index
        if let currentVC = self.viewModel.nextPageVC(with: previousIndex, isAfter: false) {
            currentVC.takeSurveyHandler = self
            return currentVC
        }
        return self.viewModel.nextPageVC(with: previousIndex, isAfter: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previousVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        
        let previousIndex: Int = previousVC.index
        if let currentVC = self.viewModel.nextPageVC(with: previousIndex) {
            // load new data from server if user at 3rd last page
            self.loadNewDataFromServer(index: currentVC.index)
            
            currentVC.takeSurveyHandler = self
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


extension MainPageVC: TakeSurveyProtocol {
    func takeSurveyPressed(with surveyModel: SurveyModel?) {
        let networkStatusVC = self.storyboard?.instantiateViewController(withIdentifier: "NetworkStatusVC") as! NetworkStatusVC
        
        self.navigationController?.pushViewController(networkStatusVC, animated: true)
    }
    
    
}

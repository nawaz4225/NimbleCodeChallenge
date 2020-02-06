//
//  MainPageVC.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

class MainPageVC: UIPageViewController {
    
    let surveyData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MainPageVC: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentVC = (viewController as? SurveyDetailVC) else {
            return nil
        }
        
        let newIndex = currentVC.index + 1
        
        if newIndex >= surveyData.count  {
            return nil
        }
    
        let profile = SurveyDetailVC()
//        profile.profile = data?.filteredProfiles[newIndex]
        profile.index = newIndex
        return profile
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        <#code#>
    }
    
    
}

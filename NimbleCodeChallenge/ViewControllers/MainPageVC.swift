//
//  MainPageVC.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

class MainPageVC: UIViewController {
    
    // The custom UIPageControl
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var pcTrailing: NSLayoutConstraint!
    
    // The UIPageViewController
    var pageContainer: UIPageViewController!
    
    let viewModel = MainPageVM()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        self.pageContainer.delegate = self
        self.pageContainer.dataSource = self
        // Add it to the view
        view.addSubview(self.pageContainer.view)
        // Configure our custom pageControl
        if let image = UIImage.outlinedEllipse(size: CGSize(width: 7.0, height: 7.0), color: .white) {
            self.pageControl.pageIndicatorTintColor = UIColor.init(patternImage: image)
            self.pageControl.currentPageIndicatorTintColor = .white
        }
        self.pageControl.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        view.bringSubviewToFront(self.pageControl)
        self.loadSurveysData(isRefresh: true)
    }
    
    
    /// NavBar Left refresh button pressed action
    /// - Parameter sender: UIBarButton
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        self.loadSurveysData(isRefresh: true)
    }
    
    /// Loading Surveys data from Server
    /// - Parameter isRefresh: if refreshing from to left nav button
    func loadSurveysData(isRefresh: Bool = false) {
        // View Controller to handle network status / loading / errors
        if isRefresh {
            self.pageControl.numberOfPages = 0
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NetworkStatusVC") as! NetworkStatusVC
            self.pageContainer.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
        self.viewModel.loadSurveyFromServer(isRefresh: isRefresh) { error in
            if let error = error {
//                vc.statusLbl.text = error.localizedDescription
//                vc.retryBtn.isHidden = false
                return
            }
            
            let dataCount: Int = self.viewModel.surveysData.count
            self.refreshDataSource()
            
            if dataCount > 0  {
                if isRefresh {
                    let firstVC = self.viewModel.initiateNextVC(for: 0)!
                    self.pageContainer.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
                    self.pageControl.currentPage = 0
                }
                if self.pageControl.numberOfPages != dataCount {
                    self.pageControl.numberOfPages = dataCount
                    self.pcTrailing.constant = -((self.pageControl.bounds.width/2) + 20)
                }
            }
        }
    }
    
    /// Refresh PagerView data source on new data load
    func refreshDataSource() {
        self.pageContainer.dataSource = nil
        self.pageContainer.dataSource = self
    }
    
    /// Load new surveys from server if user scrolled to 3rd last page
    /// - Parameter index: index of previous visible page
    func loadNewDataFromServer(index: Int) {
        if self.viewModel.isLoadNewDataRequired(index: index) {
            self.loadSurveysData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CachedImageView.clearImageCache()
    }
}



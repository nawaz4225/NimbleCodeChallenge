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
    private var pageContainer: UIPageViewController!
    
    public let pageManager = PageVCManager()
    
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
            self.pageControl.pageIndicatorTintColor = UIColor(patternImage: image)
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
    /// - Parameter isRefresh: isRefresh = true = loading first time or loading from nav bar refresh button
    func loadSurveysData(isRefresh: Bool = false) {
        // View Controller to handle network status / loading / errors
        if isRefresh {
            // disable multiple refreshing
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.showNetworkStatusVC(with: "Loading Data...")
        }
        
        self.viewModel.loadSurveyFromServer(with: isRefresh) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationItem.leftBarButtonItem?.isEnabled = true
            
            let dataCount: Int = strongSelf.viewModel.surveysData.count
            
            if let error = error {
                
                //show network error message if refresh or first page load failed
                if isRefresh {
                    //                vc.statusLbl.text = error.localizedDescription
                    strongSelf.showNetworkStatusVC(with: error.localizedDescription)
                    //                vc.retryBtn.isHidden = false
                    
                    return
                }
            } else {
                strongSelf.refreshDataSource(count: dataCount)
            }
            
            if dataCount > 0  {
                if isRefresh {
                    if let firstVC = strongSelf.setUpNextVC(pageIndex: 0) {
                        strongSelf.pageContainer.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
                        strongSelf.pageControl.currentPage = 0
                    }
                }
                if strongSelf.pageControl.numberOfPages != dataCount {
                    strongSelf.pageControl.numberOfPages = dataCount
                    strongSelf.pcTrailing.constant = -((strongSelf.pageControl.bounds.width/2) + 20)
                }
            }
        }
    }
    
    
    /// load NetworkStatusVC
    /// - Parameter errorMsg: network error message or loading data
    func showNetworkStatusVC(with errorMsg: String) {
        self.pageControl.numberOfPages = 0
        
        let networkStatusVC = self.storyboard?.instantiateViewController(withIdentifier: "NetworkStatusVC") as! NetworkStatusVC
        networkStatusVC.errorMsg = errorMsg
        self.pageContainer.setViewControllers([networkStatusVC], direction: .forward, animated: false, completion: nil)
    }
    
    /// Refresh PagerView data source on new data load
    func refreshDataSource(count: Int) {
        self.pageManager.setTotalPageCount(count: count)
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
    
    
    func setUpNextVC(pageIndex: Int) -> SurveyDetailVC? {
        
        // invalid when navigating back at first controller and forward at last controller
        if pageIndex == self.pageManager.invalidIndex {
            return nil
        }
        
        if  self.viewModel.surveysData.count > pageIndex {
            let data = self.viewModel.surveysData[pageIndex]
            return self.pageManager.initiateNextVC(for: pageIndex, with: data)
        }
        return nil
        
    }
    
    
}

extension MainPageVC: TakeSurveyProtocol {
    func takeSurveyPressed(with surveyModel: SurveyModel?) {
        let networkStatusVC = self.storyboard?.instantiateViewController(withIdentifier: "NetworkStatusVC") as! NetworkStatusVC
        
        self.navigationController?.pushViewController(networkStatusVC, animated: true)
    }
    
    
}

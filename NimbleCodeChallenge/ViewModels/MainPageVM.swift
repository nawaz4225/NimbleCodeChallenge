//
//  MainPageVM.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation

class MainPageVM {
    let loadDataThreshold: Int = 2
    
    private let apiClient: APIClient = APIClient()
    public var surveysData: [SurveyModel] = [SurveyModel]()
    
    private var pageController: PageControlModel = PageControlModel(with: 0)
    
    
    typealias fetchSurveysCompletion =  ((Error?)->Void)
    
    // get surveys from server
    func loadSurveyFromServer(with isRefresh: Bool = false,
                              _ completion: @escaping fetchSurveysCompletion){
        
        self.pageController = PageControlModel(with: self.nextPageNumber(with: isRefresh))
        
        
        apiClient.makeApiRequest(requestMethod: .get, strURL: surveysURL,parameter: self.pageController, responseType: [SurveyModel].self) { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            
            switch (response) {
            case .success(let surveyData):
                if surveyData.count > 0 {
                    if isRefresh {
                        strongSelf.surveysData.removeAll()
                    }
                    strongSelf.surveysData.append(contentsOf: surveyData)
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error)
            }
            
        }
    }
    
    /// index of next page to load
    /// - Parameter isRefresh: if refresh load first page (index = 0)
    func nextPageNumber(with isRefresh: Bool = false) -> Int {
        return isRefresh ? 0 : (self.surveysData.count / self.pageController.perPage)
    }
    
    /// check if user has scrolled to 2rd last item
    /// - Parameter index: index of last visible page
    func isLoadNewDataRequired(index: Int) -> Bool {
        
        let dataCount = self.surveysData.count
        
        /// load data if perPagaLimit is full
        if (dataCount % pageController.perPage) == 0 {
            return (index >= dataCount - self.loadDataThreshold)
        }
        
        // already have complete data from server
        return false
    }
    
}

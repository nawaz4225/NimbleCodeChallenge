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
    public var surveysData: [SurveyModel] = [SurveyModel]()
    
    private var pageController: PageControlModel = PageControlModel(with: 0)

    
    typealias fetchSurveysCompletion =  ((Error?)->Void)
    
    // get surveys from server
    func loadSurveyFromServer(with isRefresh: Bool = false,
                              _ completion: @escaping fetchSurveysCompletion){
        
        self.pageController = PageControlModel(with: self.nextPageNumber(with: isRefresh))
        
        guard let params = self.pageController.toDictionary() else {
            return
        }
        
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

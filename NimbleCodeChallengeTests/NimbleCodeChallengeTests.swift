//
//  NimbleCodeChallengeTests.swift
//  NimbleCodeChallengeTests
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import XCTest
@testable import NimbleCodeChallenge

struct DummySurveys {
    
    func createDummySurveys(size: Int) -> [SurveyModel] {
        
        var surveysData = [SurveyModel]()
        
        let dumyTheme = Theme(colorActive: "", colorInactive: "", colorQuestion: "", colorAnswerNormal: "", colorAnswerInactive: "")
        let dumySurvey = SurveyModel(id: "", title: "", description: "", coverImageUrl: "", theme: dumyTheme)
        for _ in 0...size - 1 {
            surveysData.append(dumySurvey)
        }
        
        return surveysData
    }
}

class NimbleCodeChallengeTests: XCTestCase {
    
    var viewModel: MainPageVM!
    var dumySurveyGenerator: DummySurveys!
    var authModel: OathModel!
    
    var perPageLimit: Int!
    var newloadDataindex: Int!
    var newdataLoadIndex: Int!
    
    override func setUp() {
        self.viewModel = MainPageVM()
        self.dumySurveyGenerator = DummySurveys()
        self.perPageLimit = self.viewModel.perPageLimit
        let dummySurveys = self.dumySurveyGenerator.createDummySurveys(size: 10)
        self.viewModel.surveysData.append(contentsOf: dummySurveys)
        self.newdataLoadIndex = self.viewModel.surveysData.count - self.viewModel.loadDataThreshold
        self.authModel = OathModel(accessToken: "", tokenType: "", expiresIn: 7200, createdAt: Int64(Date().timeIntervalSince1970))
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testnextPageNumberToLoadFisRefreshing() {
        XCTAssertEqual(viewModel.nextPageNumber(with: true), 0)
    }
    
    
    func testnextPageNumberWhen10loadedSurveys() {
        XCTAssertEqual(viewModel.nextPageNumber(), (10 / self.perPageLimit))
    }
    
    
    func testloadnewdatawhenbelowthreshold()  {        XCTAssertFalse(self.viewModel.isLoadNewDataRequired(index: self.newdataLoadIndex - 1))
    }
    
    func testloadnewdatawhenabovethreshold()  {
        XCTAssertTrue(self.viewModel.isLoadNewDataRequired(index: self.newdataLoadIndex))
    }
    
    func testSrollForwardAtLastPage() {
        XCTAssertNil(self.viewModel.nextPageVC(with: self.viewModel.surveysData.count))
    }
    
    
    func testScrollAtLastPage() {
        XCTAssertNotNil(self.viewModel.nextPageVC(with: self.viewModel.surveysData.count, isAfter: false))
    }
    
    func testScrollBackwardFromFirstPage() {
        XCTAssertNil(self.viewModel.nextPageVC(with: 0, isAfter: false))
    }
    
    func testScrollForwardFromFirstPage() {
        XCTAssertNotNil(self.viewModel.nextPageVC(with: 0))
    }
    
    
    func testauthTokenNotExpired(){
        XCTAssertTrue(authModel.isValidAccessToken())
    }
    
    func testauthTokenExpired() {
        let authModel = OathModel(accessToken: "", tokenType: "", expiresIn: 7200, createdAt: Int64(Date().timeIntervalSince1970) - 7200)
        XCTAssertFalse(authModel.isValidAccessToken())
    }
    
    
    func testAPICallForRefreshingData() {
        let e = expectation(description: "Alamofire")
        self.viewModel.loadSurveyFromServer(with: true) { (errorInReponse) in
            guard let _ = errorInReponse else {
                XCTAssertTrue(self.viewModel.surveysData.count > 0)
                e.fulfill()
                return
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}

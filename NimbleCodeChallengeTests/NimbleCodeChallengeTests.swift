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
    
    let invalidIndex = -1
    var viewModel: MainPageVM!
    var dumySurveyGenerator: DummySurveys!
    var authModel: OathModel!
    var pageManager: PageVCManager!
    var pageController: PageControlModel!
    var newloadDataindex: Int!
    var newdataLoadIndex: Int!
    
    override func setUp() {
        self.viewModel = MainPageVM()
        self.pageManager = PageVCManager()
        self.dumySurveyGenerator = DummySurveys()
        
        let dummySurveys = self.dumySurveyGenerator.createDummySurveys(size: 10)
        self.viewModel.surveysData.append(contentsOf: dummySurveys)

        self.pageController = PageControlModel(with: 4)
        self.newdataLoadIndex = self.viewModel.surveysData.count - self.viewModel.loadDataThreshold
        self.authModel = OathModel(accessToken: "", tokenType: "", expiresIn: 7200, createdAt: Int64(Date().timeIntervalSince1970))
        
        self.pageManager.setTotalPageCount(count: self.viewModel.surveysData.count)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testnextPageNumberToLoadFisRefreshing() {
        XCTAssertEqual(viewModel.nextPageNumber(with: true), 0)
    }
    
    
    func testnextPageNumberWhen10loadedSurveys() {
        XCTAssertEqual(viewModel.nextPageNumber(), (10 / self.pageController.perPage))
    }
    
    
    func testloadnewdatawhenbelowthreshold()  {
        
        XCTAssertFalse(self.viewModel.isLoadNewDataRequired(index: self.newdataLoadIndex - 1))
    }
    
    func testloadnewdatawhenabovethreshold()  {
        
        XCTAssertTrue(self.viewModel.isLoadNewDataRequired(index: self.newdataLoadIndex + 1))
    }
    
    func testSrollForwardAtLastPage() {
        XCTAssertEqual(self.pageManager.nextPageIndex(with: self.viewModel.surveysData.count), self.invalidIndex, "invalid index when move forward at last page")
    }
    
    
    func testScrollBackAtLastPage() {
        let pageIndex = self.pageManager.nextPageIndex(with: self.viewModel.surveysData.count, isAfter: false)
        XCTAssertEqual(pageIndex, self.viewModel.surveysData.count - 1)
    }
    
    func testScrollBackwardFromFirstPage() {
        let pageIndex = self.pageManager.nextPageIndex(with: 0, isAfter: false)
        XCTAssertEqual(pageIndex, self.invalidIndex)
    }
    
    func testScrollForwardFromFirstPage() {
        let pageIndex = self.pageManager.nextPageIndex(with: 0)
        XCTAssertTrue(self.viewModel.surveysData.count > 0)
        XCTAssertEqual(pageIndex, 1)
    }
    
    
    func testauthTokenNotExpired(){
        XCTAssertTrue(authModel.isValidAccessToken())
    }
    
    func testauthTokenExpired() {
        let authModel = OathModel(accessToken: "", tokenType: "", expiresIn: 7200, createdAt: Int64(Date().timeIntervalSince1970) - 7200)
        XCTAssertFalse(authModel.isValidAccessToken())
    }
    
}

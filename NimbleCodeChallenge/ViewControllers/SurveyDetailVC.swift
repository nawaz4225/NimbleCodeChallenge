//
//  ViewController.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 01/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import UIKit

protocol TakeSurveyProtocol {
    func takeSurveyPressed(with surveyModel: SurveyModel?)
}

class SurveyDetailVC: UIViewController {
    
    var index: Int = 0
    var surveyModel: SurveyModel?
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var surveyBtn: UIButton!
    var takeSurveyHandler: TakeSurveyProtocol?
    
    @IBOutlet weak var coverImage: CachedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let surveyModel = self.surveyModel {
            self.titleLbl.text = surveyModel.title
            self.descriptionLbl.text = surveyModel.description
            self.coverImage.loadImage(urlString: "\(surveyModel.coverImageUrl)l", bgColor: UIColor(hexString: surveyModel.theme.colorActive))
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func takeSurveyAction(_ sender: UIButton) {
        takeSurveyHandler?.takeSurveyPressed(with: self.surveyModel)
    }
    
}


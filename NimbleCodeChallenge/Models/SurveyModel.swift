//
//  SurveyModel.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 04/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation

struct SurveyModel: Codable {
    let id: String
    let title: String
    let description: String
    let coverImageUrl: String
    let theme: Theme
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case coverImageUrl = "cover_image_url"
        case theme
        
    }
}

struct Theme: Codable {
    let colorActive, colorInactive, colorQuestion, colorAnswerNormal: String
    let colorAnswerInactive: String

    enum CodingKeys: String, CodingKey {
        case colorActive = "color_active"
        case colorInactive = "color_inactive"
        case colorQuestion = "color_question"
        case colorAnswerNormal = "color_answer_normal"
        case colorAnswerInactive = "color_answer_inactive"
    }
}

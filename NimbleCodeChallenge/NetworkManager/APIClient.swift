//
//  APIClient.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 04/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL = "https://nimble-survey-api.herokuapp.com/"
let authURL = "\(BASE_URL)oauth/token"
let surveysURL = "\(BASE_URL)surveys.json"

class APIClient {
    static let sharedManager = APIClient()
    var isLoading = false
    var authModel: OathModel?
    
    
    func makeApiRequest( requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  Dictionary<String, Any>?
        , withErrorAlert errorAlert : Bool = false
        , withLoader isLoader : Bool = true
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , withBlock completion : @escaping (Data?, Error?) -> Void){
        
        self.isLoading = true
        
        var param = Dictionary<String,Any>()
        if parameter != nil {
            param = parameter!
        }
        var apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if authModel == nil || (authModel?.accessToken.isEmpty ?? false) {
            self.getAuthToken {
                apiHeaders["Authorization"] = "Bearer \(self.authModel?.accessToken ?? "")"
                self.almofireJSONrequest(strURL: url, parameter: param, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.isLoading = false
                    
                    completion(responseData, error)
                }
            }
        } else {
            apiHeaders["Authorization"] = "Bearer \(self.authModel?.accessToken ?? "")"
            self.almofireJSONrequest(strURL: url, parameter: param, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isLoading = false
                
                completion(responseData, error)
            }
        }
    }
    
    
    private func almofireJSONrequest(requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  Dictionary<String, Any>?
        , debugInfo isPrint : Bool = false
        , apiHeaders: Dictionary<String, String>
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , withBlock completion : @escaping (Data?, Error?) -> Void){
        
        if isPrint {
            print("*****************URL***********************\n")
            print("URL:- \(url)\n")
            print("Parameter:-\(String(describing: parameter))\n")
            print("MethodType:- \(requestMethod.rawValue)\n")
            print("headers:-\(String(describing: apiHeaders))\n")
            
            print("*****************End***********************\n")
        }
        
        
        var encodingScheme: ParameterEncoding = apiEncoding
        if requestMethod == .get {
            encodingScheme = URLEncoding.default
        }
        
        
        
        Alamofire.request(url, method: requestMethod, parameters: parameter, encoding: encodingScheme, headers: apiHeaders).responseJSON(completionHandler: { (response) in
            
            switch(response.result) {
            case .success(let JSON):
                DispatchQueue.main.async {
                    if isPrint {
                        print(JSON)
                    }
                    completion(response.data, nil)
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    if isPrint {
                        print(error.localizedDescription)
                    }
                    completion(nil, error)
                }
            }
        })
    }
    
    
    
    private func getAuthToken(_ completion: @escaping ()->Void) {
        
        let params = ["grant_type": "password",
                      "username": "carlos@nimbl3.com",
                      "password": "antikera"]
        
        let apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        
        self.almofireJSONrequest(requestMethod: .post, strURL: authURL, parameter: params, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
            guard let strongSelf = self else {
                return
            }
            do{
                let decoder = JSONDecoder()
                if let responseData = responseData {
                    strongSelf.authModel = try decoder.decode(OathModel.self, from: responseData)
                }
                
            }catch let error {
                print(error.localizedDescription)
            }
            completion()
        }
        
    }
}

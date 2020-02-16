//
//  APIClient.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 04/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift


let BASE_URL: String = "https://nimble-survey-api.herokuapp.com/"
let authURL: String = "\(BASE_URL)oauth/token"
let surveysURL: String = "\(BASE_URL)surveys.json"

enum NetworkingErrors: Error {
    case errorParsingJSON
    case noInternetConnection
    case dataReturnedNil
    case returnedError(Error)
    case invalidStatusCode(Int)
    case customError(String)
}

class APIClient {
    
    static let sharedManager = APIClient()
    // pod KeychainSwift object to easy read write into keychain
    private let keychain = KeychainSwift()
    
    private var authModel: OathModel?
    
    func makeApiRequest( requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  Dictionary<String, Any>?
        , withErrorAlert errorAlert : Bool = false
        , withLoader isLoader : Bool = true
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , withBlock completion : @escaping (Data?, NetworkingErrors?) -> Void){
        
        
        var param = Dictionary<String,Any>()
        if parameter != nil {
            param = parameter!
        }
        var apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let authModel = self.retriveAuthModel(),  authModel.isValidAccessToken() {
            apiHeaders["Authorization"] = "Bearer \(authModel.accessToken)"
            self.almofireJSONrequest(strURL: url, parameter: param, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
                guard let _ = self else {
                    return
                }
                completion(responseData, error)
            }
        } else {
            self.getAuthToken { [weak self] authModel in
                guard let strongSelf = self else  {
                    return
                }
                guard let authModel = authModel else {
                    print("Authentication Failed!")
                    return
                }
                
                strongSelf.authModel = authModel
                apiHeaders["Authorization"] = "Bearer \(authModel.accessToken)"
                strongSelf.almofireJSONrequest(strURL: url, parameter: param, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
                    guard let _ = self else {
                        return
                    }
                    completion(responseData, error)
                }
            }
        }
    }
    
    
    private func almofireJSONrequest(requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  Dictionary<String, Any>?
        , debugInfo isPrint : Bool = true
        , apiHeaders: Dictionary<String, String>
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , withBlock completion : @escaping (Data?, NetworkingErrors?) -> Void){
        
        var encodingScheme: ParameterEncoding = apiEncoding
        if requestMethod == .get {
            encodingScheme = URLEncoding.default
        }
        
        Alamofire.request(url, method: requestMethod, parameters: parameter, encoding: encodingScheme, headers: apiHeaders).responseJSON(completionHandler: { (response) in
            
            switch(response.result) {
            case .success( _):
              
                DispatchQueue.main.async {
                    if response.response!.statusCode == 200 {
                        //do things
                        completion(response.data, nil)
                    }else if response.response!.statusCode == 401 {
                        //authorization failed Error
                        completion(nil, .customError("Authentication Failed!"))
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(nil, .returnedError(error))
                }
            }
        })
    }
    
    
    
    /// Retrive authData from Server
    /// - Parameter completion: callback
    private func getAuthToken(_ completion: @escaping (OathModel?)->Void) {
        
        let user = UserModel(grantType: "password",
                                      userName: "carlos@nimbl3.com",
                                      password: "antikera")
        
        guard let params = user.toDictionary() else {
            return
        }
    
        let apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        
        self.almofireJSONrequest(requestMethod: .post, strURL: authURL, parameter: params, apiHeaders: apiHeaders) { [weak self] (responseData, error) in
            guard let strongSelf = self else {
                return
            }
            var authModel: OathModel?

            if let responseData = responseData,
                let oathModel = responseData.decoded(as: OathModel.self) {
                // save auth data into keychain
                authModel = oathModel
                strongSelf.keychain.set(responseData, forKey: "auth_data")
            }

            completion(authModel)
        }
        
    }
    
    /// retrieve saved Oath Data from keychain
    private func retriveAuthModel() -> OathModel?{
        
        if let authModel = self.authModel {
            return authModel
        }
        
        guard let authData = self.keychain.getData("auth_data") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let authModel = try? decoder.decode(OathModel.self, from: authData) else {
            return nil
        }
        self.authModel = authModel
        
        return authModel
    }

}

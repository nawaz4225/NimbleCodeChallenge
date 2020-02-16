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

enum MyResult<T, E: Error> {
    case success(T)
    case failure(NetworkingErrors)
}

class APIClient {
    
    private let keychain = KeychainSwift()
    
    private let manager: SessionManager
    init(manager: SessionManager = SessionManager.default) {
        self.manager = manager
    }
    
    
    
    func makeApiRequest<T: Decodable>( requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  JSONCodable?
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , responseType: T.Type
        , withBlock completion :@escaping (MyResult<T, NetworkingErrors>) -> Void){
        
        var apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let authModel = self.retriveAuthModel(),  authModel.isValidAccessToken() {
            apiHeaders["Authorization"] = "Bearer \(authModel.accessToken)"
            self.almofireJSONrequest(strURL: url, parameter: parameter, apiHeaders: apiHeaders, responseType: responseType.self) { [weak self] response in
                guard let _ = self else {
                    return
                }
                switch response {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            self.getAuthToken { [weak self] authModel in
                guard let strongSelf = self else  {
                    return
                }
                guard let authModel = authModel else {
                    return
                }
                apiHeaders["Authorization"] = "Bearer \(authModel.accessToken)"
                strongSelf.almofireJSONrequest(strURL: url, parameter: parameter, apiHeaders: apiHeaders, responseType: responseType) { [weak self] response in
                    guard let _ = self else {
                        return
                    }
                    
                    switch response {
                    case .success(let result):
                        completion(.success(result))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                    
                    
                }
            }
        }
    }
    
    
    private func almofireJSONrequest<T: Decodable>(requestMethod: HTTPMethod = .get
        , strURL url : String
        , parameter :  JSONCodable?
        , apiHeaders: Dictionary<String, String>
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , responseType: T.Type
        , withBlock completion : @escaping (MyResult<T, NetworkingErrors>) -> Void){
        
        var encodingScheme: ParameterEncoding = apiEncoding
        if requestMethod == .get {
            encodingScheme = URLEncoding.default
        }
        
        var params = Dictionary<String, Any>()
        if let parameter = parameter {
            params = parameter.toDictionary() ?? [:]
        }
        
        self.manager.request(url, method: requestMethod, parameters: params, encoding: encodingScheme, headers: apiHeaders).responseJSON(completionHandler: { (response) in
            
            switch(response.result) {
            case .success( _):
                
                DispatchQueue.main.async {
                    if response.response!.statusCode == 200 {
                        //do things
                        if let responseData = response.data?.decoded(as: T.self) {
                            completion(.success(responseData))
                        }
                    }else if response.response!.statusCode == 401 {
                        //authorization failed Error
                        completion(.failure(.customError("Authentication Failed!")))
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(.returnedError(error)))
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
        
        
        let apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        
        self.almofireJSONrequest(requestMethod: .post, strURL: authURL, parameter: user, apiHeaders: apiHeaders, responseType: OathModel.self) { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            
            switch response {
                
            case .success(let result):
                strongSelf.saveAuthKeyCredentials(with: result)
                completion(result)
            case .failure( _):
                completion(nil)
            }
        }
        
    }
    
    /// retrieve saved Oath Data from keychain
    private func retriveAuthModel() -> OathModel?{
        
        guard let authData = self.keychain.getData("auth_data") else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let authModel = try? decoder.decode(OathModel.self, from: authData) else {
            return nil
        }
        
        return authModel
    }
    
    
    private func saveAuthKeyCredentials(with authData: OathModel) {
        if let data = try? JSONSerialization.data(withJSONObject: authData, options: JSONSerialization.WritingOptions.prettyPrinted) {
            self.keychain.set(data, forKey: "auth_data")
        }
    }
    
}

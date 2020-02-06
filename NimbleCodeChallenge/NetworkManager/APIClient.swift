//
//  NetworkManager.swift
//  NimbleCodeChallenge
//
//  Created by MacBook Pro on 04/02/2020.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL = "https://nimble-survey-api.herokuapp.com/"
let authURL = "\(BASE_URL)token"
let surveysURL = "\(BASE_URL)surveys.json"

class AFManager {
    static let sharedManager = AFManager()
    
    // MARK:- GET
    func Get(strURL url : String
        , parameter :  Dictionary<String, Any>?
        , withErrorAlert errorAlert : Bool = false
        , withLoader isLoader : Bool = true
        , debugInfo isPrint : Bool = true
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , authToken: String
        , withBlock completion : @escaping ([AnyHashable: Any], Data) -> Void){
        
        if isPrint {
            print("*****************URL***********************\n")
            print("URL:- \(url)\n")
            print("Parameter:-\(String(describing: parameter))\n")
            print("MethodType:- GET\n")
            print("*****************End***********************\n")
        }
        
        // add loader if isLoader is true
        //        GFunctions.shared.hideProgressHud()
        //        if isLoader {
        //            GFunctions.shared.showProgressHud()
        //        }
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(authToken)"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "\(url)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        if parameter != nil
        {
            let postData: Data? = try? JSONSerialization.data(withJSONObject: parameter as Any, options: [])
            request.httpBody = postData
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request  as URLRequest, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                
                //                if isLoader {
                //                    GFunctions.shared.hideProgressHud()
                //                }
                
                if error == nil && !(data?.isEmpty ?? true){
                    var JSON: Any?
                    if let data = data {
                        JSON = try? JSONSerialization.jsonObject(with: data, options: []) as Any
                    }
                    
                    guard let dict = JSON as? [AnyHashable: Any] else {
                        //print("\(result) couldn't be converted to Dictionary")
                        return
                    }
                    
                    if isPrint{
                        print(dict)
                    }
                    
                    //                    let status =  dict["status"] as? Int
                    //                    let message = dict["message"] as? String
                    let findData = dict["data"]
                    
                    if findData != nil{
                        //                        GFunctions.shared.hideProgressHud()
                        completion(dict, data!)
                    }else{
                        let error =  dict["error"] as? String ?? ""
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                            //                            GFunctions.shared.hideProgressHud()
                            
                            //AlertManager.shared.show(GPAlert(title:"Formee", message: error))
                        })
                    }
                    
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                        //                        GFunctions.shared.hideProgressHud()
                        //                        AlertManager.shared.show(GPAlert(title:"Formee", message: error?.localizedDescription))
                    })
                }
            }
            
        })
        task.resume()
    }
    
    func POST(strURL url : String
        , parameter :  Dictionary<String, Any>?
        , withErrorAlert errorAlert : Bool = false
        , withLoader isLoader : Bool = true
        , debugInfo isPrint : Bool = true
        , apiEncoding: ParameterEncoding = JSONEncoding.default
        , authToken: String
        , withBlock completion : @escaping (Data?, Int) -> Void){
        
        //        if Connectivity.isConnectedToInternet {
        
        if isPrint {
            print("*****************URL***********************\n")
            print("URL:- \(url)\n")
            print("Parameter:-\(String(describing: parameter))\n")
            print("MethodType:- POST\n")
            print("*****************End***********************\n")
        }
        
        var param = Dictionary<String,Any>()
        if parameter != nil {
            param = parameter!
        }
        
        // add loader if isLoader is true
        //            if isLoader {
        //                GFunctions.shared.showProgressHud()
        //                UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //            }
        
        let apiHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(authToken)"
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: apiEncoding, headers: apiHeaders).responseJSON(completionHandler: { (response) in
            
            switch(response.result) {
            case .success(let JSON):
                DispatchQueue.main.async {
                    
                    if isPrint {
                        print(JSON)
                    }
                    
                    // remove loader if isLoader is true
                    //                        if isLoader {
                    //                            GFunctions.shared.hideProgressHud()
                    //                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //                        }
                    
                    var statusCode = 0
                    //Logout User
                    if let headerResponse = response.response {
                        statusCode = headerResponse.statusCode
                    }
                    
                    completion(response.data, statusCode)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    //                        if isLoader {
                    //                            GFunctions.shared.hideProgressHud()                            //                            GFunction.shared.removeLoader()
                    //                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //                        }
                    
                    var statusCode = 0
                    
                    //Logout User
                    if let headerResponse = response.response {
                        statusCode = headerResponse.statusCode
                        if (headerResponse.statusCode == 404) {
                            //TODO: - Add your logout code here
                            //                                GFunction.shared.userLogOut(self.appDelegate.window)
                        }
                    }
                    
                    //Display error Alert if errorAlert is true
                    if(errorAlert) {
                        let err = error as NSError
                        if statusCode != 401
                            && err.code != NSURLErrorTimedOut
                            && err.code != NSURLErrorNetworkConnectionLost
                            && err.code != NSURLErrorNotConnectedToInternet{
                            
                        } else {
                            print(error.localizedDescription)
                        }
                    }
                    
                    //                        let alert = GPAlert(title: "Formee" , message: error.localizedDescription)
                    //                        AlertManager.shared.show(alert)
                    
                    completion(nil, statusCode)
                }
            }
        })
        
    }
}

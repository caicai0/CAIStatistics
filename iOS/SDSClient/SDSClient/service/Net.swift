//
//  Net.swift
//  SDSClient
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 cai. All rights reserved.
//

import UIKit
import Alamofire

@objc class Net: NSObject {
    
    open var baseUrl:String = "http://localhost";
    
    static let shared = Net()
    
    open func post(_: Dictionary<String,Any>) {
        
    }
    
    open func login(userName:String,password:String,finish:(_ token:String,_ error:Error)->Void){
        let loginApi = baseUrl+"/user/login";
        let parameters = ["userName":userName,"password":password]
        Alamofire.request(loginApi, method: .post, parameters: parameters, encoding:JSONEncoding() as ParameterEncoding, headers: nil).responseJSON { (res) in
            debugPrint("firstMethod --> responseJSON --> \(res)")
            if let json = res.result.value {
                print("firstMethod --> responseJSON --> \(json)")
            }
        }
    }
} 

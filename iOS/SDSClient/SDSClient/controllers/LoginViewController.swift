//
//  LoginViewController.swift
//  SDSClient
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 cai. All rights reserved.
//

import UIKit
import Alamofire

@objc class LoginViewController: UIViewController {

    @IBOutlet weak var serverTfd: UITextField!
    @IBOutlet weak var userNameTfd: UITextField!
    @IBOutlet weak var passwordTfd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: UIButton) {
        guard let server = serverTfd.text else {return}
        guard let username = userNameTfd.text else {return}
        guard let password = passwordTfd.text else {return}
        
        let loginPath = String(format: "%@/user/login",server)
        request(loginPath, method: .post, parameters: ["userName":username,"password":password], encoding: JSONEncoding() as ParameterEncoding, headers: nil).responseJSON { (res) in
            debugPrint("firstMethod --> responseJSON --> \(res)")
            if let json = res.result.value {
                print("firstMethod --> responseJSON --> \(json)")
                /*  返回请求地址、数据、和状态结果等信息
                 print("firstMethod --> responseJSON() --> \(returnResult.request!)")
                 print("firstMethod --> responseJSON() --> \(returnResult.data!)")
                 print("firstMethod --> responseJSON() --> \(returnResult.result)")
                 */
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

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

    @IBOutlet weak var userNameTfd: UITextField!
    @IBOutlet weak var passwordTfd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: UIButton) {
        guard let username = userNameTfd.text else {return}
        guard let password = passwordTfd.text else {return}
        Net.shared.login(userName: username, password: password) { (token, error) in
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

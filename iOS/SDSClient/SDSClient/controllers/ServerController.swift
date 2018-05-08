//
//  ServerController.swift
//  SDSClient
//
//  Created by cai on 2018/4/16.
//  Copyright © 2018年 cai. All rights reserved.
//

import UIKit

class ServerController: UIViewController {

    
    @IBOutlet weak var serverTfd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let serverUrl = UserDefaults.standard.value(forKey: "serverUrl")
        if serverUrl != nil {
            serverTfd.text = serverUrl as? String
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func sure(_ sender: UIButton) {
        let serverurl = serverTfd.text;
        if (serverurl?.count)!>0 {
            Net.shared.baseUrl = serverurl!
            
            UserDefaults.standard.set(serverurl, forKey: "serverUrl")
            self.performSegue(withIdentifier: "LoginViewController", sender: nil)
        }else{
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

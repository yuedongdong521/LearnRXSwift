//
//  MoyaRequestViewController.swift
//  LearnRXSwift
//
//  Created by ydd on 2020/5/28.
//  Copyright © 2020 ydd. All rights reserved.
//

import UIKit
import Moya



class MoyaRequestViewController: UITableViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            testMoya()
        case 1:
            GetRequest(requestUrl: URL(string: "http://ip-api.com/json/ydd")!, { (data, errorCode) in
                
            }) { (code, mesg) in
                
            }
        case 2:
            testSmscodeAPI()
        default:
            break
        }
        
    }

   
}

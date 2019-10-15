//
//  NetworkCheckManager.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/9/3.
//  Copyright © 2019 ydd. All rights reserved.
//

import Foundation
import Alamofire

class NetworkCheckManager {
    
    lazy var checkManager: NetworkReachabilityManager? = {
        guard let checkManager = NetworkReachabilityManager.init() else { return nil }
        return checkManager
    }()
    
    static let shareManager = NetworkCheckManager()
  
    func startCheck() {
        checkManager?.listener = { status in
            print("网络状态：\(status)")
        }
        checkManager?.startListening()
    }
    
    func isAilble() -> Bool {
        return checkManager?.isReachable ?? false
    }
    
    
}




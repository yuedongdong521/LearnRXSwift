//
//  DefaultValidationService.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/28.
//  Copyright © 2019 ydd. All rights reserved.
//


import RxSwift
import Foundation

import struct Foundation.CharacterSet
import struct Foundation.URL
import struct Foundation.URLRequest
import struct Foundation.NSRange
import class Foundation.URLSession
import func Foundation.arc4random


class DefaultValidationService: AppValidationService {
    
    let API: LogonAPI
    
    init(API: LogonAPI) {
        self.API = API
    }
    
   
    static let sharedService = DefaultValidationService(API: AppDefaultAPI.sharedAPI)
    
     let minPasswordCount = 5
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return API
        .usernameAvailable(username)
        .map {available in
            if available {
                return .ok(message: "用户名可用")
            } else {
                return .failed(message: "用户名已占用")
            }
        }
        .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
        if numberOfCharacters == 0 {
            return .empty
        }
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "密码必须大于\(minPasswordCount)个字符")
        }
        return .ok(message: "密码可用")
    }
    
    func validateRepatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "密码正确")
        } else {
            return .failed(message: "密码不统一")
        }
    }
    
    
}



class AppDefaultAPI: LogonAPI {
    let URLSession: Foundation.URLSession
    
    static let sharedAPI = AppDefaultAPI(URLSession: Foundation.URLSession.shared)
    
    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }
    
    func usernameAvailable(_ userName: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(userName.URLEscaped)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        return self.URLSession.rx.response(request: request)
            .map{ pair in
                return pair.response.statusCode == 404
        }
        .catchErrorJustReturn(false)
        
    }
    
    func logon(_ userName: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signupResult)
        .delay(.seconds(1), scheduler: MainScheduler.instance)
        
    }
    
    
}

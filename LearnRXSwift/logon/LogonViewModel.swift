//
//  LogonViewModel.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/27.
//  Copyright © 2019 ydd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LogonViewModel {

    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>
    let signupEnabled: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>
    
    init(input: (
            username: Observable<String>,
            password: Observable<String>,
            repeatedPassword: Observable<String>,
            loginTaps: Observable<Void>
        ),
         dependency:(
            API: LogonAPI,
            validationService: AppValidationService,
            wireframe: Wireframe
        )) {
    
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe
        
        validatedUsername = input.username
            .flatMapLatest { username in
                return validationService.validateUsername(username)
                        .observeOn(MainScheduler.instance)
                        .catchErrorJustReturn(.failed(message: "连接服务器失败"))
        }.share(replay: 1)
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
        }.share(replay: 1)
        
        validatedPasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepatedPassword).share(replay: 1, scope: .forever)
        
       
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) {
            (username: $0, passwd: $1)
        }
        
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { pair in
                return API.logon(pair.username, password: pair.passwd)
                          .observeOn(MainScheduler.instance)
                          .catchErrorJustReturn(false)
                          .trackActivity(signingIn)
        }
            .flatMapLatest { loggedIn -> Observable<Bool> in
                let messahe = loggedIn ? "注册成功" : "注册失败"
                return wireframe.promptFor(messahe, cancelAction: "ok", actions: [])
                    .map {_ in
                        loggedIn
                }
                
        }
        .share(replay: 1, scope: .forever)
        
    
        signupEnabled = Observable.combineLatest (
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated,
            signingIn.asObservable()
        ) { username, password, repeatPassword, signingIn in

            username.isValid &&
            password.isValid &&
            repeatPassword.isValid &&
            !signingIn
        }
        .distinctUntilChanged()
        .share(replay: 1, scope: .forever)
    }
    
    
    
    
}

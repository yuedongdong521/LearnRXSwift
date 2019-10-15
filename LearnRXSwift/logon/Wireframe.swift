//
//  Wireframe.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/27.
//  Copyright © 2019 ydd. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

enum RetryResult {
    case retry
    case cancel
}

protocol Wireframe {
    func open(url: NSURL)
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions:[Action]) -> Observable<Action>
    
}

class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()
    
    func open(url: NSURL) {
        UIApplication.shared.openURL(url as URL)
    }
    
    private static func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>  {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })
            
            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                    observer.on(.next(action))
                })
            }

            
//
            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: {

            })
            
//            DefaultWireframe.rootViewController().dismiss(animated: true, completion: nil)
            
            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
            
        }
    }
}

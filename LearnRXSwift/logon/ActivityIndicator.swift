//
//  ActivityIndicator.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/28.
//  Copyright © 2019 ydd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
  
    
   
    private let _source: Observable<E>
    private let _dispose: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
      _dispose.dispose()
    }
    func asObservable() -> Observable<E> {
        return _source
    }
}


public class ActivityIndicator: SharedSequenceConvertibleType {
   
    public typealias SharingStrategy = DriverSharingStrategy
    public typealias Element = Bool
    
    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        _loading = _relay.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }
    
    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }
    private func decrement() {
        _lock.lock()
        _relay.accept(_relay.value - 1)
        _lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Bool> {
        return _loading
    }
    
}


extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}

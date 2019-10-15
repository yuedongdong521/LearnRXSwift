//
//  LoginViewController.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/26.
//  Copyright © 2019 ydd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let minUserLength = 5
private let minPassLength = 5


class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    
    @IBOutlet weak var userTips: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passTips: UILabel!
    
    @IBOutlet weak var logon: UIButton!
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        userTips.text = "账号不少于\(minUserLength)个字符"
        passTips.text = "密码不少于\(minPassLength)个字符"
        
        let userValid = userTextField.rx.text.orEmpty
            .map { (text) in
                return text.count >= minUserLength
        }
            .share(replay: 1, scope: .forever)
        
        let passValid = passwordTextField.rx.text.orEmpty
            .map{ $0.count >= minPassLength }
            .share(replay: 1, scope: .forever)
        
        let everythingValid = Observable.combineLatest(
            userValid,
            passValid
        ) {$0 && $1}
        .share(replay: 1, scope: .forever)
        
        userValid
            .bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        userValid
            .bind(to: userTips.rx.isHidden)
            .disposed(by: disposeBag)
        
        passValid
            .bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
       
        passValid
            .bind(to: passTips.rx.isHidden)
            .disposed(by: disposeBag)
        
        everythingValid
            .bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginBtn.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert(message:"成功") }, onError: { [weak self] error in  self?.showAlert(message: "失败")}, onCompleted: {[weak self] in self?.showAlert(message: "完成")}, onDisposed: {[weak self] in self?.showAlert(message: "Disposed")})
        .disposed(by: disposeBag)
        
        logon.rx.tap
            .subscribe(onNext: { [weak self] _ in
//                self?.present(LogonViewController(), animated: true, completion: {
//
//                })
                self?.navigationController?.pushViewController(LogonViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        
    }


    func showAlert(message msg:String) {
        let alertView = UIAlertController.init(title: "提示", message: msg, preferredStyle: .alert)
        alertView.addAction(UIAlertAction.init(title: "确定", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

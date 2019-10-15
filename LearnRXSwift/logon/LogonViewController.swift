//
//  LogonViewController.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/28.
//  Copyright © 2019 ydd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LogonViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var nameTips: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passTips: UILabel!
    
    @IBOutlet weak var repPassTextField: UITextField!
    
    @IBOutlet weak var repTips: UILabel!
    
    @IBOutlet weak var logonBtn: UIButton!
    
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let viewModel = LogonViewModel(
            input: (
                username: nameTextField.rx.text.orEmpty.asObservable(),
                password: passwordTextField.rx.text.orEmpty.asObservable(),
                repeatedPassword: repPassTextField.rx.text.orEmpty.asObservable(),
                loginTaps: logonBtn.rx.tap.asObservable()
            ),
            dependency: (
                API: AppDefaultAPI.sharedAPI,
                validationService: DefaultValidationService.sharedService,
                wireframe: DefaultWireframe.shared)
        )
        
        viewModel.signupEnabled
            .subscribe(onNext: { [weak self] valid in
                self?.logonBtn.isEnabled = valid
                self?.logonBtn.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        viewModel.validatedUsername
            .bind(to: nameTips.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bind(to: passTips.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPasswordRepeated
            .bind(to: repTips.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .bind(to: loading.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe(onNext: { sinedin in
                print("用户注册： \(sinedin)")
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: {[weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapBackground)
        
    }


//    @IBAction func logonAction(_ sender: Any) {
//
//
//
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

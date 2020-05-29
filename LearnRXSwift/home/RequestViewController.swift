//
//  RequestViewController.swift
//  LearnRXSwift
//
//  Created by ydd on 2020/5/28.
//  Copyright © 2020 ydd. All rights reserved.
//

import UIKit
import SnapKit

class RequestViewController: UIViewController {

    private func createBtn(type:RequestType) -> UIButton {
        let btn = UIButton.init(type: .custom)
        btn.tag = type.rawValue
        btn.setTitle(type.decription(), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .cyan
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
        return btn
    }
    
    @objc func btnAction(btn:UIButton) {
        
        
        
        let completed = {(data:Any?, error:Error?) in
            
        }
        
        let type : RequestType = RequestType(rawValue: btn.tag) ?? .get
        switch type {
        case .get:
            let urlStr = "http://ip-api.com/json"
            AlamofireGETRequest(url: urlStr, completed: completed)
            break
        case .post:
            
            break
        case .download:
            AlamofireDownLoad(url: "http://onapp.yahibo.top/public/videos/video.mp4") { (file) in
                print(file)
            }
            break
        case .backgroundLoad:
            AlamofireBackgroundDownload(videoUrl: "http://onapp.yahibo.top/public/videos/video.mp4")
            break
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        let alamofireList:[RequestType] = [.get, .post, .download, .upload, .backgroundLoad, .redirestAdapter, .retrier, .verification]
        var y = 100
        for i in 0..<alamofireList.count {
            let btn = createBtn(type: alamofireList[i])
            self.view.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.top.equalTo(y)
                make.height.equalTo(30)
                make.right.equalTo(-20)
            }
            y += 50
        }
        
        
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

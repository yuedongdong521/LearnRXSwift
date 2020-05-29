//
//  HomeViewController.swift
//  LearnRXSwift
//
//  Created by ydd on 2020/5/28.
//  Copyright © 2020 ydd. All rights reserved.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let listArr = [NSStringFromClass(RequestViewController.classForCoder()),
                   NSStringFromClass(MoyaRequestViewController.classForCoder())]
    
    private lazy var tableView : UITableView = {
        let tab = UITableView(frame: CGRect.zero, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tab
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
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

extension HomeViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = listArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            self.pushViewController(vc: RequestViewController.init())
        case 1:
            self.pushViewController(vc: MoyaRequestViewController.init())
        default:
            break
        }
    }
    
    func pushViewController(vc:UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

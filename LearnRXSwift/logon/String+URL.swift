//
//  String+URL.swift
//  LearnRXSwift
//
//  Created by ydd on 2019/8/29.
//  Copyright © 2019 ydd. All rights reserved.
//

import Foundation

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

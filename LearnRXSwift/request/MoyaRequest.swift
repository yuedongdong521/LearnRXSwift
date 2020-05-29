//
//  MoyaRequest.swift
//  LearnRXSwift
//
//  Created by ydd on 2020/5/28.
//  Copyright © 2020 ydd. All rights reserved.
//

import Foundation
import Moya

enum MyService {
    case zen
    case showUser(id: Int)
    case createUser(firstName: String, lastName: String)
    case updateUser(id: Int, firstName: String, lastName: String)
    case showAccounts
}

extension MyService: TargetType {
    /// 请求域名地址
    var baseURL: URL {
        return URL(string: "http://ip-api.com")!
    }
    /// 请求地址路径
    var path: String {
        switch self {
            case .zen:
                return "/json"
            case .showUser(let id), .updateUser(let id, _, _):
                return "/user/\(id)"
            case .createUser(_, _):
                return "/users"
            case .showAccounts:
                return "/accounts"
        }
    }
    
    /// 请求类型
    var method: Moya.Method {
        switch self {
            case .zen, .showAccounts, .showUser:
                return .get
            case .createUser, .updateUser:
                return .post
        }
    }
    
    /// 用于单元测试
    var sampleData: Data {
        switch self {
        case .zen:
            let str = "Half measures are as bad as nothing at all."
            return str.data(using: .utf8)!
        case .showUser(let id):
            return "{\"id\": \(id), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".data(using: .utf8)!
        case .createUser(let firstName, let lastName):
            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".data(using: .utf8)!
        case .updateUser(let id, let firstName, let lastName):
            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".data(using: .utf8)!
        case .showAccounts:
            // Provided you have a file named accounts.json in your bundle.
            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    /// 请求参数
    var task: Task {
        switch self {
        case .zen, .showUser, .showAccounts: // 没有参数
            return .requestPlain
        case let .updateUser(_, firstName, lastName): /// 直接拼接在url上的参数
            return .requestParameters(parameters: ["first_name": firstName, "last_name" : lastName], encoding: URLEncoding.queryString)
        case let .createUser(firstName, lastName): /// body参数,json格式
            return .requestParameters(parameters:  ["first_name": firstName, "last_name" : lastName], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}


private extension String {
    // url encode
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    var utf8Encoded: Data? {
        return data(using: .utf8)
    }
    
}


let endpointClosure = { (target: MyService) -> Endpoint in
    print(URL(target: target).absoluteString)
    return Endpoint(url: URL(target: target).absoluteString, sampleResponseClosure: { () -> EndpointSampleResponse in
        
        return .networkResponse(200, target.sampleData)
    }, method: target.method, task: target.task, httpHeaderFields: nil)
}
//
//let failureEndpointClosure = { (target : MyService) -> Endpoint in
//    let sampleResponseClosure = { () -> (EndpointSampleResponse) in
//        if shouldTimeout {
//            return .networkError(NSError())
//        }
//
//    }
//}



/// 单元测试调用方法
func testSmscodeAPI() {
    let provitder = MoyaProvider<MyService>(stubClosure: MoyaProvider.immediatelyStub)
    provitder.request(.zen) { (result) in
        switch result {
        case let .success(moyaResponse):
            let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
            let data = String.init(data: moyaResponse.data, encoding: String.Encoding.utf8)
            print("\(statusCode)")
            print(data ?? "no data")
        case .failure(_):
            break
        }
    }
 
}


func testMoya() {
    
    let provider = MoyaProvider(endpointClosure: endpointClosure)
    provider.request(.zen) { result in
        switch result {
        case let .success(moyaResponse):
            let data = moyaResponse.data // Data, your JSON response is probably in here!
            let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
            
            let str = String(data: data, encoding: .utf8)
            print(str)
        // do something in your app
        case let .failure(error):
            print(error)
            break
            // TODO: handle the error == best. comment. ever.
        }
    }
}


func creatProvider(timeInterval:TimeInterval  = 15) -> MoyaProvider<MyService> {
    return MoyaProvider<MyService>(
        requestClosure: { (endPoint, closure) in
            do {
                var urlRequest = try endPoint.urlRequest()
                urlRequest.timeoutInterval = timeInterval;
                closure(.success(urlRequest))
            } catch MoyaError.requestMapping(let url) {
                closure(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                closure(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
    })
    
}

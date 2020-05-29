//
//  AlamofireRequest.swift
//  LearnRXSwift
//
//  Created by ydd on 2020/5/28.
//  Copyright © 2020 ydd. All rights reserved.
//

import Foundation
import Alamofire

/// 设置公共参数
class CustomAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue("hibotoken", forHTTPHeaderField: "token")
        request.setValue("device", forHTTPHeaderField: "iOS")
        request.setValue("vision", forHTTPHeaderField: "1.0.0")
        return request
    }
}

/// 请求重定向
class redireatAdapter: RequestAdapter{
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        let newURLRequest = URLRequest.init(url: URL.init(string: "http://onapp.yahibo.top/public/?s=api/test")!)
        return newURLRequest
    }
}

class MyRetrier: RequestRetrier{
    var count: Int = 0
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        /// 设定重新发送请求3次
        /// 延时2秒再发送请求
        if count<3 {
            completion(true,2)
            count += 1
        }else{
            completion(false,2)
        }
    }
}

enum RequestType :Int {
    case get = 0
    case post
    case download
    case upload
    case backgroundLoad
    case redirestAdapter
    case retrier
    case verification
    
    func decription() -> String {
        
        switch self {
        case .get:
            return "GET请求"
        case .post:
            return "POST请求"
        case .download:
            return "文件下载"
        case .upload:
            return "上传表单"
        case .backgroundLoad:
            return "后台下载"
        case .redirestAdapter:
            return "请求重定向"
        case .retrier:
            return "重新请求"
        case .verification:
            return "自定义验证"
        }
    }
}

func AlamofireGETRequest(url:String, completed:@escaping (_ data:Any?, _ err:Error?)->Void) {
    /// 设置header方法
    /// Alamofire.SessionManager.default.adapter = CustomAdapter()
    
    /// 请求重定向使用方法，修改请求url
    /// Alamofire.SessionManager.default.adapter = redireatAdapter()
    
    /// 重新请求, 请求失败时重新请求3次，每次间隔两秒
    /// Alamofire.SessionManager.default.retrier = MyRetrier()
    
    Alamofire.request(url).responseJSON { (response) in
        switch response.result {
            case .success(let json):
                print(url + "\n json:\(json)")
                completed(json, nil)
                
            case .failure(let error):
                print(url + "\n error:\(error)")
                completed(nil, error)
            
        }
    }
}

func AlamofirePOSTRequest(url:String, parameters:[String:Any], completed:@escaping (_ data:Any?, _ err:Error?)->Void) {
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (responds) in
        switch responds.result {
            case .success(let json):
                print(url + "\n json:\(json)")
                completed(json, nil)
            
            case .failure(let error):
                print(url + "\n error:\(error)")
                completed(nil, error)
        }
    }
}

func downloadSavePath(name:String) -> URL {
    let cachPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    return cachPath.appendingPathComponent("\(name.hashValue).mp4")
    
}

func AlamofireDownLoad(url:String, completed:@escaping (_ videoFilePath:String) -> Void) {
    
    let videoUrl = "http://onapp.yahibo.top/public/videos/video.mp4"
  
    Alamofire.download(videoUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, to:  { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
        let fileURL = downloadSavePath(name: url.absoluteString)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }).downloadProgress { (progress) in
        print(url + "dlownProgress : \(progress)")
        
    }
}

func AlamofireUpload(url:String, prarmeters:[UIImage]) {
    
    Alamofire.upload(multipartFormData: { (formData) in
        formData.append("hibo".data(using: .utf8)!, withName: "name")
        formData.append("123456".data(using: .utf8)!, withName: "password")
        for i in 0 ... prarmeters.count-1 {
            let data = prarmeters[i].pngData()
            let fileName = "image_\(i).png"
            formData.append(data!, withName: "image[]", fileName: fileName, mimeType: "image/png")
        }
    }, to: url) { (result) in
        switch result {
        case .success(let upload, _, _):
            upload.uploadProgress(closure: { (progress) in
                print(progress)
            }).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    break
                case .failure(let error):
                    print("error:\(error)")
                    break
                }
            })
            break
        case .failure(let error):
            print(error)
            break
        }
        print("result:\(result)")
    }
}


struct BackgroundManager {
    static let shared = BackgroundManager()
    let manager: SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier:"com.yahibo.background_id")
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
}

func AlamofireBackgroundDownload(videoUrl:String)  {
    BackgroundManager.shared.manager.download(videoUrl) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
        let fileURL = downloadSavePath(name: videoUrl)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }.downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
        print(progress)
    }.response(queue: DispatchQueue.global(qos: .utility), completionHandler: { (response) in
        
        print("完成下载：\(response) statue : \(String(describing: response.response?.statusCode))")
    })
}

/// 自定义验证，自定义错误提示
func AlamofireR() {
    let urlStr = "http://onapp.yahibo.top/public/?s=api/test/list2"
    let url = URL.init(string: urlStr)!
    Alamofire.SessionManager.default.retrier = MyRetrier()
    Alamofire.request(url).responseJSON {
        (response) in
        switch response.result{
        case .success(let json):
            print("json:\(json)")
            break
        case .failure(let error):
            print("error:\(error)")
            break
        }
    }.validate{ (request, response, data) -> Request.ValidationResult in
        print(response)
        guard let _ = data else {
            return .failure(NSError(domain: "没有数据啊", code: 10086, userInfo: nil))
        }
        if response.statusCode == 404 {
            return .failure(NSError(domain: "密码错误", code: response.statusCode, userInfo: nil))
        }
        return .success
    }
}


func GetRequest(requestUrl url: URL, _ successBlock:( (_ data: Data?, _ errorCode: Int) -> Void)?, _ failureBlock:( (_ errorCode: Int, _ message: String?) -> Void)?) {
    let task = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main).dataTask(with: url) { (data, response, error) in
        if error == nil {
            guard successBlock == nil else {
                return successBlock!(data, 0)
            }
            
        } else {
            guard failureBlock == nil else {
               return failureBlock!(0, "失败")
            }
        }
    }
    task.resume()
}

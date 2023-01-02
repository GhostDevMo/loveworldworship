//
//  BankTransferManager.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/26/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK
class BankTransferManager{
    static let instance = BankTransferManager()
    func sendReceipt(AccesToken: String,mode:String,mediaData:Data?, completionBlock: @escaping (_ Success:BankTransferModel.BankTransferSuccessModel?,_ sessionError:BankTransferModel.sessionErrorModel?, Error?) ->()){
            
            let params = [
                API.Params.AccessToken : AccesToken,
                 API.Params.mode : mode,
                API.Params.ServerKey : API.SERVER_KEY.Server_Key
                ] as [String : Any]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
            let decoded = String(data: jsonData, encoding: .utf8)!
            log.verbose("Decoded String = \(decoded)")
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]
        AF.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                    if let data = mediaData{
                        multipartFormData.append(data, withName: "receipt_img", fileName: "media.jpg", mimeType: "image/png")
                }
                
        }, to: API.Bank_Transfer_Methods.BANK_TRANSFER_API, usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON { (response) in
            print("Succesfully uploaded")
            log.verbose("response = \(response.value)")
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(BankTransferModel.BankTransferSuccessModel.self, from: data)
                    log.debug("Success = \(result.status ?? 0)")
                    completionBlock(result,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                   
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(BankTransferModel.sessionErrorModel.self, from: data)
                        log.error("AuthError = \(result.error ?? "")")
                        completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
            }
        }
}

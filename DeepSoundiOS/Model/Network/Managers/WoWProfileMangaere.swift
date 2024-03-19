//
//  WoWProfileMangaere.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/1/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK


class WoWProfileManager {
    
    static let instance = WoWProfileManager()
    
    func WoWonderUserData(userId : String, access_token: String, completionBlock: @escaping(_ Success: String?, _ AuthError: LoginWithWoWonderModel.LoginWithWoWonderErrorModel?, Error?) -> () ) {
        let params = [
            API.Params.ServerKey : ControlSettings.wowonder_ServerKey,
            API.Params.user_id : userId,
            API.Params.Fetch : "user_data"
        ] as [String : Any]
        AF.request(API.AUTH_WOWONDER_METHODS.USER_DATA_API + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String: Any] {
                guard let apiStatusCode = res["api_status"] else { return }
                if apiStatusCode is Int {
                    let base64String = self.jsonToBaseString(yourJSON: res)
                    completionBlock(base64String, nil, nil)                    
                } else {
                    let data = try! JSONSerialization.data(withJSONObject: res, options: [])
                    let result = try! JSONDecoder().decode(LoginWithWoWonderModel.LoginWithWoWonderErrorModel.self, from: data)
                    completionBlock(nil, result, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func jsonToBaseString(yourJSON: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: yourJSON, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData.base64EncodedString(options: .endLineWithCarriageReturn)
        } catch {
            return nil
        }
    }
    
}

//
//  AlbumManager.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 10/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import DeepSoundSDK

class AlbumManager{
    static let instance = AlbumManager()
    
    
    func getAlbumSongs(albumId:Int,AccessToken:String,completionBlock: @escaping (_ Success:GetAlbumSongsModel.GetAlbumSongsSuccessModel?,_ SessionError:GetAlbumSongsModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Id: albumId,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Album_Methods.GET_ALBUM_SONG_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Album_Methods.GET_ALBUM_SONG_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
               
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(GetAlbumSongsModel.GetAlbumSongsSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(GetAlbumSongsModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func deleteAlbum(albumId:Int,AccessToken:String,type:String,completionBlock: @escaping (_ Success:DeleteAlbumModel.DeleteAlbumSuccessModel?,_ SessionError:DeleteAlbumModel.sessionErrorModel?, Error?) ->()){
           let params = [
               
               API.Params.AccessToken: AccessToken,
               API.Params.Id: albumId,
               API.Params.type: type,
               API.Params.ServerKey: API.SERVER_KEY.Server_Key
               
               ] as [String : Any]
           
           let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
           let decoded = String(data: jsonData, encoding: .utf8)!
           log.verbose("Targeted URL = \(API.Album_Methods.DELETE_ALBUM_SONG_API)")
           log.verbose("Decoded String = \(decoded)")
        AF.request(API.Album_Methods.DELETE_ALBUM_SONG_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
               
               if (response.value != nil){
                   guard let res = response.value as? [String:Any] else {return}
                  
                   guard let apiStatus = res["status"]  as? Int else {return}
                   if apiStatus ==  API.ERROR_CODES.E_TwoH{
                       log.verbose("apiStatus Int = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(DeleteAlbumModel.DeleteAlbumSuccessModel.self, from: data)
                       completionBlock(result,nil,nil)
                   }else{
                       log.verbose("apiStatus String = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                       let result = try! JSONDecoder().decode(DeleteAlbumModel.sessionErrorModel.self, from: data)
                       log.error("AuthError = \(result.error ?? "")")
                       completionBlock(nil,result,nil)
                   }
               }else{
                   log.error("error = \(response.error?.localizedDescription ?? "")")
                   completionBlock(nil,nil,response.error)
               }
           }
       }
    func submitAlbum(AccessToken:String,AlbumTitle:String,AlbumDescription:String,AlbumGenreGenresString:String,AlbumPriceString:String,thumbnailPath:String,completionBlock: @escaping (_ Success:UploadAlbumModel.UploadAlbumSuccessModel?,_ SessionError:UploadAlbumModel.sessionErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.AccessToken: AccessToken,
            API.Params.Title: AlbumTitle,
            API.Params.Description: AlbumDescription,
            API.Params.CategoryId: AlbumGenreGenresString,
            API.Params.albumPrice: AlbumPriceString,
            API.Params.albumthumbnail: thumbnailPath,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
            
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Album_Methods.SUBMIT_ALBUM_SONG_API)")
        log.verbose("Decoded String = \(decoded)")
        AF.request(API.Album_Methods.SUBMIT_ALBUM_SONG_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                
                guard let apiStatus = res["status"]  as? Int else {return}
                if apiStatus ==  API.ERROR_CODES.E_TwoH{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(UploadAlbumModel.UploadAlbumSuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    log.verbose("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(UploadAlbumModel.sessionErrorModel.self, from: data)
                    log.error("AuthError = \(result.error ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    func updateAlbum(AccessToken:String,albumID:String,AlbumTitle:String,AlbumDescription:String,AlbumGenreGenresString:String,AlbumPriceString:String,thumbnailPath:String,completionBlock: @escaping (_ Success:UploadAlbumModel.UploadAlbumSuccessModel?,_ SessionError:UploadAlbumModel.sessionErrorModel?, Error?) ->()){
           let params = [
               
               API.Params.AccessToken: AccessToken,
                API.Params.albumId: albumID,
               API.Params.Title: AlbumTitle,
               API.Params.Description: AlbumDescription,
               API.Params.CategoryId: AlbumGenreGenresString,
               API.Params.albumPrice: AlbumPriceString,
               API.Params.albumthumbnail: thumbnailPath,
               API.Params.ServerKey: API.SERVER_KEY.Server_Key
               
               ] as [String : Any]
           
           let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
           let decoded = String(data: jsonData, encoding: .utf8)!
           log.verbose("Targeted URL = \(API.Album_Methods.UPDATE_ALBUM_SONG_API)")
           log.verbose("Decoded String = \(decoded)")
        AF.request(API.Album_Methods.UPDATE_ALBUM_SONG_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
               
               if (response.value != nil){
                   guard let res = response.value as? [String:Any] else {return}
                   
                   guard let apiStatus = res["status"]  as? Int else {return}
                   if apiStatus ==  API.ERROR_CODES.E_TwoH{
                       log.verbose("apiStatus Int = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                       let result = try! JSONDecoder().decode(UploadAlbumModel.UploadAlbumSuccessModel.self, from: data)
                       completionBlock(result,nil,nil)
                   }else{
                       log.verbose("apiStatus String = \(apiStatus)")
                       let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                       let result = try! JSONDecoder().decode(UploadAlbumModel.sessionErrorModel.self, from: data)
                       log.error("AuthError = \(result.error ?? "")")
                       completionBlock(nil,result,nil)
                   }
               }else{
                   log.error("error = \(response.error?.localizedDescription ?? "")")
                   completionBlock(nil,nil,response.error)
               }
           }
       }
    func PurchaseAlbum(AccessToken:String,albumId:String,userID:Int,via:String,completionBlock: @escaping (_ Success:PurchaseAlbumModel.PurchaseAlbumSuccessModel?,_ SessionError:PurchaseAlbumModel.sessionErrorModel?, Error?) ->()){
          let params = [
              
              API.Params.AccessToken: AccessToken,
              API.Params.user_id: userID,
              API.Params.albumId: albumId,
              API.Params.via: via,
              API.Params.ServerKey: API.SERVER_KEY.Server_Key
              
              ] as [String : Any]
          
          let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
          let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Targeted URL = \(API.Album_Methods.PURCHASE_ALBUM_API)")
          log.verbose("Decoded String = \(decoded)")
        AF.request(API.Album_Methods.PURCHASE_ALBUM_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
              
              if (response.value != nil){
                  guard let res = response.value as? [String:Any] else {return}
                  
                  guard let apiStatus = res["status"]  as? Int else {return}
                  if apiStatus ==  API.ERROR_CODES.E_TwoH{
                      log.verbose("apiStatus Int = \(apiStatus)")
                      let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(PurchaseAlbumModel.PurchaseAlbumSuccessModel.self, from: data)
                      completionBlock(result,nil,nil)
                  }else{
                      log.verbose("apiStatus String = \(apiStatus)")
                      let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                      let result = try! JSONDecoder().decode(PurchaseAlbumModel.sessionErrorModel.self, from: data)
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

//
//  GitUserInfo.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 6..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class GitUserInfo {
    var seq : Int?
    var loginId : String
    var avatarUrl : String
    var bookmarkCheck : Bool
    
    init(loginId:String, avatarUrl:String){
        self.loginId = loginId
        self.avatarUrl = avatarUrl
        self.bookmarkCheck = false

    }

    init(seq:Int, loginId:String, avatarUrl:String, bookmarkCheck:String){
        self.seq = seq
        self.loginId = loginId
        self.avatarUrl = avatarUrl
        self.bookmarkCheck = bookmarkCheck == "Y" ? true : false 
    }
    /**
     GitApi 로 부터 받은 json 을 GituserInfo 형식으로 파싱
     */
    static func convertGitUsers( items:Array<[String: Any]> ) ->  Array<GitUserInfo>  {
        var total = Array<GitUserInfo>()
        for ( val ) in items{
            
            if let loginId = val["login"] as? String , let avatarUrl = val["avatar_url"] as? String  {
                let user = GitUserInfo(loginId: loginId, avatarUrl: avatarUrl)
                //기존에 등록되어 있는지 체크
                user.bookmarkCheck = DBManager.shared.checkBookmar(loginId: loginId)
                total.append(user)
                
            }
        }
        return total;
    }
    /**
     GitApi 로 부터 받은 json 을 GituserInfo 형식으로 파싱
     id 의 맨 앞자 ( 영어/한글:초성 ) 으로 맵핑  ->  강문성의 id 일 경우  'ㄱ' 으로 맵핑
     */
    static func convertGitUsers( items:Array<[String: Any]> ) ->  [String:Array<GitUserInfo>]  {
        var total = [String:Array<GitUserInfo>]()
        for ( val ) in items{

            if let loginId = val["login"] as? String , let avatarUrl = val["avatar_url"] as? String  {
                let user = GitUserInfo(loginId: loginId, avatarUrl: avatarUrl)
                //기존에 등록되어 있는지 체크
                user.bookmarkCheck = DBManager.shared.checkBookmar(loginId: loginId)
                
                var firstStr = loginId.substring(to: loginId.index(after: loginId.startIndex))
                firstStr =  Utils.splitText(str: firstStr.lowercased())
                
                if total[firstStr] != nil {
                    total[firstStr]?.append(user)
                }else{
                    total[firstStr] = Array<GitUserInfo>()
                    total[firstStr]?.append(user)
                }

            }
        }
        return total;
    }
    /**
     Local DB  로 부터 받은 GitUserInfo 정보를 맵핑
     id 의 맨 앞자 ( 영어/한글:초성 ) 으로 맵핑  ->  강문성의 id 일 경우  'ㄱ' 으로 맵핑
     */
    static func convertGitUsers( items:Array<GitUserInfo> ) ->  [String:Array<GitUserInfo>]  {
        var total = [String:Array<GitUserInfo>]()
        for ( user ) in items{
            
            var firstStr = user.loginId.substring(to: user.loginId.index(after: user.loginId.startIndex))
            firstStr =  Utils.splitText(str: firstStr.lowercased())
            
            if total[firstStr] != nil {
                total[firstStr]?.append(user)
            }else{
                total[firstStr] = Array<GitUserInfo>()
                total[firstStr]?.append(user)
            }
        }
        return total;
    }
    
    /**
     맵핑의 키값 ( 영어 / 한글:초성 ) 으로 sort 작업
     */
    static func getSectionList( userList : [String:Array<GitUserInfo>] ) -> Array<String>{
        var result = Array<String>()
        for( key, _ ) in userList{
            result.append(key)
        }
        return result.sorted()
    }

    
    
}

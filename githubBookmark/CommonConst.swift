//
//  CommonConst.swift
//  githubBookmark
//
//  Created by bizisolution on 2018. 5. 8..
//  Copyright © 2018년 강문성. All rights reserved.
//

import Foundation

//공통 텍스트 관련 전역변수
struct CommonConst {
    static var strBookmarkRegist = "즐겨찾기에서 추가 할까요 ?"
    static var strBookmarkRegistOk = "추가"
    static var strBookmarkRegistCancel = "취소"
    static var strBookmarkImgEmpy = "star.png"
    static var strBookmarkImgeFull = "starfull.png"
    
    static var strBookmarkRemove = "즐겨찾기에서 삭제할까요?"
    static var strBookmarkRemoveOk = "삭제"
    static var strBookmarkRemoveCancel = "취소"
}
//공통 네트워크 관련 전역변수
struct CommonNetwrok {
    static var urlGithubSearchUrl = "https://api.github.com/search/users?q=%@&page=%d"
}

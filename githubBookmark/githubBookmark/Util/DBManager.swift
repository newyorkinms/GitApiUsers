//
//  DBManager.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 7..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit
import FMDB

class DBManager  {

    static let shared: DBManager = DBManager()
    let databaseFileName = "database.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    let database_name =  "LOCAL_BOOKMKAR"
    let field_seq = "seq"
    let field_login_id = "LOGIN_ID"
    let field_avata_url = "AVATA_URL"
    let field_bookmark_check = "BOOKMARK_CHECK"
    
    init() {
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        
    }

    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            if database != nil {
                // Open the database.
                if database.open() {
                    let createBookmarkTableQuery = "create table \(database_name) ( \(field_seq) INTEGER PRIMARY KEY AUTOINCREMENT , \(field_login_id) TEXT NULL, \(field_avata_url) TEXT NULL, \(field_bookmark_check) TEXT NULL )"
                    do {
                        try database.executeUpdate(createBookmarkTableQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    // At the end close the database.
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        return created
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }else{
                createDatabase()
            }
        }
        if database != nil {
            if database.open() {
                return true
            }
        }
        return false
    }
    
    /**
     즐겨찾기 삽입
     */
    func insertGitUserData(gituser : GitUserInfo ) -> Bool {
        var result = false
        if openDatabase() {
            
            let countQuery = "select count(*) from \(database_name) where \(field_bookmark_check) = 'Y'  and \(field_login_id) = '\(gituser.loginId)' "
            do{
                //기존에 추가된 아이디 인지 체크
                let countResult = try database.executeQuery(countQuery, values: nil)
                while countResult.next(){
                    //result = countResult.int(forColumnIndex: 0) > 0 ? false : true
                    if countResult.int(forColumnIndex: 0) > 1{
                        database.close()
                        return false;
                    }
                }
                
                let bookmarkCheck = gituser.bookmarkCheck ? "Y" : "N"
                let query = "insert into  \(database_name) ( \(field_login_id), \(field_avata_url), \(field_bookmark_check) ) values ( '\(gituser.loginId)', '\(gituser.avatarUrl)', '\(bookmarkCheck)' );"
                if !database.executeStatements(query) {
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
                result = true
            }catch{
                
            }

            database.close()
        }
        return result
    }
    
    /**
     즐겨찾기에 추가된 인원 모두 불러오기
     */
    func selectGituserData() -> Array<GitUserInfo> {
        var userList = Array<GitUserInfo>()
        if openDatabase() {
            
            let query = "select * from \(database_name) where \(field_bookmark_check) = 'Y' "
            do{
                let result = try database.executeQuery(query, values: nil)
                while result.next(){
                    let seq = Int( result.int(forColumn: field_seq) )
                    let gitUserInfo = GitUserInfo.init(seq: seq, loginId: result.string(forColumn: field_login_id)!, avatarUrl: result.string(forColumn: field_avata_url)!, bookmarkCheck: result.string(forColumn: field_bookmark_check)! )
                    userList.append(gitUserInfo)
                }
            }catch{
                print(" selectGituserData error")
            }
            
            database.close()
        }
        return userList
    }
    /**
     검색하여 즐겨찾기에 인원 불러오기
     */
    func selectGituserData(searchName : String ) -> Array<GitUserInfo> {
        var userList = Array<GitUserInfo>()
        if openDatabase() {
            
            let query = "select * from \(database_name) where \(field_bookmark_check) = 'Y'  and \(field_login_id) LIKE '%\(searchName)%' "

            do{
                let result = try database.executeQuery(query, values: nil)
                while result.next(){
                    let seq = Int( result.int(forColumn: field_seq) )
                    let gitUserInfo = GitUserInfo.init(seq: seq, loginId: result.string(forColumn: field_login_id)!, avatarUrl: result.string(forColumn: field_avata_url)!, bookmarkCheck: result.string(forColumn: field_bookmark_check)! )
                    userList.append(gitUserInfo)
                }
            }catch{
                print(" selectGituserData error")
            }
            
            database.close()
        }
        return userList
    }
    /**
     Gituser 삭제
     */
    func deleteGituserData(gituser : GitUserInfo ) -> Bool{
        var result = false
        if openDatabase(){
            let query = "delete from \(database_name) where seq = \( Int( gituser.seq ))"
            do{
                try database.executeUpdate(query, values: nil)
                result = true
            }catch{
                print("deleteGituserData error ")
            }
            database.close()
        }
        
        return result
    }
    /**
     즐겨찾기에 추가되었는지 확인
     */
    func checkBookmar( loginId : String ) -> Bool {
        var check = false
        if openDatabase() {
            
            var query = "select * from \(database_name) where \(field_login_id) = '\(loginId)' "
            do{
                
                let result = try database.executeQuery(query, values: nil)
                while result.next(){
                    let seq = Int( result.int(forColumn: field_seq) )
                    let gitUserInfo = GitUserInfo.init(seq: seq, loginId: result.string(forColumn: field_login_id)!, avatarUrl: result.string(forColumn: field_avata_url)!, bookmarkCheck: result.string(forColumn: field_bookmark_check)! )
                    check = gitUserInfo.bookmarkCheck
                    break;
                }
            }catch{
                
            }
            
            database.close()
        }
        return check
    }
}

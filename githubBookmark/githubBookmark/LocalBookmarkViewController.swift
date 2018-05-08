//
//  LocalBookmarkViewController.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 7..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class LocalBookmarkViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblUsers: UITableView!
    
    var dataList = [String:Array<GitUserInfo>]()
    var dataSection = Array<String>()
    var gitApiVc:GitApiViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblUsers.delegate = self
        self.tblUsers.dataSource = self
        self.txtSearch.delegate = self
        
        let nib = UINib.init(nibName: "GitUserTableViewCell", bundle: nil)
        self.tblUsers.register(nib, forCellReuseIdentifier: "GitUserTableViewCell")
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        //처음 화면 열었을 경우 모든 인원을 보여줌.
        
        self.dataList = GitUserInfo.convertGitUsers(items: DBManager.shared.selectGituserData())
        self.dataSection = GitUserInfo.getSectionList(userList: self.dataList )
        self.tblUsers.reloadData()
    }
    
    
    /**
     유저 검색 필드 이벤트 감지
     */
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.count)! > 0 {
            self.gitUserSearchLocal(searchName: textField.text )
        }else{  //빈 문자열일 경우 전체 검색
            self.dataList = GitUserInfo.convertGitUsers(items: DBManager.shared.selectGituserData())
            self.dataSection = GitUserInfo.getSectionList(userList: self.dataList )
            self.tblUsers.reloadData()
            self.tblUsers.reloadSectionIndexTitles()
        }
        self.tblUsers.setContentOffset(.zero, animated: true)
    }
    /**
     특수문자 체크
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Utils.specialChaMatches(text: string){
            return false
        }
        return true
    }
    /**
     키보드 엔터 처리
     */
    @IBAction func txtPrimaryActionTriggered(_ sender: UITextField) {
        self.gitUserSearchLocal(searchName: sender.text )
    }
    
    func gitUserSearchLocal( searchName : String? ){
        if let name = searchName , name.count > 0 {
            self.dataList = GitUserInfo.convertGitUsers(items: DBManager.shared.selectGituserData(searchName: name))
            self.dataSection = GitUserInfo.getSectionList(userList: self.dataList )
            self.tblUsers.reloadSectionIndexTitles()
            self.tblUsers.reloadData()
        }else{
            //빈 값일 경우 초기화
            self.tableReset()
        }
    }
    /**
     테이블 초기화
     */
    func tableReset(){
        self.dataList.removeAll()
        self.dataSection.removeAll()
        self.tblUsers.reloadSectionIndexTitles()
        self.tblUsers.reloadData()
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell", for: indexPath) as! GitUserTableViewCell
        
        let sectionKey = self.dataSection[indexPath.section]
        let userInfo = self.dataList[sectionKey]![ indexPath.row ]
        
        cell.lblUserName.text = userInfo.loginId
        if( userInfo.avataImg.size.width <= 0 ){
            Alamofire.request(userInfo.avatarUrl).responseImage { response in
                if let image = response.result.value {
                    cell.imgProfile.image = image
                }
            }
        }else{
            cell.imgProfile.image = userInfo.avataImg
        }
        
        cell.btnBookmark.accessibilityHint = String(indexPath.section)
        cell.btnBookmark.tag = indexPath.row
        cell.btnBookmark.addTarget(self, action: #selector( LocalBookmarkViewController.bookmarkClick(sender:) ), for: .touchUpInside)
        if( userInfo.bookmarkCheck ){
            let img = UIImage(named: CommonConst.strBookmarkImgeFull)
            cell.btnBookmark.setImage(img, for: .normal)
        }else{
            let img = UIImage(named: CommonConst.strBookmarkImgEmpy)
            cell.btnBookmark.setImage(img, for: .normal)
        }
        return cell
    }
    /**
     테이블 클릭시 해당 테이블 삭제
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let deleteAction:(UIAlertAction) -> Void  = { (action: UIAlertAction) in
            let sectionKey = self.dataSection[indexPath.section]
            let userInfo = self.dataList[sectionKey]![ indexPath.row ]
            if DBManager.shared.deleteGituserData(gituser: userInfo) {
                self.dataList[sectionKey]?.remove(at: indexPath.row)
                self.dataSection = GitUserInfo.getSectionList(userList: self.dataList )
                self.tblUsers.reloadData()
                self.tblUsers.reloadSectionIndexTitles()
                self.gitApiVc.delegate.deleteBookmark(user: userInfo)
            }
        }
        
        Utils.okAndCancelAlert(viewcontroller:self , title: CommonConst.strBookmarkRemove, message: "", okTitle: CommonConst.strBookmarkRemoveOk,cancelTitle: CommonConst.strBookmarkRemoveCancel, okAction: deleteAction, cancelAction: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 57.5;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  self.dataSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = self.dataSection[section]
        return (self.dataList[sectionKey]?.count)!
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    /**
     북마크 버튼 클릭 이벤트 처리
     */
    @objc func bookmarkClick(sender: UIButton){
        let deleteAction:(UIAlertAction) -> Void  = { (action: UIAlertAction) in
            if let section = Int(sender.accessibilityHint!){
                let row = sender.tag
                let sectionKey = self.dataSection[section]
                let userInfo = self.dataList[sectionKey]![ row ]
                if DBManager.shared.deleteGituserData(gituser: userInfo) {
                    self.dataList[sectionKey]?.remove(at: row)
                    self.dataSection = GitUserInfo.getSectionList(userList: self.dataList )
                    self.tblUsers.reloadSectionIndexTitles()
                    self.tblUsers.reloadData()
                    self.gitApiVc.delegate.deleteBookmark(user: userInfo)
                }
            }
        }
        
        Utils.okAndCancelAlert(viewcontroller:self , title: CommonConst.strBookmarkRemove, message: "", okTitle: CommonConst.strBookmarkRemoveOk,cancelTitle: CommonConst.strBookmarkRemoveCancel, okAction: deleteAction, cancelAction: nil)
    }
    /**
     API 페이지로 이동
     */
    @IBAction func clickApi(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

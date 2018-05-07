//
//  ViewController.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 5..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class GitApiViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblUsers: UITableView!
    var url_search : String = "https://api.github.com/search/users?q=%@&page=%d"

    var dataList = Array<GitUserInfo>()
    var dataSection = Array<String>()
    var curPage:Int = 1
    
    var beforeTask = DispatchWorkItem{}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tblUsers.delegate = self
        self.tblUsers.dataSource = self
        self.txtSearch.delegate = self
        
        let nib = UINib.init(nibName: "GitUserTableViewCell", bundle: nil)
        self.tblUsers.register(nib, forCellReuseIdentifier: "GitUserTableViewCell")
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
 
    }

    /**
      유저 검색 필드 실시간 이벤트 감지
     */
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        //self.tblUsers.setContentOffset(.zero, animated: false)
        self.beforeTask.cancel()
        self.beforeTask = DispatchWorkItem { self.gitUserSearchApi(searchName: textField.text ) }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: beforeTask)
    }
    
    /**
     키보드 엔터 처리
     */
    @IBAction func txtPrimaryActionTriggered(_ sender: UITextField) {
        self.gitUserSearchApi(searchName: sender.text )
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
     GitAPI 유저 검색 메소드
     */
    func gitUserSearchApi( searchName : String? ){
        curPage = 1
        if let name = searchName , name.count > 0 {
            let totalUrl = String( format: url_search,  name,curPage)
            Alamofire.request(totalUrl)
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Github Search Error")
                        return
                    }
                    if let totalValue = response.result.value as? [String: Any]{
                        if let count = totalValue["total_count"] as? Int , count > 0  {
                            let items = totalValue["items"] as! Array<[String:Any]>;
                            
                            self.curPage = 1
                            self.dataList = GitUserInfo.convertGitUsers(items: items)
                            self.tblUsers.reloadData()
                            
                            return
                        }
                    }
            }
        }else{
            //빈 값일 경우 초기화
            self.curPage = 1
            self.dataList.removeAll()
            self.dataSection.removeAll()
            self.tblUsers.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GitUserTableViewCell", for: indexPath) as! GitUserTableViewCell
        let userInfo = self.dataList[ indexPath.row ]
  
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
       
        cell.btnBookmark.tag = indexPath.row
        cell.btnBookmark.addTarget(self, action: #selector( GitApiViewController.bookmarkClick(sender:) ), for: .touchUpInside)
        if( userInfo.bookmarkCheck ){
            let img = UIImage(named: "starfull.png")
            cell.btnBookmark.setImage(img, for: .normal)
        }else{
            let img = UIImage(named: "star.png")
            cell.btnBookmark.setImage(img, for: .normal)
        }
        return cell
    }
    /**
     테이블 클릭시 즐겨찾기 추가
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let deleteAction:(UIAlertAction) -> Void  = { (action: UIAlertAction) in
            let cell = tableView.cellForRow(at: indexPath) as! GitUserTableViewCell
            let userInfo = self.dataList[indexPath.row]
            if( !userInfo.bookmarkCheck ){
                let img = UIImage(named: "starfull.png")
                cell.btnBookmark.setImage(img, for: .normal)
                userInfo.bookmarkCheck = true
                self.dataList[ indexPath.row ] = userInfo
                DBManager.shared.insertGitUserData(gituser: userInfo)
                
            }
        }
        
        Utils.okAndCancelAlert(viewcontroller:self , title: "즐겨찾기에서 추가 할까요", message: "", okTitle: "추가",cancelTitle: "취소", okAction: deleteAction, cancelAction: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 57.5;
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    /**
     테이블의 마지막 로우 체크 후 다음 페이지로 이동
     */
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row == self.dataList.count-5 {
            self.curPage += 1
            if let name = self.txtSearch.text {
                
                let totalUrl = String( format: url_search,  name,curPage)
                Alamofire.request(totalUrl)
                    .responseJSON { response in
                        guard response.result.isSuccess else {
                            print("Github Search Error")
                            return
                        }
                        
                        if let totalValue = response.result.value as? [String: Any]{
                            
                            if let count = totalValue["total_count"] as? Int , count > 0  {
                                let items = totalValue["items"] as! Array<[String:Any]>;
                                self.dataList.append(contentsOf:  GitUserInfo.convertGitUsers(items: items) )
                                self.tblUsers.reloadData()
                                
                                return
                            }
                            
                        }
                }
                
            }
            
        }
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
            let row = sender.tag
            let userInfo = self.dataList[row]
            if( !userInfo.bookmarkCheck ){
                let img = UIImage(named: "starfull.png")
                sender.setImage(img, for: .normal)
                userInfo.bookmarkCheck = true
                self.dataList[ row ] = userInfo
                DBManager.shared.insertGitUserData(gituser: userInfo)
            }
        }
        Utils.okAndCancelAlert(viewcontroller:self , title: "즐겨찾기에서 추가 할까요", message: "", okTitle: "추가",cancelTitle: "취소", okAction: deleteAction, cancelAction: nil)
    }
    
    /**
     로컬 북마크 뷰컨트롤러 이동
     */
    @IBAction func clickLocalBookmark(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LocalBookmarkViewController") as! LocalBookmarkViewController
        self.present(vc, animated: false, completion: nil)
    }
    
}


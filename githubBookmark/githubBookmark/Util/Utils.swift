//
//  Utils.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 6..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit

class Utils {

    /**
     한글 초성값 가져오기 / 영어는 그대로 반환 
     */
    static func splitText(str: String) -> String {
        guard let text = str.last else { return str }
        let val = UnicodeScalar(String(text))?.value
        guard let value = val else { return str }
        if( 0xac00 > value ){return str}
        let x = (value - 0xac00) / 28 / 21
        
        let cho = UnicodeScalar(0x1100 + x) //초성

        return String(cho!)
    }
 
    /**
     특수문자 여부 체크
     */
    static func specialChaMatches(text: String) -> Bool {
        var result = false
        let regex = "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]"
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let finalResult = results.map {
                String(text[Range($0.range, in: text)!])
            }
            result = finalResult.count > 0 ? true : false
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return result
        }
        return result
    }
    /**
     두가지 버튼이 나오는 공통 알러트 
     */
    static func okAndCancelAlert(viewcontroller:UIViewController, title:String, message:String, okTitle : String, cancelTitle : String , okAction: ( (UIAlertAction) -> Void )?, cancelAction: ((UIAlertAction)->Void)?){
        
        let alertController = UIAlertController(title: title,message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: okTitle, style: UIAlertActionStyle.destructive , handler: okAction)
        let cancelButton = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.cancel, handler: cancelAction)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        viewcontroller.present(alertController,animated: true,completion: nil)
    }
}

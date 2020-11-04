//
//  QGNoMenuTextField.swift
//  B2BAutoziMall
//
//  Created by whq0413 on 2016/11/18.
//  Copyright © 2016年 qeegoo. All rights reserved.
//

import UIKit

class QGNoMenuTextField: UITextField {

//    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        return false
//    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

}

//
//  QGCropImageVC.swift
//  B2BAutoziMall
//
//  Created by autozi01 on 2017/7/31.
//  Copyright © 2017年 qeegoo. All rights reserved.
//

import UIKit

class QGCropImageVC: UIViewController {

    private var originalImageView: TKImageView!
    var originalImage:UIImage?
    var didClickedCancelButtonClosure: clickBtnClouse?
    var didClickedOKButtonClosure: getCropImageClosure?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        fromAlbum( )
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
    /// **setupLayout（）** function
    private func setupLayout () {
//        weak var blockSelf = self
        
        self.view.backgroundColor = UIColor.black
        let toolbar = UIView()
        toolbar.backgroundColor = UIColor.gray
        toolbar.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 64)
        self.view.addSubview(toolbar)
        
        let btnCancel = UIButton(type: UIButton.ButtonType.custom)
        btnCancel.setTitle("取 消", for: .normal)
        btnCancel.setTitleColor(UIColor.white, for: .normal)
        btnCancel.backgroundColor = UIColor.clear
        btnCancel.addTarget(self, action: #selector(QGCropImageVC.didClickedButtonAction(btn:)), for: .touchUpInside)
        btnCancel.tag = 1000
        btnCancel.frame = CGRect(x: 5, y: 30, width: 80, height: 20)
        toolbar.addSubview(btnCancel)
        
        let buttonOK = UIButton(type: UIButton.ButtonType.custom)
        buttonOK.setTitle("完 成", for: .normal)
        buttonOK.setTitleColor(UIColor.green, for: .normal)
        buttonOK.backgroundColor = UIColor.clear
        buttonOK.addTarget(self, action: #selector(QGCropImageVC.didClickedButtonAction(btn:)), for: .touchUpInside)
        buttonOK.tag = 2000
        buttonOK.frame = CGRect(x: kScreenW - 80, y: 30, width: 80, height: 20)
        toolbar.addSubview(buttonOK)

        
        originalImageView = { [unowned self] in
            
            let imageView = TKImageView()
            if self.originalImage != nil  {
                imageView.toCropImage = self.originalImage
            }

            imageView.showMidLines = true
            imageView.needScaleCrop = true
            imageView.showCrossLines = false
            imageView.cornerBorderInImage = false
            imageView.cropAreaCornerWidth = 14
            imageView.cropAreaCornerHeight = 14
            imageView.minSpace = 1//最小间距
            
            imageView.cropAreaCornerLineColor = UIColor.green
            imageView.cropAreaBorderLineColor = UIColor.green
            imageView.cropAreaCornerLineWidth = 3 //角宽
            imageView.cropAreaBorderLineWidth = 1
            
            imageView.cropAreaMidLineWidth = 14
            imageView.cropAreaMidLineHeight = 3
            imageView.cropAreaMidLineColor = UIColor.green
            imageView.cropAreaCrossLineColor = UIColor.green
            imageView.cropAreaCrossLineWidth = 1
            imageView.initialScaleFactor = 0.7
            
            //设置边框线的颜色
            self.view.addSubview(imageView)
            imageView.frame = CGRect(x: 10, y: 64, width: kScreenW, height: (kScreenH - 64))
//            imageView.snp.makeConstraints { (make) -> Void in
//                make.top.equalTo(64)
//                make.width.equalTo(kScreenW)
//                make.height.equalTo(kScreenH - 64)
//            }
            return imageView
            }()

      
    }
  
    // MARK: -处理按钮点击事件
    /**
     - Parameters:
     - btn: UIButton
     */

    @objc func didClickedButtonAction(btn: UIButton) {
        
        switch btn.tag {
        case 1000:
            if let sureClosure = didClickedCancelButtonClosure {
                sureClosure()
            }
            self.dismiss(animated: true, completion: nil)
        case 2000:
            let img = originalImageView.currentCroppedImage()
            self.dismiss(animated: true, completion: nil)
            if  img != nil {
                didClickedOKButtonClosure!(img!)
            }
        default :
            break
        }
    }

}

//
//  QGScanCodeVC.swift
//  B2BAutoziMall
//
//  Created by autozi01 on 16/3/3.
//  Copyright © 2016年 qeegoo. All rights reserved.
//


import UIKit
import AVFoundation
import AssetsLibrary
import Alamofire

typealias GetVinOrOemCode = (String, String) -> Void   //定义闭包传递选中的分类信息
typealias getCropImageClosure = (UIImage) -> Void

class QGScanCodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // AVCaptureSession 是input 与 output 的桥梁，它协调input 到  output的数据传输
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput : AVCaptureStillImageOutput?
    var captureView: UIView!
    var qrcodeView: OverlayView!
//    private var timer: Timer?
    private var getVinOrOemCode:GetVinOrOemCode?           //接收上个页面穿过来的闭包
//    private var baiduOCR = BaiduOCR()//vin码扫描类
    
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initCapture()
        setupCaptureView()
        if let goodSession = captureSession {
            goodSession.startRunning()    // 启动
//            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(QGScanCodeVC.scrollScanAction), userInfo: nil, repeats: true)
        }
       // AipOcrService.shard().auth(withAK: "L30qk1m2tCDd2ct5jvOVdfZ8", andSK: "cux5rq5nYStbUOh1epSuPfOsAOuGeYYk")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       // IQKeyboardManager.sharedManager().enable = false
       // IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    deinit {
       // IQKeyboardManager.sharedManager().enable = true
       // IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackClosure(code: @escaping GetVinOrOemCode) {
        getVinOrOemCode = code
    }
    
    // 定时器控制扫描控件
    @objc func scrollScanAction() {
        qrcodeView.scrollLabel.isHidden = !qrcodeView.scanButton.isSelected
        let qrcodeViewYOffset = kScreenW * 0.75
        qrcodeView.scrollLabel.snp.updateConstraints { (make) -> Void in
            // error,因为supdate只能更新原有约束的值,并不能加入新的约束
            // make.bottom.equalTo(self.qrcodeView.codeView.snp_bottom).offset(-10)
            make.top.equalTo(self.qrcodeView.codeView.snp.top).offset(qrcodeViewYOffset - 5)
            make.centerX.equalTo(self.qrcodeView.codeView.snp.centerX)
            make.width.equalTo(self.qrcodeView.codeView.snp.width)
            make.height.equalTo(2)
        }
        UIView.animate(withDuration: 1.9, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            self.qrcodeView.scrollLabel.snp.updateConstraints { (make) -> Void in
                make.top.equalTo(self.qrcodeView.codeView.snp.top).offset(5)
            }
        }
    }

    // MARK: - View Setup
    private func setupCaptureView() {
        // 创建系统自动捕获框
        captureView = {
            let captureView = UIView()
            captureView.layer.borderColor = UIColor.green.cgColor
            captureView.layer.borderWidth = 2
            self.view.addSubview(captureView)
            //           bringSubviewToFront（）方法可以将指定的视图推送到前面，而 sendSubviewToBack()则可以将指定的视图推送到背面。
            self.view.bringSubviewToFront(captureView)
            return captureView
        }()
        // 扫一扫的图片
        qrcodeView = {
            let codeView = OverlayView(frame: CGRect.zero)
            weak var weakSelf = self
            codeView.didClickedBackButtonClosure = {
                weakSelf!.stopCapture()
                weakSelf!.qrcodeView.removeFromSuperview()
                weakSelf!.dismiss(animated: true, completion: nil)
            }
            codeView.didClickedPhonoButtonClosure = {
                weakSelf!.didPressTakePhoto()
            }
            codeView.didClickedRemakeButtonClosure = {
                if let session = weakSelf!.captureSession
                {
                    session.startRunning()
                    weakSelf!.captureView.removeFromSuperview()
                    weakSelf!.qrcodeView.resetButtonTitle()//清空原来识别的按钮上的文字
                }
            }
            //  确认
            codeView.didClickedOKVinCodeButtonClosure = {(vidCode) -> Void in
                weakSelf!.qrcodeView.removeFromSuperview()
                weakSelf!.stopCapture()
                weakSelf!.dismiss(animated: true, completion: nil)
                if(weakSelf!.getVinOrOemCode != nil) {
                    weakSelf!.getVinOrOemCode!("vin", vidCode)
                }
            }
            
            self.view.addSubview(codeView)
            codeView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)//self.view.frame
            
            //从相册中选择图像
            codeView.didClickedPhotoAlbumButtonClosure = {
                
                weakSelf!.stopCapture()
                //                weakSelf!.qrcodeView.removeFromSuperview()
                //                weakSelf!.showToast("从相册中选择图像")
                //                weakSelf!.cropImageVC()
                weakSelf!.fromAlbum()
            }
            
            return codeView
        }()
        
    }
    func cropImageVC(_  img: UIImage) {
        let vc = QGCropImageVC(nibName:"QGCropImageVC", bundle:nil)
        vc.originalImage = img
        present(vc, animated: true, completion: nil)
        weak var weakSelf = self
        vc.didClickedCancelButtonClosure = {
            if let session = weakSelf!.captureSession {
                session.startRunning()
            }
        }
        
        vc.didClickedOKButtonClosure = { (img) -> Void in
            weakSelf!.qrcodeView.editVINCode(isEdit: true)
            weakSelf!.qrcodeView.imageClipView.image = img
//            if img.size.width > img.size.height {
//                let captureImage = img.imageByRotate(degreesToRadians(-90.0), true)!
//                weakSelf!.qrcodeView.imageClipView.image = captureImage
//            } else {
//                 weakSelf!.qrcodeView.imageClipView.image = img
//            }
            
//            if weakSelf!.qrcodeView.imageClipView.isHidden == false
//            {
                let img1 = self.qrcodeView.imageClipView.image
                if img1 != nil
                {
                    weakSelf!.imgPro(img1!)
//                    weakSelf!.baiduOCR.request(img)
                }
//            }
        }
    }
    
    // MARK:
    func fromAlbum() {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self          //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            picker.allowsEditing = false
            
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
            
        }
        
    }
    
    //选择图片成功后代理
     func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //查看info对象
        print(info)
        
        //        let isEditPic: Bool = false
        //        //显示的图片
        //        let image:UIImage!
        //        if isEditPic {
        //            //获取编辑后的图片
        //            image = info[UIImagePickerControllerEditedImage] as! UIImage
        //        }else{
        //            //获取选择的原图
        //            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        }
        //
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
            
        })
        self.cropImageVC(image)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)  {
//        showToast("cancel")
        picker.dismiss(animated: true, completion: {
            () -> Void in
            
        })
        captureSession!.startRunning()
    }
    
    // MARK: - Private Methods
    // 初始化视频捕获
    private func initCapture() {
        // 代表抽象的硬件设备,这里传入video
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //       这里代表输入设备（可以是它的子类），它配置抽象硬件设备的ports。
        var captureInput:AVCaptureDeviceInput?
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice!) as AVCaptureDeviceInput
            
        } catch let error as NSError {
            print(error)
            return
        }
        //  input和output的桥梁,它协调着intput到output的数据传输.(见字意,session-会话)
        captureSession = AVCaptureSession()
        if kScreenH < 500 {
            captureSession!.sessionPreset = AVCaptureSession.Preset.vga640x480
        }else{
            captureSession!.sessionPreset = AVCaptureSession.Preset.high
        }
        captureSession!.addInput(captureInput!)
        // 限制扫描区域http://blog.csdn.net/lc_obj/article/details/41549469
        let windowSize:CGSize = UIScreen.main.bounds.size;
        let scanSize:CGSize = CGSize(width: windowSize.width*3/4, height: windowSize.width*3/4)
        var scanRect:CGRect = CGRect.init(x: (windowSize.width-scanSize.width)/2, y: (windowSize.height-scanSize.height)/2 - 45, width: scanSize.width, height: scanSize.height)
        //计算rectOfInterest 注意x,y交换位置
        scanRect = CGRect(x: scanRect.origin.y/windowSize.height, y: scanRect.origin.x/windowSize.width, width: scanRect.size.height/windowSize.height, height: scanRect.size.width/windowSize.width)
        // 输出流 它代表输出数据，管理着输出到一个movie或者图像。
        let captureMetadataOutput = AVCaptureMetadataOutput()
        //设置可探测区域
        captureMetadataOutput.rectOfInterest = scanRect
        captureSession!.addOutput(captureMetadataOutput)
        // 添加的队列按规定必须是串行
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 指定信息类型,QRCode,你懂的
        //        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
       captureMetadataOutput.metadataObjectTypes = [.ean8, .ean13, .code39, .code93, .code128, .qr]
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        captureSession!.addOutput(stillImageOutput!)
        // 用这个预览图层和图像信息捕获会话(session)来显示视频
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer!.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        view.layer.addSublayer(videoPreviewLayer!)
    }
    // 关闭捕获
    private func stopCapture() {
        if captureSession != nil {
            captureSession!.stopRunning()
            captureView.removeFromSuperview()
        }
        //self.navigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if qrcodeView.currentScanMode != ScanModelState.kScanDimensionCode {
            return ;
        }
        if metadataObjects == nil || metadataObjects.count == 0 {
            captureView!.frame = CGRect.zero
            return
        }
        // 刷取出来的数据
        for metadataObject in metadataObjects {
            if (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.qr ||  (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.ean8 || (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.ean13 || (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.code39 || (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.code93 || (metadataObject as AnyObject).type == AVMetadataObject.ObjectType.code128 {
                let metadata = metadataObject as? AVMetadataMachineReadableCodeObject
                // 元数据对象就会被转化成图层的坐标
                let codeCoord = videoPreviewLayer?.transformedMetadataObject(for: metadata!) as? AVMetadataMachineReadableCodeObject
                if codeCoord != nil{
                    captureView?.frame = codeCoord!.bounds
                }
                if metadata?.stringValue != nil {
                    //   println("\(metadata.stringValue)")
                    self.captureSession?.stopRunning()
                    self.qrcodeView.removeFromSuperview()
                    self.stopCapture()
                    self.dismiss(animated: true, completion: nil)
                    self.getVinOrOemCode!("oem", metadata!.stringValue!)
                
                }
            }
        }
    }
    
    // MARK: 处理拍照
    private func didPressTakePhoto(){
        if let videoConnection = stillImageOutput?.connection(with: AVMediaType.video){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
             weak var weakSelf = self
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                (sampleBuffer, error) in
                if sampleBuffer != nil {
                    self.stopCapture()
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider  = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    var captureImage = UIImage( cgImage: cgImageRef!)
                    captureImage = captureImage.imageByRotate(degreesToRadians(-90.0), true)!
                    var f: CGRect  = CGRect.zero
                    let scale = captureImage.size.height / kScreenH;
                    let w = self.qrcodeView.codeView.frame.width * scale;
                    let h = self.qrcodeView.codeView.frame.height * scale;
                    //big
                    let w2 = captureImage.size.width;
                    let h2 = captureImage.size.height;
                    f.origin.y = (h2 - h) / 2.0;
                    f.origin.x = (w2-w)/2.0;
                    f.size.height = h;
                    f.size.width  = w;
                    let image = captureImage.cropWithCropRect(f)
                    self.qrcodeView.imageClipView.image = image
                    if self.qrcodeView.imageClipView.isHidden == false
                    {
                        let img = self.qrcodeView.imageClipView.image
                        if self.qrcodeView.imageClipView.image != nil
                        {
                            weakSelf!.imgPro(img!)
                        }
                    }
                }
            })
        }
    }
    func vinCodeProc(vinString: String)-> Void {
        let dic = getDictionaryFromJSONString(jsonString: vinString as String)
        if dic.count > 0 {
            let vin = dic["vin"]
            if (vin != nil) {
                self.qrcodeView.setVinCode(vin as! String)
            }
        }
    }
    func carNoProc(vinString: String)-> Void {
        let dic = getDictionaryFromJSONString(jsonString: vinString as String)
        if dic.count > 0 {
//            let vin = dic["vin"]
//            self.qrcodeView.setVinCode(vin as! String)
        }
    }
    
    func imgPro(_ image: UIImage) {
//        let appcode = "APPCODE 0df99e0c9bb04c5586ed54e0dc916b17"
//        let host = "https://vin.market.alicloudapi.com"
//        let path = "/api/predict/ocr_vin"
//        let url = host + path
//        let imgData = image.jpegData(compressionQuality: 0.8)
        let imgData = image.pngData()
        let data = imgData?.base64EncodedString()
        
        if qrcodeView.currentScanMode == .kScanDimensionCode {
            AliNet.requestOCRCarNo(data!, carNoString: carNoProc )
        }else {
            AliNet.requestOCRVin_bd(data, vinCodeString: vinCodeProc )
        }
       
//        weakSelf!.qrcodeView.
//        let parameters: Parameters = ["image": data!.utf8]
//        let headers: HTTPHeaders = [
//            "Authorization": appcode,
//              "Content-Type": "application/json"
//        ]
//        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { response in
//            debugPrint(response)
//
//            if let json = response.result.value {
//                print("JSON: \(json)")
//            }
//        }
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }
    
    lazy var device: AVCaptureDevice? = {
        let d = AVCaptureDevice.default(for: AVMediaType.video)
        return d
    }()
    
    func focusAtPoint(/*point : CGPoint*/) {
//        let size = self.qrcodeView.imageClipView.frame.size
//        let focusPoint = CGPoint.init(x: point.y/size.height, y: 1-point.x/size.width)
        let focusPoint = CGPoint(x: self.qrcodeView.imageClipView.frame.midX, y: self.qrcodeView.imageClipView.frame.midY)
        if let device = device {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                // exposure : 暴露
                if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose){
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
    }

    
    
}

extension UITextField {
    func selectedRange() -> NSRange
    {
        let beginning = self.beginningOfDocument
        let selectedRange = self.selectedTextRange
        let selectionStart = selectedRange?.start
        let selectionEnd = selectedRange?.end
        guard let _ = selectionStart else { return NSRange.init(location: 0, length: 0)}
        guard let _ = selectionEnd else { return NSRange.init(location: 0, length: 0)}
        let location = self.offset(from: beginning, to: selectionStart!)
        let length = self.offset(from: selectionStart!, to: selectionEnd!)
        //let length = self.offsetFromPosition(selectionStart!, toPosition: selectionEnd!)
        return NSRange.init(location: location, length: length)
    }
    
    func setSelectedRange(range: NSRange)
    {
        let beginning = self.beginningOfDocument
        let startPosition = self.position(from: beginning, offset: range.location)
        let endPosition = self.position(from: beginning, offset: range.location + range.length)
        guard let _ = startPosition else { return }
        guard let _ = endPosition else { return }
        let selectionRange = self.textRange(from: startPosition!, to: endPosition!)
        self.selectedTextRange = selectionRange
    }
    
 
}


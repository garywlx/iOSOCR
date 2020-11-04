//
//  UIImage+Additions.swift
//  UIViewDemo
//
//  Created by weilaixi on 2/24/16.
//  Copyright © 2016 weilaixi. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    // MARK: - 裁剪给定得区域
    /// 裁剪给定得区域
    public func cropWithCropRect( _ crop: CGRect) -> UIImage?
    {
        let cropRect = CGRect(x: crop.origin.x * self.scale, y: crop.origin.y * self.scale, width: crop.size.width * self.scale, height: crop.size.height *  self.scale)
        
        if cropRect.size.width <= 0 || cropRect.size.height <= 0 {
            return nil
        }
        var image:UIImage?
        autoreleasepool{
            let imageRef: CGImage?  = self.cgImage!.cropping(to: cropRect)
            if let imageRef = imageRef {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
    
    func imageByApplayingAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.height)
        context?.setBlendMode(.multiply)
        context?.setAlpha(alpha)
        context?.draw(self.cgImage!, in: area)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
}


extension UIImage {
    /**
     Draw an UIImage with rounded corner via CGGraphics. Note that if the cornerRadius is bigger than the radius of the image, it will be a circle.
     
     - parameter sizeToFit:       Size of the image to draw on.
     - parameter cornerRadius:    Raidus of corner.
     - parameter borderWidth:     Default to 0.
     - parameter borderColor:     Default to white.
     - parameter backgroundColor: Background color. If you set `opaque` to true, you should provide a background color otherwise it will be black.
     - parameter opaque:          By default, set to true for performance reason.
     - parameter scale:           By default, set to `UIScreen.mainScreen().scale`.
     
     - returns: The drawn UIImage.
     */
    public func maskWithRoundedRect(sizeToFit: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.white, backgroundColor: UIColor? = nil, opaque: Bool = true, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        // size to draw
        let rect = CGRect(origin: CGPoint.zero, size: sizeToFit)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, opaque , scale )
        
        // fill the background color first if available
        if let backgroundColor = backgroundColor {
            backgroundColor.set()
            UIRectFill(rect)
        }
        
        // drawing path
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        let context = UIGraphicsGetCurrentContext()
        context!.addPath(path.cgPath)
        context?.clip()
        draw(in: rect)
        
        // draw border
        context?.setStrokeColor(borderColor.cgColor)
        context?.setLineWidth(borderWidth)
        
        path.lineWidth = borderWidth * 2
        path.stroke()
        
        let output = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return output ?? self
    }
    
    
    // Returns true if the image has an alpha layer
    func hasAlpha() -> Bool
    {
        let alpha: CGImageAlphaInfo = self.cgImage!.alphaInfo
        return (alpha == CGImageAlphaInfo.first || alpha == CGImageAlphaInfo.last || alpha == CGImageAlphaInfo.premultipliedFirst || alpha == CGImageAlphaInfo.premultipliedLast)
    }
    
    //MARK: gif图片其实是一张张的图片在连续切换，播放gif，需要拿到一张张的图片，和图片显示的时长，一张张替换
    public class func gifImage(file path:String) -> UIImage?{
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        return UIImage.gifImage(with:data as Data)
    }
    public class func gifImage(with data:Data) -> UIImage? {
        //data转为CGImageSource对象
        guard let imageSource = CGImageSourceCreateWithData(data as CFData,nil) else {
            return nil
        }
        //获取图片的张数
        let imageCount = CGImageSourceGetCount(imageSource)
        //gif图组
        var imageArray = [UIImage]()
        var timeCount:TimeInterval = 0
        //遍历获取所有图片
        for i in 0..<imageCount {
            //根据下标创建图片
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { continue }
            let image = UIImage(cgImage: cgImage)
            imageArray.append(image)
            //每张图片的持续时间
            guard let imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? [String:Any] else { continue }
            guard let gifInfo = imageInfo[kCGImagePropertyGIFDictionary as String] as? [String:Any] else { continue }
            guard let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval else { continue }
            timeCount += delayTime
        }
        //将多张图片转化为一张图片
        return UIImage.animatedImage(with: imageArray, duration: timeCount)
        
        //设置imageView显示一组动画
        //        imageView.animationImages = imageArray
        //        imageView.animationDuration = timeCount
        //        imageView.startAnimating()
        
    }
    
    
    // MARK: - 图片缩放
    /// 按比例减少给定图像的尺寸
    ///
    ///     eg:
    ///     压缩方式一：最大边不超过某个值等比例压缩
    ///     let px_1000_img = oldImg?.scaleImage(1000.0)
    ///     let px_1000_data = UIImageJPEGRepresentation(px_1000_img!, 0.7)
    ///     tv.text.append("最大边不超过1000PX的大小 \(M(Double(px_1000_data!.count))) M \n")
    ///     tv.text.append("最大边不超过1000PX宽度 \(String(describing: px_1000_img?.size.width))\n")
    ///     tv.text.append("最大边不超过1000PX高度 \(String(describing: px_1000_img?.size.height))\n\n")
    ///     tv.text.append("-------------------------------\n")
    ///
    /// - Parameter maxSideLength: 缩小后的尺寸.
    ///
    /// - Returns: 函数按比例返回缩小后的图像
    func scaleImage(_ maxSideLength: CGFloat) -> UIImage {
        guard  size.width > maxSideLength || size.height > maxSideLength else {
            return self
        }
        let imgSize = reduceSize(size, maxSideLength)
        var img: UIImage!
        // 1 代表1X
        UIGraphicsBeginImageContextWithOptions(imgSize, true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height), blendMode: .normal, alpha: 1.0)
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img
    }
    
    //MARK: -   按比例裁剪图片
    func scaleToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    /// 按比例减少尺寸
    ///
    /// - Parameter sz: 原始图像尺寸.
    /// - Parameter limit:目标尺寸.
    /// - Returns: 函数按比例返回缩小后的尺寸
    /// - Complexity: O(*n*)
    
    func reduceSize(_ sz: CGSize, _ limit: CGFloat) -> CGSize {
        let maxPixel = max(sz.width, sz.height)
        guard maxPixel > limit else {
            return sz
        }
        var resSize: CGSize!
        let ratio = sz.height / sz.width;
        
        if (sz.width > sz.height) {
            resSize = CGSize(width:limit, height:limit*ratio);
        } else {
            resSize = CGSize(width:limit/ratio, height:limit);
        }
        
        return resSize;
    }
    
    //生成圆角UIIamge 的方法
    
    func imageWithRoundedCornersSize(cornerRadius: CGFloat) -> UIImage{
        let original = self
        
        let frame = CGRect.init(x: 0, y: 0, width: original.size.width, height: original.size.height)
        
        UIGraphicsBeginImageContextWithOptions(original.size, false, 1.0)
        
        UIBezierPath.init(roundedRect: frame, cornerRadius: cornerRadius).addClip()
        
        original.draw(in: frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    
    // MARK: - 图片压缩
    /// 图片压缩
    ///
    ///     eg:
    ///     oldImg?.compressImage(1024*1024*1, 1000.0, {(data) in
    ///     let img = UIImage(data: data)
    ///     tv.text.append("图片最大值不超过最大边1M 以及 最大边不超过1000PX的大小 \(self.M(Double((data.count)))) M\n")
    ///     tv.text.append("图片最大值不超过最大边1M 以及 最大边不超过1000PX的宽度 \(img!.size.width)\n")
    ///     tv.text.append("图片最大值不超过最大边1M 以及 最大边不超过1000PX的高度 \(img!.size.height)\n\n")
    ///     tv.text.append("-------------------------------\n")
    ///     })
    ///
    /// - Parameter limitSize:限制图像的大小.
    /// - Parameter maxSideLength: 缩小后的尺寸.
    /// - Parameter completion: 闭包回调.
    /// - Returns: 函数按比例返回压缩后的图像
    func compressImage( _ limitSize: Int, _ maxSideLength: CGFloat, _ completion: @escaping (_ dataImg: Data)->Void ) {
        guard limitSize>0 || maxSideLength>0 else {
            return
        }
        //weak var weakSelf = self
        let compressQueue = DispatchQueue(label: "image_compress_queue")
        compressQueue.async {
            var quality = 0.7
            //let img = weakSelf?.scaleImage(maxSideLength)
            let img = self.scaleImage(maxSideLength)
            var imageData = img.jpegData(compressionQuality: CGFloat(quality))
            guard imageData != nil else { return }
            if (imageData?.count)! <= limitSize {
                DispatchQueue.main.async(execute: {//在主线程里刷新界面
                    completion(imageData!)
                })
                return
            }
            
            repeat {
                autoreleasepool {
                    imageData = img.jpegData(compressionQuality: CGFloat(quality))
                    quality = quality-0.05
                }
            } while ((imageData?.count)! > limitSize);
            DispatchQueue.main.async(execute: {//在主线程里刷新界面
                completion(imageData!)
            })
        }
    }
    
    // MARK: - 旋转
    public func imageByRotate(_ radians: CGFloat, _ fitSize: Bool) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let width: Int = cgImage.width
        let height: Int = cgImage.height
        let newRect: CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)).applying(fitSize ? CGAffineTransform(rotationAngle: radians) : CGAffineTransform.identity)
        var resultImage: UIImage?
        autoreleasepool {
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
            if let context = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height),bitsPerComponent: 8,bytesPerRow: Int(newRect.size.width * 4), space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) {
                context.setShouldAntialias(true)
                context.setAllowsAntialiasing(true)
                context.interpolationQuality = CGInterpolationQuality.high;
                context.translateBy(x: +(newRect.size.width * 0.5), y: +(newRect.size.height * 0.5))
                context.rotate(by: radians)
                context.draw(self.cgImage!, in: CGRect(x: -(CGFloat(width) * 0.5), y: -(CGFloat(height) * 0.5), width: CGFloat(width), height: CGFloat(height)))
                if let imgRef: CGImage = context.makeImage() {
                    resultImage = UIImage(cgImage: imgRef)
                }
            }
        }
        return resultImage;
    }
    
    //水印位置枚举
    enum WaterMarkCorner{
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
    
    //添加水印方法
    func waterMarkedImage(waterMarkText:String, corner:WaterMarkCorner = .BottomRight,
                          margin:CGPoint = CGPoint(x: 20, y: 20),
                          waterMarkTextColor:UIColor = UIColor.white,
                          waterMarkTextFont:UIFont = UIFont.systemFont(ofSize: 20),
                          backgroundColor:UIColor = UIColor.clear) -> UIImage{
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:waterMarkTextColor,
                              NSAttributedString.Key.font:waterMarkTextFont,
                              NSAttributedString.Key.backgroundColor:backgroundColor]
        let textSize = NSString(string: waterMarkText).size(withAttributes: textAttributes)
        var textFrame = CGRect.init(x: 0, y: 0, width: textSize.width, height: textSize.height)//CGRectMake(0, 0, textSize.width, textSize.height)
        
        let imageSize = self.size
        switch corner{
        case .TopLeft:
            textFrame.origin = margin
        case .TopRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x, y: margin.y)
        case .BottomLeft:
            textFrame.origin = CGPoint(x: margin.x, y: imageSize.height - textSize.height - margin.y)
        case .BottomRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x,
                                       y: imageSize.height - textSize.height - margin.y)
        }
        
        // 开始给图片添加文字水印
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.width))//CGRectMake(0, 0, imageSize.width, imageSize.height))
        NSString(string: waterMarkText).draw(in: textFrame, withAttributes: textAttributes)
        
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return waterMarkedImage!
        
        
        //                    self?.test_Img.image = UIImage(named:"VIPCardPay")?
        //                        .waterMarkedImage(waterMarkText: "做最好的开发者知识平台", corner: .TopLeft,
        //                                          margin: CGPoint(x: 20, y: 20),
        //                                          waterMarkTextColor: UIColor.white,
        //                                          waterMarkTextFont: UIFont.systemFont(ofSize: 20),
        //                                          backgroundColor: UIColor.clear)
        //                        .waterMarkedImage(waterMarkText: "hangge.com", corner: .BottomRight,
        //                                          margin: CGPoint(x: 20, y: 20),
        //                                          waterMarkTextColor: UIColor.black,
        //                                          waterMarkTextFont: UIFont.systemFont(ofSize: 45),
        //                                          backgroundColor: UIColor.clear)
    }
}




//
//  AssetsManager.swift
//  vrodeo
//
//  Created by Caitlin on 7/11/15.
//  Copyright (c) 2015 vrodeo. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

class AssetObject {
    var metadata : [NSObject : AnyObject]
    var image : Unmanaged<CGImage>
    var URL : NSURL
    var thumbnail : UIImage
    
    init(asset : ALAsset){
        self.URL = asset.defaultRepresentation().url()
        self.thumbnail = self.dynamicType.generateThumbImage(self.URL)
        self.image = asset.defaultRepresentation().fullResolutionImage()
        self.metadata = asset.defaultRepresentation().metadata()
    }
    
    class func generateThumbImage(url : NSURL) -> UIImage{
        var asset : AVAsset = AVAsset.assetWithURL(url) as! AVAsset
        var assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var error       : NSError? = nil
        var time        : CMTime = CMTimeMake(1, 30)
        var img         : CGImageRef = assetImgGenerate.copyCGImageAtTime(time, actualTime: nil, error: &error)
        var frameImg    : UIImage = UIImage(CGImage: img)!
        
        return frameImg
    }

}


class AssetsManager {

    var groupName : String? {
        didSet {
            println("new group name: \(self.groupName)")
        }
    }
    var library = ALAssetsLibrary()
    var assets = [AssetObject]()
    
    func addGroupAlbumToRoll(){
        self.library.addAssetsGroupAlbumWithName(groupName, resultBlock: nil, failureBlock: { (err) -> Void in
            if ((err) != nil) {println("Album could not be added")}
        })
    }
    
    func saveVideoToGalleryGroup(videoURL: NSURL){
        library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum),
                usingBlock: { (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) in
                    if (group != nil) {
                        if group!.valueForProperty(ALAssetsGroupPropertyName).isEqualToString(self.groupName!) {
                            stop.initialize(true)
                            self.library.writeVideoAtPathToSavedPhotosAlbum(videoURL,
                                completionBlock: { (assetURL, error: NSError?) in
                                    if let theError = error?.code {
                                        println("Error saving video \(theError)")
                                    } else {
                                        self.library.assetForURL(assetURL,
                                            resultBlock: { (asset: ALAsset!) -> Void in
                                                group!.addAsset(asset)
                                                let assetObject = AssetObject(asset: asset)
                                                self.assets.append(assetObject)
                                            },
                                            
                                            failureBlock: { (theError: NSError!) -> Void in
                                            println("Error saving video \(theError)")
                                        })
                                    }
                                })

                        }
                        }
                },
            
                failureBlock: { (theError: NSError!) -> Void in
                println("Error saving video \(theError)")
            }
        )}
    
    
    func loadVideosFromGroupAlbum(completion: (Bool) -> Void) {
        self.library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum),
            usingBlock: { (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) in
                if (group != nil) {
                    if group!.valueForProperty(ALAssetsGroupPropertyName).isEqualToString(self.groupName!) {
                        stop.initialize(true)
                        group?.enumerateAssetsUsingBlock({ (asset: ALAsset?, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            if let asset = asset {
                                let assetObject = AssetObject(asset: asset)
                                self.assets.append(assetObject)
                            }
                        })
                        completion(true)
                    }
                }
            },
            
            failureBlock: { (theError: NSError!) -> Void in
                println("Error saving video \(theError)")
                completion(false)
            }
            
        )
    }
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

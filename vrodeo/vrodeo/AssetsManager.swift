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
    
    deinit {
        image.release()
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
    
    private var library = ALAssetsLibrary()
    var assets = [AssetObject]()
    
    func addGroupAlbumToRoll(){
        self.library.addAssetsGroupAlbumWithName(groupName, resultBlock: nil, failureBlock: { (err) -> Void in
            if ((err) != nil) {println("Album could not be added")}
        })
    }
    
    func saveVideoToGalleryGroup(videoURL: NSURL, completion: (Bool) -> Void){
        self.findGroupAlbum { (complete, group) -> Void in
            if complete {
                self.library.writeVideoAtPathToSavedPhotosAlbum(videoURL,
                    completionBlock: { (assetURL, error: NSError?) in
                        if let theError = error?.code {
                            println("Error saving video \(theError)")
                            completion(false)
                        } else {
                            self.library.assetForURL(assetURL,
                                resultBlock: { (asset: ALAsset!) -> Void in
                                    group!.addAsset(asset)
                                    let assetObject = AssetObject(asset: asset)
                                    self.assets.append(assetObject)
                                    completion(true)
                                },
                                
                                failureBlock: { (theError: NSError!) -> Void in
                                    println("Error saving video \(theError)")
                                    completion(false)
                            })
                        }
                })
            }
        }
    }
    
    private func findGroupAlbum(completion: (Bool, group: ALAssetsGroup?) -> Void){ //ALAssets is nil so can return nil if returning from failureBlock
        self.library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum),
        usingBlock: { (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) in
            if let group = group {
                if group.valueForProperty(ALAssetsGroupPropertyName).isEqualToString(self.groupName!) {
                    stop.initialize(true)
                    completion(true, group: group)
                }
            }
        },
        failureBlock: { (theError: NSError!) -> Void in
            println("Error saving video \(theError)")
            completion(false, group: nil)
        })
    }
    
    func loadVideosFromGroupAlbum(completion: (Bool) -> Void) {        
        self.findGroupAlbum { (complete, group) -> Void in
            if complete {
                group?.enumerateAssetsUsingBlock({ (asset: ALAsset?, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let asset = asset {
                        let assetObject = AssetObject(asset: asset)
                        self.assets.append(assetObject)
                    }
                })
                completion(true)
            }
        }
        
    }
}

//
//  ALAssetsGroupViewController.swift
//  vrodeo
//
//  Created by Caitlin on 7/11/15.
//  Copyright (c) 2015 vrodeo. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

class AssetObject {
    var Metadata : [NSObject : AnyObject]!
    var Image : Unmanaged<CGImage>!
    var URL : NSURL?
    var Thumbnail : UIImage?
}


class ALAssetsGroupViewController: UIViewController {

    var groupName : String?
    var library = ALAssetsLibrary()
    var assets = [AssetObject]()
    var appDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setALAssetGroupName(name: String){
        groupName = name
    }
    
    func addGroupAlbumToRoll(){
        self.library.addAssetsGroupAlbumWithName(groupName, resultBlock: { (group) -> Void in
        }) { (err) -> Void in
            if ((err) != nil) {println("Album could not be added")}
        }
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
                                                let assetObject = AssetObject()
                                                assetObject.URL = asset!.defaultRepresentation().url()
                                                assetObject.Thumbnail = self.generateThumbImage(assetObject.URL!)
                                                assetObject.Image = asset!.defaultRepresentation().fullResolutionImage()
                                                assetObject.Metadata = asset!.defaultRepresentation().metadata()
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
    
    
    func loadVideosFromGroupAlbum() {
        self.library.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupAlbum),
            usingBlock: { (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) in
                if (group != nil) {
                    if group!.valueForProperty(ALAssetsGroupPropertyName).isEqualToString(self.groupName!) {
                        stop.initialize(true)
                        group?.enumerateAssetsUsingBlock({ (asset: ALAsset?, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            if (asset != nil) {
                                let assetObject = AssetObject()
                                assetObject.URL = asset!.defaultRepresentation().url()
                                assetObject.Thumbnail = self.generateThumbImage(assetObject.URL!)
                                assetObject.Image = asset!.defaultRepresentation().fullResolutionImage()
                                assetObject.Metadata = asset!.defaultRepresentation().metadata()
                                self.assets.append(assetObject)
                            }
                        })
                    }
                }
            },
            
            failureBlock: { (theError: NSError!) -> Void in
                println("Error saving video \(theError)")
            }
            
        )
    }
    
    func generateThumbImage(url : NSURL) -> UIImage{
        var asset : AVAsset = AVAsset.assetWithURL(url) as! AVAsset
        var assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var error       : NSError? = nil
        var time        : CMTime = CMTimeMake(1, 30)
        var img         : CGImageRef = assetImgGenerate.copyCGImageAtTime(time, actualTime: nil, error: &error)
        var frameImg    : UIImage = UIImage(CGImage: img)!
        
        return frameImg
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

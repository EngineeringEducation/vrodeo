//
//  CloudinaryViewController.swift
//  vrodeo
//
//  Created by Caitlin on 7/12/15.
//  Copyright (c) 2015 vrodeo. All rights reserved.
//

import UIKit
import AssetsLibrary

class CloudinaryViewController: UIViewController, FMAssetInputStreamDelegate, CLUploaderDelegate {

    var Cloudinary = CLCloudinary()!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // IMPORTANT: Using this for testing only. When app goes live, Cloudinary says you should not include the api_secret
        

        // Do any additional setup after loading the view.
        
    }
    
    func uploadVideo(video: ALAsset, url: NSURL){
        var Cloudinary = CLCloudinary(url: "http://res.cloudinary.com/vrodeo")
        let assetStreamDelegate : FMAssetInputStreamDelegate
        let uploader = CLUploader(Cloudinary, delegate: self)

        Cloudinary.config().setValue("335738194273788", forKey: "api_key")
        Cloudinary.config().setValue("g9FcsUp25_hsa7fnBTKBXiptoTE", forKey: "api_secret")
        Cloudinary.config().setValue("vrodeo", forKey: "cloud_name")
        //let string = video.standardizedURL
        println(video)
        
        let request = NSMutableURLRequest(URL: url)
        request.setAsset(video, delegate: self)
        
        uploader.upload(request, options: ["public_id":"vrodeo"])
    }
    
    func progressBytes(progress: Int64, totalBytes total: Int64) {
        println("something")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  ViewController.swift
//  vrodeo-reboot
//
//  Created by Caitlin on 6/29/15.
//  Copyright (c) 2015 vrodeo. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import AVKit
import CoreImage
import Photos

class FirstViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var groupName = "vrodeo"
    
    var camera = UIImagePickerController()
    var cameraRoll = UIImagePickerController()
    var library = ALAssetsLibrary()
    var moviePlayer : MPMoviePlayerController!
    var vrodeoGroup = ALAssetsGroup()
    let assetsVC = AssetsManager()
    
    @IBOutlet weak var videoTableCollectionView: UICollectionView!
    

    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if assetsVC.assets.count != 0 {
            return assetsVC.assets.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath) as! PhotoCellCollectionViewCell
        cell.videoCell.image = self.assetsVC.assets[indexPath.row].thumbnail
        cell.videoCell.sizeToFit()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        uploadToAmazon(assetsVC.assets[indexPath.row].asset)
        
//        if (assetsVC.assets.count > 0){
//            let urlString = assetsVC.assets[indexPath.row].URL
//            let player = AVPlayer(URL: urlString)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//            self.presentViewController(playerViewController, animated: true, completion: { () -> Void in
//                player.play()
//                playerViewController
//            })
//        }
    }
    
    // MARK: - Video Recorder Interactions
    
    @IBAction func recordVideo(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            camera.delegate = self
            camera.sourceType = UIImagePickerControllerSourceType.Camera
            camera.mediaTypes = [kUTTypeMovie as String]
            camera.showsCameraControls = true
            camera.allowsEditing = true
            camera.cameraCaptureMode = .Video
            print(camera.cameraCaptureMode.rawValue, terminator: "")
            self.presentViewController(camera, animated: true, completion: { () -> Void in
            })
            
        } else {
            print("no camera available", terminator: "")
        }
        
    }
    
    // TODO: This transition is super slow. Works, though so moving on. Ask Janardan.
    func videoStopped(notification : NSNotification){
        moviePlayer.view.removeFromSuperview()
    }
    
    // OK so right now, the camera launches but isn't actually ready. Need to implement a timer or something to catch this. Not a huge deal, just push record again and it works when it's ready.
    func cameraIsReady(notification : NSNotification) {
        self.camera.startVideoCapture()
    }
    
    
    // MARK: - Image Picker Controller
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imagePickerControllerDidCancel(picker)
        let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        assetsVC.saveVideoToGalleryGroup(videoURL, completion: { (complete) -> Void in
            if complete {
                self.videoTableCollectionView.reloadData()
            } else {
                print("error", terminator: "")
            }
        })
        self.videoTableCollectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.camera.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }


    
    // MARK: - Views
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: "cameraIsReady:", name: AVCaptureSessionDidStartRunningNotification, object: nil)
        defaultCenter.addObserver(self, selector: "videoStopped:", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        
        
        // TODO: Need to add a check to only add it if it's not on the screen already
        assetsVC.groupName = groupName
        assetsVC.addGroupAlbumToRoll()
        assetsVC.loadVideosFromGroupAlbum { (complete) -> Void in
            if complete == true {
                self.videoTableCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func uploadToAmazon(asset: ALAsset) {
        let keyID = "AKIAIZWEQJNXM6XR3ZOQ"
        let secret = "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"
        let s3Manager = AFAmazonS3Manager(accessKeyID: keyID, secret: secret)
        s3Manager.requestSerializer.region = AFAmazonS3USStandardRegion
        s3Manager.requestSerializer.bucket = "vrodeo"
        let destinationPath = "/test.mp4"
        
        let newAsset = PHAsset.fetchAssetsWithALAssetURLs([asset.defaultRepresentation().url()], options: nil).firstObject! as! PHAsset
        
        // TODO: Handle the many unhandled failures that can happen here
        
        PHImageManager.defaultManager().requestExportSessionForVideo(newAsset, options: nil, exportPreset: AVAssetExportPreset1280x720) { (exportSession, info) -> Void in
            
            guard let exportSession = exportSession else {
                // yell at the user for sucking
                return
            }
            
            let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            
            let cachesURL = NSURL(fileURLWithPath: cachesDirectory)
            let outputURL = NSURL(string: "convertedVideo.mp4", relativeToURL: cachesURL)!
            
            exportSession.outputFileType = AVFileTypeMPEG4
            exportSession.outputURL = outputURL
            
            exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                s3Manager.putObjectWithFile(exportSession.outputURL!.path!, destinationPath: destinationPath, parameters: nil,
                    progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                        print("\(bytesWritten) toward \(totalBytesWritten) of \(totalBytesExpectedToWrite)")
                    },
                    success: { (responseObject) -> Void in
                        print("Upload complete")
                        do {
                            try NSFileManager.defaultManager().removeItemAtURL(outputURL)
                        } catch {
                            // lol
                        }
                    },
                    failure: { (error) -> Void in
                        print(error)
                        do {
                            try NSFileManager.defaultManager().removeItemAtURL(outputURL)
                        } catch {
                            // lol
                        }
                })
            })
        }
    }
    
//    AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:@"..." secret:@"..."];
//    s3Manager.requestSerializer.region = AFAmazonS3USWest1Region;
//    s3Manager.requestSerializer.bucket = @"my-bucket-name";
//    
//    NSString *destinationPath = @"/pathOnS3/to/file.txt";
//    
//    [s3Manager postObjectWithFile:@"/path/to/file.txt"
//    destinationPath:destinationPath
//    parameters:nil
//    progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//    NSLog(@"%f%% Uploaded", (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100));
//    }
//    success:^(AFAmazonS3ResponseObject *responseObject) {
//    NSLog(@"Upload Complete: %@", responseObject.URL);
//    }
//    failure:^(NSError *error) {
//    NSLog(@"Error: %@", error);
//    }];
    
}
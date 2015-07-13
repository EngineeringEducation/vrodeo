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

class FirstViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var groupName = "vrodeo"
    
    var camera = UIImagePickerController()
    var cameraRoll = UIImagePickerController()
    var library = ALAssetsLibrary()
    var videoURLs : [String] = []
    var moviePlayer : MPMoviePlayerController!
    var vrodeoGroup = ALAssetsGroup()
    let assets = ALAssetsGroupViewController()
    let cloudinary = CloudinaryViewController()
    
    @IBOutlet weak var videoTableCollectionView: UICollectionView!
    
    @IBAction func refreshTable(sender: UIBarButtonItem) {
        videoTableCollectionView.reloadData()
        for (var i = 0; (i < assets.assets.count); i++){
            println(assets.assets[i].URL)
            let video = assets.assets[i].URL

        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if assets.assets.count != 0 {
            return assets.assets.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath) as! PhotoCellCollectionViewCell
        cell.videoCell.image = self.assets.assets[indexPath.row].Thumbnail
        cell.videoCell.sizeToFit()
        return cell
    }
    
//    @IBOutlet weak var videoTable: UITableView!
    
    @IBAction func recordVideo(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            camera.delegate = self
            camera.sourceType = UIImagePickerControllerSourceType.Camera
            camera.mediaTypes = [kUTTypeMovie]
            camera.showsCameraControls = true
            camera.allowsEditing = true
            camera.cameraCaptureMode = .Video
            println(camera.cameraCaptureMode.rawValue)
            self.presentViewController(camera, animated: true, completion: { () -> Void in
            })
            
        } else {
            println("no camera available")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        var defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: "cameraIsReady:", name: AVCaptureSessionDidStartRunningNotification, object: nil)
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("vrodeo-videos") != nil) {
            var arr = NSUserDefaults.standardUserDefaults().valueForKey("vrodeo-videos") as! [String]
            videoURLs = arr
        }
        
        assets.setALAssetGroupName(groupName)
        assets.addGroupAlbumToRoll()
        assets.loadVideosFromGroupAlbum()
        //need to figure out how to set the groupCount after the previous call finishes. Can't set from other one because then it crashes.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // OK so right now, the camera launches but isn't actually ready. Need to implement a timer or something to catch this. Not a huge deal, just push record again and it works when it's ready.
    func cameraIsReady(notification : NSNotification) {
        self.camera.startVideoCapture()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (videoURLs.count > 0){
            var urlString = videoURLs[indexPath.row]
            self.moviePlayer = MPMoviePlayerController(contentURL: NSURL(fileURLWithPath: urlString))
            
            if (self.moviePlayer != nil) {
                self.moviePlayer.prepareToPlay()
                self.view.addSubview(moviePlayer.view)
                self.moviePlayer.view.frame = self.view.bounds
                self.moviePlayer.fullscreen = true
                self.moviePlayer.scalingMode = .AspectFill
                self.moviePlayer.movieSourceType = .File
                self.moviePlayer.play()
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.camera.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imagePickerControllerDidCancel(picker)
        var videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        var videoURLString = toString(videoURL)
        videoURLs.append(videoURLString)
//        videoTable.reloadData()
        println(videoURLString)
        println(videoURL)
        NSUserDefaults.standardUserDefaults().setValue(videoURLs, forKey: "vrodeo-videos")
//        self.library.saveVideo(videoURL, toAlbum: "vrodeo", completion: { (url, err) -> Void in
//            println(url)
//            }) { (err) -> Void in
//                println(err)
//        }
        
    }
}
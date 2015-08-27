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
import QuartzCore

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
        if (assetsVC.assets.count > 0){
            var urlString = assetsVC.assets[indexPath.row].URL
            var playerItem = AVPlayerItem(URL: urlString)
            var player = AVPlayer(playerItem: playerItem)
            var playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.frame
            self.view.layer.addSublayer(playerLayer)
            player.play()
            
            
//            self.moviePlayer = MPMoviePlayerController(contentURL: urlString)
//            if (self.moviePlayer != nil) {
//                self.moviePlayer.prepareToPlay()
//                self.presentMoviePlayerViewControllerAnimated(self.moviePlayer)
//                self.moviePlayer.view.frame = self.view.bounds
//                self.moviePlayer.fullscreen = true
//                self.moviePlayer.scalingMode = .AspectFill
//                self.moviePlayer.movieSourceType = .File
//                self.moviePlayer.play()
//            }
        }
    }
    
    // MARK: - Video Recorder Interactions
    
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
    
    // TODO: This transition is super slow. Works, though so moving on. Ask Janardan.
    func videoStopped(notification : NSNotification){
        moviePlayer.view.removeFromSuperview()
    }
    
    // OK so right now, the camera launches but isn't actually ready. Need to implement a timer or something to catch this. Not a huge deal, just push record again and it works when it's ready.
    func cameraIsReady(notification : NSNotification) {
        self.camera.startVideoCapture()
    }
    
    
    // MARK: - Image Picker Controller
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imagePickerControllerDidCancel(picker)
        var videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        var videoURLString = toString(videoURL)
        assetsVC.saveVideoToGalleryGroup(videoURL, completion: { (complete) -> Void in
            if complete {
                self.videoTableCollectionView.reloadData()
            } else {
                println("error")
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
        
        var defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: "cameraIsReady:", name: AVCaptureSessionDidStartRunningNotification, object: nil)
        defaultCenter.addObserver(self, selector: "videoStopped:", name: MPMoviePlayerDidExitFullscreenNotification, object: nil)
        
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
    
}
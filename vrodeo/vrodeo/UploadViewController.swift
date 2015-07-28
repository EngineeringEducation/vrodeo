//
//  CloudinaryViewController.swift
//  vrodeo
//
//  Created by Caitlin on 7/12/15.
//  Copyright (c) 2015 vrodeo. All rights reserved.
//

import UIKit
import AssetsLibrary

class UploadViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // IMPORTANT: Using this for testing only. When app goes live, Cloudinary says you should not include the api_secret
        

        // Do any additional setup after loading the view.
        
    }
    
    func uploadVideo(video: ALAsset, url: NSURL){
        println(video)
        
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        let listTableInput = AWSDynamoDBListTablesInput()
        dynamoDB.listTables(listTableInput).continueWithBlock{ (task: AWSTask!) -> AnyObject! in
            let listTablesOutput = task.result as! AWSDynamoDBListTablesOutput
            
            for tableName : AnyObject in listTablesOutput.tableNames {
                println("\(tableName)")
            }
            
            return nil
        }
        

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

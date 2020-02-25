//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Sudhir Mishra on 24/12/19.
//  Copyright © 2019 .
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }
        
        print("APNs device token:")
        /// Add the category so the "Open Board" action button is added.
       
        
        let defaults = UserDefaults(suiteName: "group.sudhirmishra.ionic.push")
        defaults?.set(nil, forKey: "images")
        defaults?.synchronize()
          bestAttemptContent?.categoryIdentifier = "GENERAL"
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        guard let apnsData = content.userInfo["data"] as? [String: Any] else {
            contentHandler(request.content)
            return
        }
        
        guard let attachmentURL = apnsData["attachment-url"] as? String else {
            contentHandler(request.content)
             
            return
        }
        
        do {
            print("APNs ")
            
           
           // content.title = "test"
            //content.body = "changed"
          
           let defaults = UserDefaults(suiteName: "group.sudhirmishra.ionic.push")
           var x = defaults?.integer(forKey: "badgeCount")
           x = (x ?? 0) + 1
           defaults?.set(x, forKey: "badgeCount")
           content.badge = x as NSNumber?
            // content.badge = 2
            
            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
            
            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
                contentHandler(request.content)
                return
            }
            print("APNs ")
              print(attachment)
            content.attachments = [attachment]
            contentHandler(content.copy() as! UNNotificationContent)
            
        } catch {
            contentHandler(request.content)
            print("Unable to load data: \(error)")
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
extension UNNotificationAttachment {
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?)
        -> UNNotificationAttachment? {
            let fileManager = FileManager.default
            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.sudhirmishra.ionic.push") {
                do {
                    let newDirectory = directory.appendingPathComponent("Images")
                    if (!fileManager.fileExists(atPath: newDirectory.path)) {
                        try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                    let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
                    do {
                        try data.write(to: fileURL, options: [])
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                    
                    let defaults = UserDefaults(suiteName: "group.sudhirmishra.ionic.push")
                    defaults?.set(data, forKey: "images")
                    defaults?.synchronize()
                    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier,
                                                                            url: fileURL,
                                                                            options: options)
                    return imageAttachment
                } catch let error {
                    print("error \(error)")
                }
            }
            return nil
    }
}
private func registerNotificationCategories() {
    let openBoardAction = UNNotificationAction(identifier: UNNotificationDefaultActionIdentifier, title: "Open Board", options: UNNotificationActionOptions.foreground)
    let contentAddedCategory = UNNotificationCategory(identifier: "content_added_notification", actions: [openBoardAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
    UNUserNotificationCenter.current().setNotificationCategories([contentAddedCategory])
}
/*
 
 {   "aps": {
        "category" : "content_added_notification"
        "alert": "Hello!",
        "sound": "default",
        "mutable-content": 1,
        "badge": 1
    },
    "data": {
        "attachment-url": "https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Sun_Life_Financial_Logo.svg/374px-Sun_Life_Financial_Logo.svg.png"
    }
 }
 
 */

//
//  AppDelegate.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 16/10/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    self.prepareApp()
    self.configureThirdParty()
    self.prepareDeviceToken()

    return true
  }
  
  private func prepareApp() {
    if NSUserDefaults.standardUserDefaults().boolForKey(AppConstants.DefaultKeys.APP_ALIVE) {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let rootController = storyboard.instantiateViewControllerWithIdentifier("MainTabC") as! MainTabC
      self.window?.rootViewController = rootController
    }
  }
  
  func configureThirdParty() {
    Fabric.with([Crashlytics.self])
  }
  
  func prepareDeviceToken() {
    if NSUserDefaults.standardUserDefaults().stringForKey(AppConstants.DefaultKeys.DEVICE_TOKEN) == nil {
      let pushNotificationType: UIUserNotificationType = [.Sound, .Alert, .Badge]
      let pushNotificationSetting = UIUserNotificationSettings(forTypes: pushNotificationType, categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(pushNotificationSetting)
      UIApplication.sharedApplication().registerForRemoteNotifications()
    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    print("Device token data: \(deviceToken)")
    let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
    
    let deviceTokenString: String = ( deviceToken.description as NSString )
      .stringByTrimmingCharactersInSet( characterSet )
      .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
    
    print("Device token string:  \(deviceTokenString)")
    
    NSUserDefaults.standardUserDefaults().setValue(deviceTokenString, forKey: AppConstants.DefaultKeys.DEVICE_TOKEN)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("Couldn’t register for remote notification: \(error)")
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    print(userInfo)
  }

}


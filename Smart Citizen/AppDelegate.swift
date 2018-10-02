/**
 * Copyright (c) 2016 Mustafa Hastürk
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Fabric
import Crashlytics
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    self.configureThirdParty()
    self.decideSceneToOpen()
    self.prepareDeviceToken()
    
    return true
  }
  
  func decideSceneToOpen() {
    if UserDefaults.standard.bool(forKey: AppConstants.DefaultKeys.APP_ALIVE) {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let rootController = storyboard.instantiateViewController(withIdentifier: "MainTabC") as! MainTabC
      self.window?.rootViewController = rootController
    }
  }
  
  func configureThirdParty() {
    Fabric.with([Crashlytics.self])
    self.configureAWS()
  }
  
  fileprivate func configureAWS() {    
    let CognitoPoolID = "us-east-1:d91b018b-71d6-4831-9b05-6ca53bb92725"
    
    let Region = AWSRegionType.USEast1 // Cognito Region
    
    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: Region,
                                                            identityPoolId: CognitoPoolID)
    // S3 Region
    let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
    
    AWSServiceManager.default().defaultServiceConfiguration = configuration
  }
  
  func prepareDeviceToken() {
    if UserDefaults.standard.string(forKey: AppConstants.DefaultKeys.DEVICE_TOKEN) == nil {
      let pushNotificationType: UIUserNotificationType = [.sound, .alert, .badge]
      let pushNotificationSetting = UIUserNotificationSettings(types: pushNotificationType, categories: nil)
      UIApplication.shared.registerUserNotificationSettings(pushNotificationSetting)
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("Device token data: \(deviceToken)")
    let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
    
    let deviceTokenString: String = ( deviceToken.description as NSString )
      .trimmingCharacters( in: characterSet )
      .replacingOccurrences( of: " ", with: "" ) as String
    
    print("Device token string:  \(deviceTokenString)")
    
    UserDefaults.standard.setValue(deviceTokenString, forKey: AppConstants.DefaultKeys.DEVICE_TOKEN)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Couldn’t register for remote notification: \(error)")
  }
  
  private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : Any]) {
    print(userInfo)
  }

}


//
//  LockInfoStorage.swift
//  LeeGesturesPassword
//
//  Created by yuanjilee on 15/10/13.
//  Copyright © 2015年 yuanjilee. All rights reserved.
//

/**
  abstract: 数据存储
*/

import UIKit

class LockInfoStorage: NSObject {
  
  fileprivate static let kPassCodeKey: String = "LockPassCodeKey"
  fileprivate static let kTouchIDSwitchKey: String = "touchIDSwitchKey"
  fileprivate static let kGestureSwitchKey: String = "gestureSwithKey"
  
  // passcode
  class func setLockInfo(withString str: String) {
    let defaults: UserDefaults = UserDefaults.standard
    defaults.set(str, forKey: kPassCodeKey)
    defaults.synchronize()
  }
  
  class func getLockInfo() -> String? {
    let defaults: UserDefaults = UserDefaults.standard
    let lockInfo: String? =  defaults.object(forKey: kPassCodeKey) as? String
    return lockInfo
  }
  
  // switch
  class func setSwitchState(withBoolValue value: Bool) {
    let defaults: UserDefaults = UserDefaults.standard
    defaults.set(value, forKey: kGestureSwitchKey)
    defaults.synchronize()
  }

  class func getSwitchState() -> Bool {
    let defaults: UserDefaults = UserDefaults.standard
    let switchState: Bool? = defaults.object(forKey: kGestureSwitchKey) as? Bool
    if let switchState = switchState {
      return switchState
    }
    else {
      return false
    }
  }
  
  
  // touchID
  class func setTouchIDState(withBoolValue value: Bool) {
    let defaults: UserDefaults = UserDefaults.standard
    defaults.set(value, forKey: kTouchIDSwitchKey)
    defaults.synchronize()
  }

  class func getTouchIDState() -> Bool {
    let defaults: UserDefaults = UserDefaults.standard
    let touchIDState: Bool? = defaults.object(forKey: kTouchIDSwitchKey) as? Bool
    if let touchIDState = touchIDState {
      return touchIDState
    }
    else {
      return false
    }
  }
  
  
  //clear
  class func clearAllGestureLockInfo() {
    let defaults: UserDefaults = UserDefaults.standard
    defaults.set(nil, forKey: kPassCodeKey)
    defaults.set(false, forKey: kTouchIDSwitchKey)
    defaults.set(false, forKey: kGestureSwitchKey)
  }
}



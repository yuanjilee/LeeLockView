//
//  LockViewController.swift
//  LeeGesturesPassword
//
//  Created by yuanjilee on 15/10/12.
//  Copyright © 2015年 yuanjilee. All rights reserved.
//

import UIKit
import LocalAuthentication

/// 绘制完手势后的事件处理 (setting + verifiy)
///
/// 参数: 无
///
///
/// @since 1.0
/// @author yuanjilee
class LockViewController: UIViewController {
  
  
  // MARK: - Enum
  
  enum LockType: String {
    case setting = "setting"
    case verify = "verify"
    case modify = "modify"
  }
  
  
  // MARK: - Commons
  
  var lock: LockView!
  var indicator: LockIndicatorView!
  let kScreenSize: CGSize = UIScreen.main.bounds.size
  let kPassCodeAttemptAmount: Int = 4
  let kCornerRadius = 5.0
  
  
  // MARK: - Property
  
  var lockType: LockType = .setting
  fileprivate var _lockTitleLabel: UILabel?
  fileprivate var _avatarImageView: UIImageView!
  //三步提示
  fileprivate var _tip1: String = ""
  fileprivate var _tip2: String = ""
  fileprivate var _tip3: String = ""
  //密码
  fileprivate var _passcodefirst: String = ""
  fileprivate var _passcodeConfirm: String = ""
  fileprivate var _passcodeSaved: String = ""
  fileprivate var _passcodeAttemtCount: Int = 0
  
  lazy var forgetBtn: UIButton = { [unowned self] in
    let forgetBtn: UIButton = UIButton(type: .custom)
    forgetBtn.addTarget(self, action: #selector(LockViewController._forgetBtnClick), for: .touchUpInside)
    forgetBtn.setTitle(NSLocalizedString("FORGET_PASSWORD", comment: ""), for: UIControlState())
    forgetBtn.setTitleColor(kForgetBtnColorNormal, for: UIControlState())
    forgetBtn.titleLabel?.font = UIFont.systemFont(ofSize: kSmallFontSize)
    return forgetBtn
  }()
  
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _setupApperance()
    _prepare()
    
    // TouchID
    let isOpenTouchIDSwitch = LockInfoStorage.getTouchIDState()
    if isOpenTouchIDSwitch {
      _touchID()
    }
  }
}

extension LockViewController {
  
  fileprivate func _prepare() {
    lock = LockView()
    lock.delegate = self
    view.addSubview(lock)
    
    switch lockType {
      
    case .setting:
      _initIndicatorView()
      _initLockTitleLabel()
      _lockTitleLabel?.text = NSLocalizedString("DRAW_GESTURE_PASSWORD", comment: "")

    case .verify:
      
      _initView()
      _initAvatarImageView()
      _initLockTitleLabel()
      _lockTitleLabel?.text = NSLocalizedString("ENTER_THE_GESTURE_PASSWORD", comment: "")
      
    default:
      break
    }
    _initLockView()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { _ in
      self.configureLayout(size)
    }, completion: nil)
  }
  
  open func configureLayout(_ size: CGSize = UIApplication.shared.delegate?.window??.bounds.size ?? .zero) {
    
  }
  
  fileprivate func _initView() {
    view.addSubview(forgetBtn)
    forgetBtn.translatesAutoresizingMaskIntoConstraints = false
    view.addConstraints([NSLayoutConstraint(item: forgetBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                         NSLayoutConstraint(item: forgetBtn, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)])
    
    let isOpenTouchIDSwitch = LockInfoStorage.getTouchIDState()
    if isOpenTouchIDSwitch {
      let fingerBtn: UIButton = UIButton(type: .custom)
      fingerBtn.addTarget(self, action: #selector(LockViewController._touchID), for: .touchUpInside)
      fingerBtn.setTitle(NSLocalizedString("FINGERPRINT_UNLOCK", comment: ""), for: UIControlState())
      fingerBtn.setTitleColor(kForgetBtnColorNormal, for: UIControlState())
      fingerBtn.titleLabel?.font = UIFont.systemFont(ofSize: kSmallFontSize)
      view.addSubview(fingerBtn)
      
      fingerBtn.translatesAutoresizingMaskIntoConstraints = false
      view.addConstraints([NSLayoutConstraint(item: fingerBtn, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20),
                           NSLayoutConstraint(item: fingerBtn, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)])
      
      //忘记密码位置左移,并移除其上所有约束  或 snp.remakeContraints
      forgetBtn.removeConstraints(forgetBtn.constraints)
      for constraints in (forgetBtn.superview?.constraints)! {
        if constraints.firstItem.isEqual(forgetBtn) {
          forgetBtn.superview?.removeConstraint(constraints)
        }
      }
      
      view.addConstraints([NSLayoutConstraint(item: forgetBtn, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20),
                           NSLayoutConstraint(item: forgetBtn, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)])
    }
  }
  
  
  fileprivate func _initAvatarImageView() {
    
    if lockType == .verify {
      _avatarImageView = UIImageView()
      _avatarImageView.layer.masksToBounds = true
      _avatarImageView.layer.cornerRadius = CGFloat(35)
      
      // 头像 网络请求用户头像
//      let me: WTCUser = WTCDirector.sharedDirector().me()
//      _avatarImageView.WTK_setAvatarForUser(me, length: 35)
      
      _avatarImageView.image = UIImage(named: "ico_person_default")
      
      view.addSubview(_avatarImageView)
      
      _avatarImageView.translatesAutoresizingMaskIntoConstraints = false
      view.addConstraints([NSLayoutConstraint(item: _avatarImageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 60),
                           NSLayoutConstraint(item: _avatarImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70),
                           NSLayoutConstraint(item: _avatarImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70),
                           NSLayoutConstraint(item: _avatarImageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)])
    }
  }
  
  fileprivate func _initIndicatorView() {
    indicator = LockIndicatorView()
    view.addSubview(indicator)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    view.addConstraints([NSLayoutConstraint(item: indicator, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 24 + 20),
                         NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
                         NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
                         NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 8)])
  }
  
  fileprivate func _initLockTitleLabel() {
    if let _ = _lockTitleLabel {return}
    else {
      _lockTitleLabel = UILabel()
      view.addSubview(_lockTitleLabel!)
      _lockTitleLabel?.textAlignment = .center
      _lockTitleLabel?.textColor = kTipColorNormal
      _lockTitleLabel?.font = UIFont.systemFont(ofSize: kNormalFontSize)
      _lockTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
      view.addConstraints([NSLayoutConstraint(item: _lockTitleLabel!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: _lockTitleLabel!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: _lockTitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)])
      if lockType == .verify {
        view.addConstraint(NSLayoutConstraint(item: _lockTitleLabel!, attribute: .top, relatedBy: .equal, toItem: _avatarImageView, attribute: .bottom, multiplier: 1, constant: 20))
      }
      else if lockType == .setting {
        view.addConstraint(NSLayoutConstraint(item: _lockTitleLabel!, attribute: .top, relatedBy: .equal, toItem: indicator, attribute: .bottom, multiplier: 1, constant: 0))
      }
  }
}
  
  fileprivate func _initLockView() {
    lock.translatesAutoresizingMaskIntoConstraints = false
    if UIDevice.current.userInterfaceIdiom == .pad {
      view.addConstraints([NSLayoutConstraint(item: lock, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: lock, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.2, constant: 0),
                           NSLayoutConstraint(item: lock, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320),
                           NSLayoutConstraint(item: lock, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)])
    } else {
      
      let leftMagin = (48 / 376) * UIScreen.main.bounds.width
      let lockW = UIScreen.main.bounds.width - (2 * leftMagin)
      var lockTopMagin = (214 / 667) * UIScreen.main.bounds.height
      if lockType == .verify {
        lockTopMagin = (314 / 667) * UIScreen.main.bounds.height
      }
      
      view.addConstraints([NSLayoutConstraint(item: lock, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: lock, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: lockTopMagin),
                           NSLayoutConstraint(item: lock, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lockW),
                           NSLayoutConstraint(item: lock, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: lockW)])
    }
  }
  
  //创建密码
  fileprivate func _creatPasscode(_ passcode: String) {
    
    if _passcodefirst == "" && _passcodeConfirm == "" {
      _passcodefirst = passcode
      _setTip(_tip2)
      
    }
    else if _passcodefirst != "" && _passcodeConfirm == "" {
      _passcodeConfirm = passcode
      if _passcodefirst != _passcodeConfirm {
        debugPrint("与上次输入不一致，请重新设置");
        _tip2 = NSLocalizedString("INCORRECT_PATTERN", comment: "")
        _passcodeConfirm = ""
        _passcodefirst = ""
        _setTip(_tip2)
        //置空
        indicator.setSelectedArray([])
        lock.showErrorLockView()
      }
      else {
        debugPrint("两次密码一致")
        _setTip(_tip3)
        //设置成功,插入VC
        let lockInfo: String? = LockInfoStorage.getLockInfo()
        if lockInfo == nil {
          let setting:UIViewController = LockSettingViewController()
          let count = navigationController?.viewControllers.count
          navigationController?.viewControllers.insert(setting, at: count!-1)
        }
        
        LockInfoStorage.setLockInfo(withString: _passcodefirst)
        LockInfoStorage.setSwitchState(withBoolValue: true)
        lock.showDismissLockView()
        //成功提示语
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1000 * USEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
          _ = self.navigationController?.popViewController(animated: true)
        })
      }
    }
  }
  
  //验证密码
  fileprivate func _verifyPassCode(_ passcode: String) {
    let storageCode = LockInfoStorage.getLockInfo()
    if passcode == storageCode {
      dismiss(animated: true, completion: nil)
    }
    else {
      if _passcodeAttemtCount <= 0 { // 连续输错五次密码
        dismiss(animated: true) { () -> Void in
          //清空手势数据
          LockInfoStorage.clearAllGestureLockInfo()
        }
        // 登出操作
//        _logout()
      }
      else {
        _passcodeAttemtCount -= 1
        _setErrorTip(_tip2)
      }
    }
  }
  
  fileprivate func _setTip(_ tip: String) {
    _lockTitleLabel?.text = tip
    _lockTitleLabel?.textColor = kTipColorNormal
  }
  
  fileprivate func _setErrorTip(_ tip: String) {
    //图形错误
    lock.showErrorLockView()
    //错误标签
    _lockTitleLabel?.text = tip
    _lockTitleLabel?.textColor = kTipColorError
    _shake()
  }
  
  fileprivate func _shake() {
    let caAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    let offset: CGFloat = 15
    caAnimation.values = [(-offset),(0),(offset),(0),(-offset),(0),(offset),(0)]
    caAnimation.duration = 0.2
    caAnimation.repeatCount = 2
    caAnimation.isRemovedOnCompletion = true
    _lockTitleLabel?.layer.add(caAnimation, forKey: "shake")
  }
  
}

extension LockViewController: LockViewDelegate {
  
  //MARK: - LockViewDelegate
  
  func lockViewDelegate(_ lockView: LockView, passCode: String, selectedArray: [Int]) {

    let passcode = passCode
    debugPrint("passcode = \(passcode)")
    
    switch lockType {
    case .setting:
      _tip1 = NSLocalizedString("SET_A_PATTERN_PASSWORD", comment: "")
      _tip2 = NSLocalizedString("ENTER_AGAIN_FOR_CONFIRAMTION", comment: "")
      _tip3 = NSLocalizedString("CREATING_SUCCESS", comment: "")
      
      //密码长度4位
      if passcode.count < 4 {
        _tip2 = NSLocalizedString("AT_LAST_4_POINTS_SET_AGAIN", comment: "")
        _setTip(_tip2)
      }
      else {
        //刷新 indicator
        if lockType == .setting {
          indicator.setSelectedArray(selectedArray)
        }
        _creatPasscode(passcode)
      }
      
    case .verify:
      _tip1 = NSLocalizedString("ENTER_THE_GESTURE_PASSWORD", comment: "")
      _tip2 = "密码错误，还可以再输入\(_passcodeAttemtCount)次"
      let alert: String = String(format:NSLocalizedString("INCORRECT_PATTERN_CHANCE_LEFT", comment: "") , _passcodeAttemtCount)
      _tip2 = NSLocalizedString(alert, comment: "")
      _tip3 = NSLocalizedString("ENTER_THE_GESTURE_PASSWORD", comment: "")
      _verifyPassCode(passcode)
    default:
      break
    }
    
  }
  
}

extension LockViewController {
  
  //MARK: - LockType
  
  class func showSettingLockViewController(_ aboveViewController: UIViewController) -> LockViewController {
    let lockVC: LockViewController = LockViewController()
    lockVC.navigationItem.title = NSLocalizedString("PATTERN_PASSWORD", comment: "");
    lockVC.lockType = .setting
    lockVC._passcodeAttemtCount = lockVC.kPassCodeAttemptAmount
    aboveViewController.navigationController?.pushViewController(lockVC, animated: true)
    return lockVC
  }
  
  class func showVerifyLockViewController(_ aboveViewController: UIViewController) -> LockViewController {
    let lockVC: LockViewController = LockViewController()
    lockVC.navigationController?.isNavigationBarHidden = true
    lockVC.lockType = .verify
    lockVC._passcodeAttemtCount = lockVC.kPassCodeAttemptAmount
    aboveViewController.present(lockVC, animated: false, completion: nil)
    return lockVC
  }
}

extension LockViewController {
  
  @objc fileprivate func _forgetBtnClick() {
    dismiss(animated: true) { () -> Void in
      //清空手势数据
      LockInfoStorage.clearAllGestureLockInfo()
    }
    // 登出操作
//    _logout()
  }
  
  //MARK: - TouchID
  
  @available(iOS 8.0, *)
   @objc fileprivate func _touchID() {
    let context: LAContext = LAContext()
    var authorError: NSError?
    context.localizedFallbackTitle = ""
    
    if #available(iOS 9.0, *) {
      if  context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorError) {
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString("UNLOCK_VALIDATION_WORKTILE", comment: ""), reply: { (success: Bool, error: Error?) -> Void in
          
          if success {
            debugPrint("验证成功 \(success)")
            self.dismiss(animated: false, completion: nil)
          }
          else {
            if let error = error {
              switch error._code {
                
              case LAError.Code.authenticationFailed.rawValue:
                debugPrint("Faild")
                
              case LAError.Code.userCancel.rawValue:
                debugPrint("User cancel")
                
              case LAError.Code.systemCancel.rawValue:
                debugPrint("System cancel")
                
              case LAError.Code.touchIDLockout.rawValue:
                debugPrint("Lock out")
                
              case LAError.Code.touchIDNotAvailable.rawValue:
                debugPrint("Not avaliable")
                
              case LAError.Code.userFallback.rawValue:
                debugPrint("Fallback")
                
              default:
                debugPrint("Default")
                break
              }
            }
          }
        })
      }
      else {
        let unSupportAlert: UIAlertView = UIAlertView(title: NSLocalizedString("TOUCH_ID_SYSTEM_IS_NOT_TUENED_ON", comment: ""), message: NSLocalizedString("PLEASE_OPEN_THE_SYSTEM_SETTING_FOR_TOUCHID", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
        unSupportAlert.tag = 10
        unSupportAlert.show()
      }
    }
    else {
      // Fallback on earlier versions
      if  context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorError) {
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("UNLOCK_VALIDATION_WORKTILE", comment: ""), reply: { (success: Bool, error: Error?) -> Void in
          
          if success {
            debugPrint("验证成功 \(success)")
            self.dismiss(animated: false, completion: nil)
          }
          else {
            if let error = error {
              switch error._code {
                
              case LAError.Code.authenticationFailed.rawValue:
                debugPrint("Faild")
                
              case LAError.Code.userCancel.rawValue:
                debugPrint("User cancel")
                
              case LAError.Code.systemCancel.rawValue:
                debugPrint("System cancel")
                
              case LAError.Code.touchIDNotAvailable.rawValue:
                debugPrint("Not avaliable")
                
              case LAError.Code.userFallback.rawValue:
                debugPrint("Fallback")
                
              default:
                debugPrint("Default")
                break
              }
            }
          }
        })
      }
      else {
        let unSupportAlert: UIAlertView = UIAlertView(title: NSLocalizedString("TOUCH_ID_SYSTEM_IS_NOT_TUENED_ON", comment: ""), message: NSLocalizedString("PLEASE_OPEN_THE_SYSTEM_SETTING_FOR_TOUCHID", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
        unSupportAlert.tag = 10
        unSupportAlert.show()
      }
    }
  }
  
  
  //MARK: - Apperance
  
  fileprivate func _setupApperance() {
    view.backgroundColor = kVerifyBackgroundColor
  }
  
}

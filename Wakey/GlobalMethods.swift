//
//  GlobalMethods.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation
import EasyTipView
import NVActivityIndicatorView
import PopupDialog
import MediaPlayer

//converting the time selected from a time picker to a date when the alarm should fire

extension UIView {
  func addTopBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
    self.layer.addSublayer(border)
  }
    
  func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
    self.layer.addSublayer(border)
  }
}

func convertSelectedTimeToDate(time: Date) -> Date {
    let calendar = Calendar.current
    let hour = Calendar.current.component(.hour, from: time)
    let minute = Calendar.current.component(.minute, from: time)
    var whenToFire = calendar.date(
        bySettingHour: hour,
        minute: minute,
        second: 0,
        of: time)!
    if whenToFire < Date() {
        whenToFire = Calendar.current.date(byAdding: .day, value: 1, to: whenToFire)!
    }
    return whenToFire
}

//get string from time interval
extension TimeInterval {
    private var seconds: Int {
        return Int(self) % 60
    }

    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }

    private var hours: Int {
        return Int(self) / 3600
    }

    var stringTime: String {
        if hours != 0 {
            if minutes != 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes != 0 {
            return "\(minutes)m"
        } else {
            return "less than a minute"
        }
    }
}


//Rotate image
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }
        return self
    }
}

//to programatically set volume
extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
      slider?.value = volume
    }
  }
}

//present pop up with title and message
func presentPopUpWith(title: String, message: String, viewController: UIViewController, image: UIImage?) -> UIViewController {
    //Button init
    let button = DefaultButton(title: "GOT IT", dismissOnTap: true) {}
    //Pop up init
    let popUp = PopupDialog(title: title, message: message, image: image)
    //setting the animation
    popUp.transitionStyle = .zoomIn
    popUp.addButton(button)
    
    viewController.present(popUp,animated: true,completion: nil)
    return popUp
}

func getPopUpWith(title: String, message: String, image: UIImage?) -> PopupDialog {
    //Button init
    let button = DefaultButton(title: "GOT IT", dismissOnTap: true) {}
    //Pop up init
    let popUp = PopupDialog(title: title, message: message, image: image)
    //setting the animation
    popUp.transitionStyle = .zoomIn
    popUp.addButton(button)
    return popUp
}




//Method configures settings for a standard pop up when the app is launched
func configurePopUp(backgroundColor: UIColor, textColor: UIColor) {
    //Pop up config
    let dialogAppearance = PopupDialogDefaultView.appearance()
    //dialogAppearance.backgroundColor      = Constants.adaptiveColors.postBackgroundColor
    dialogAppearance.titleFont            = UIFont(name: "Avenir-heavy", size: 15)!
    dialogAppearance.titleColor           = UIColor.init(named: "AppRedColor")
    dialogAppearance.titleTextAlignment   = .center
    dialogAppearance.messageFont          = UIFont(name: "Avenir-medium", size: 12)!
    dialogAppearance.messageColor         = textColor
    dialogAppearance.messageTextAlignment = .center
    //button config
    let buttonAppearance = DefaultButton.appearance()
    // Default button
    buttonAppearance.titleFont      = UIFont(name: "Avenir-Medium", size: 14)!
    buttonAppearance.backgroundColor = backgroundColor
    buttonAppearance.titleColor     = UIColor.init(named: "AppRedColor")
    buttonAppearance.buttonColor    = .clear
    buttonAppearance.separatorColor = UIColor(named: "AppRedColor")?.withAlphaComponent(0.5)
    
    // Customize the container view appearance
    let pcv = PopupDialogContainerView.appearance()
    pcv.backgroundColor = backgroundColor
    pcv.cornerRadius    = 10
    pcv.shadowEnabled   = true
    pcv.shadowColor     = .black
    pcv.shadowOpacity = 0.8
}

//Method configures settings for a standard pop up when the app is launched
func configurePopUpForImage(backgroundColor: UIColor, textColor: UIColor) {
    //Pop up config
    let dialogAppearance = PopupDialogDefaultView.appearance()
    //dialogAppearance.backgroundColor      = Constants.adaptiveColors.postBackgroundColor
    dialogAppearance.titleFont            = UIFont(name: "Avenir-heavy", size: 1)!
    dialogAppearance.titleColor           = UIColor.init(named: "AppRedColor")
    dialogAppearance.titleTextAlignment   = .center
    dialogAppearance.messageFont          = UIFont(name: "Avenir-Book", size: 1)!
    dialogAppearance.messageColor         = textColor
    dialogAppearance.messageTextAlignment = .center
    //button config
    let buttonAppearance = DefaultButton.appearance()
    // Default button
    buttonAppearance.titleFont      = UIFont(name: "Avenir-Medium", size: 14)!
    buttonAppearance.backgroundColor = backgroundColor
    buttonAppearance.titleColor     = UIColor.init(named: "AppRedColor")
    buttonAppearance.buttonColor    = .clear
    buttonAppearance.separatorColor = UIColor(white: 0.9, alpha: 0.5)
    
    // Customize the container view appearance
    let pcv = PopupDialogContainerView.appearance()
    pcv.backgroundColor = backgroundColor
    pcv.cornerRadius    = 10
    pcv.shadowEnabled   = true
    pcv.shadowColor     = .black
    pcv.shadowOpacity = 0.8
}

func configEasyTipsPrefs() {
    var preferences = EasyTipView.Preferences()
    preferences.drawing.font = UIFont(name: "Avenir-Medium", size: 13)!
    preferences.drawing.foregroundColor = UIColor.white
    preferences.drawing.backgroundColor = UIColor.init(named: "AppRedColor")!
    preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.any
    preferences.drawing.arrowHeight = 8
    preferences.positioning.bubbleHInset = 10
    preferences.positioning.bubbleVInset = 4
    preferences.animating.showDuration = 0.3
    preferences.animating.dismissDuration = 0.3
    preferences.drawing.shadowColor = .black
    preferences.drawing.shadowOpacity = 0.4
    preferences.drawing.shadowRadius = 2
    preferences.drawing.shadowOffset = CGSize(width: 0.0, height: 2.0)
    EasyTipView.globalPreferences = preferences
}

func loadingCollectionView(backgroundColor: UIColor, indicatorColor: UIColor) -> UIView {
    let view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = backgroundColor
    let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 20, y: view.center.y - 20, width: 40, height: 40), type: .lineScale, color: indicatorColor, padding: 5)
    view.addSubview(activityIndicator)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        activityIndicator.startAnimating()
    }
    
    return view
}


func jsonDateToDate(jsonStr: String) -> Date {
    //print("parsing this date:")
    //print(jsonStr)

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = dateFormatter.date(from:jsonStr) {
        return date
    } else {
        return Date()
    }
}


extension UIButton {
    func roundedButton() {
        self.layer.cornerRadius = 0.5*self.bounds.size.width
        self.clipsToBounds = true
    }
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    // Returns the data for the specified image in JPEG format.
    // If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    // - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

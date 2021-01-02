//
//  ReactionsView.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/21.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit


protocol reactionViewDelegate: class {
    func userDidReactWith(emojiName: String, forAlarm: receivedAlarm)
}

class ReactionsView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var reaction1: UIButton!
    @IBOutlet weak var reaction2: UIButton!
    @IBOutlet weak var reaction3: UIButton!
    @IBOutlet weak var reaction4: UIButton!
    @IBOutlet weak var reaction5: UIButton!
    @IBOutlet weak var reaction6: UIButton!
    
    weak var delegate: reactionViewDelegate?
    
    
    var reactingToAlarm: receivedAlarm!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    var shortnames = ["heart_reaction", "rofl_face", "party_face", "clap_reaction", "blowing_up_face", "crazy_face"]
    
    func initSubviews() {
        // standard initialization logic
        Bundle.main.loadNibNamed("ReactionsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        titleLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    
    
    @IBAction func reactionPressed(_ sender: UIButton, event: UIEvent) {
        //["heart_reaction", "rofl_face", "party_face", "clap_reaction", "blowing_up_face", "crazy_face"]
        var imageName = ""
        switch sender {
        case reaction1:
            imageName = shortnames[0]
            break
        case reaction2:
            imageName = shortnames[1]
            break
        case reaction3:
            imageName = shortnames[2]
            break
        case reaction4:
            imageName = shortnames[3]
            break
        case reaction5:
            imageName = shortnames[4]
            break
        case reaction6:
            imageName = shortnames[5]
            break
        default:
            return
        }
        delegate?.userDidReactWith(emojiName: imageName, forAlarm: reactingToAlarm)
        if let touch = event.touches(for: sender)?.first {
            let thePoint = touch.location(in: UIApplication.shared.keyWindow!)
            let fromFrame = sender.frame
            let fromRect = CGRect(x: thePoint.x - fromFrame.width/2, y: thePoint.y - fromFrame.height/2, width: fromFrame.width, height: fromFrame.height)
            performReactionAnimation(fromButtonFrame: fromRect, imageName: imageName)
        }
    }
    
    func performReactionAnimation(fromButtonFrame: CGRect, imageName: String) {
        let emojiImage = UIImage(named: imageName)!
        (0...10).forEach { (_) in
            generateAnimatedReaction(emojiImage: emojiImage, reactionButtonFrame: fromButtonFrame)
        }
    }

    
}


func generateAnimatedReaction(emojiImage: UIImage, reactionButtonFrame: CGRect) {
    //print("FRAME")
    let reaction = UIImageView(frame: reactionButtonFrame)
    reaction.contentMode = .scaleAspectFit
    reaction.image = emojiImage
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.path = customPath(startPoint: reaction.center).cgPath
    animation.duration = 0.2 + drand48() * 1
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
    
    animation.delegate = AnimationDelegate(
        didStart: nil,
        didStop: {
            reaction.removeFromSuperview()
    })
    reaction.layer.add(animation, forKey: nil)
    UIApplication.shared.keyWindow!.addSubview(reaction)
}


class AnimationDelegate: NSObject, CAAnimationDelegate {
    typealias AnimationCallback = (() -> Void)

    let didStart: AnimationCallback?
    let didStop: AnimationCallback?

    init(didStart: AnimationCallback?, didStop: AnimationCallback?) {
        self.didStart = didStart
        self.didStop = didStop
    }

    internal func animationDidStart(_ anim: CAAnimation) {
        didStart?()
    }

    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didStop?()
    }
}



func customPath(startPoint: CGPoint) -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: startPoint)
    let endPoint = CGPoint(x: startPoint.x, y: 0)
    let randomXShift = CGFloat(drand48()) * 300.0
    
    let chance = drand48()
    if chance > 0.5 {
        //variation 1
        let cp1 = CGPoint(x: startPoint.x - 60 - randomXShift, y: startPoint.y/4)
        let cp2 = CGPoint(x: startPoint.x + 60 + randomXShift, y: startPoint.y/2)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    } else {
        //variation 2
        let cp1 = CGPoint(x: startPoint.x + 60 + randomXShift, y: startPoint.y/4)
        let cp2 = CGPoint(x: startPoint.x - 60 - randomXShift, y: startPoint.y/2)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    }
    
    
    //variation 2
    
    return path
}

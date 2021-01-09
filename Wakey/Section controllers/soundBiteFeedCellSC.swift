//
//  soundBiteFeedCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2021/01/05.
//  Copyright © 2021 Wakey. All rights reserved.
//

import IGListKit
import Foundation
import NVActivityIndicatorView


class soundBiteFeedCellSC: ListSectionController {
    
    var soundBite: soundBite!
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = self.collectionContext?.containerSize.width else {
            return CGSize(width: UIScreen.main.bounds.width, height: 260)
        }
        return CGSize(width: width , height: 260)
    }
    
    var alarm: curateListAlarm!
    var currPlayingState = playButtonState.notPlaying
    
    enum playButtonState: String {
        case playing
        case paused
        case notPlaying
        case loading
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: soundBiteFeedCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? soundBiteFeedCell {
            cell.sc = self
            cell.accountTopLabel.text = soundBite.associatedProfile.username
            cell.accountBottomLabel.text = soundBite.createdAt.getElapsedInterval() + " ago"
            if let proPicUrl = URL(string: soundBite.associatedProfile.profilePicUrl) {
                cell.accountProPic.sd_setImage(with: proPicUrl)
            }
            if let imgUrl = URL(string: soundBite.imageUrl) {
                cell.soundBiteImage.sd_setImage(with: imgUrl)
            }
            cell.soundBiteTopLabel.setTitle(soundBite.title, for: .normal)
            cell.soundBiteMiddleLabel.setTitle(soundBite.category, for: .normal)
            cell.soundBiteBottomLabel.text = "\"" + soundBite.transcript + "\""
            cell.numSentLabel.text = String(soundBite.timesSent)
            configurePlayButton(cell: cell, isPlaying: currPlayingState)
            if soundBite.explicit {
                cell.explicitSymbol.isHidden = false
            } else {
                cell.explicitSymbol.isHidden = true
            }
        }
        return cell
    }
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
        //
    }
    
    
    func configurePlayButton(cell: soundBiteFeedCell, isPlaying: playButtonState) {
        switch isPlaying {
        case playButtonState.playing:
            cell.activityIndicator?.removeFromSuperview()
            cell.soundBitePlayButton.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            cell.soundBitePlayButton.isEnabled = true
        case playButtonState.paused:
            cell.activityIndicator?.removeFromSuperview()
            cell.soundBitePlayButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            cell.soundBitePlayButton.isEnabled = true
        case playButtonState.notPlaying:
            cell.activityIndicator?.removeFromSuperview()
            cell.soundBitePlayButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            cell.soundBitePlayButton.isEnabled = true
        case playButtonState.loading:
            cell.activityIndicator?.removeFromSuperview()
            cell.activityIndicator = NVActivityIndicatorView(frame: cell.soundBitePlayButton.bounds, type: .circleStrokeSpin, color: UIColor(named: "AppRedColor"), padding: 6)
            cell.activityIndicator!.startAnimating()
            cell.soundBitePlayButton.addSubview(cell.activityIndicator!)
            cell.soundBitePlayButton.setImage(UIImage(), for: .normal)
            cell.soundBitePlayButton.isEnabled = false
        default:
            cell.soundBitePlayButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
        
    }
    
    
    func playButtonPressed(cell: soundBiteFeedCell) {
        guard let vc = self.viewController as? soundBitesFeedVC else {return}
        vc.userPressedPlay(cell: cell, soundBite: self.soundBite)
    }
    
    
    
    func sendSoundBitePressed(cell: soundBiteFeedCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "SelectRecipientsVC") as! SelectRecipientsVC
        nextVC.soundBite = self.soundBite
        nextVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        guard let vc = self.viewController as? soundBitesFeedVC else {return}
        vc.present(nextVC, animated: true, completion: nil)
    }
   
    
}

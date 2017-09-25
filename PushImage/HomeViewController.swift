//
//  HomeViewController.swift
//  PushImage
//
//  Created by Lawrence Tan on 5/9/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Cocoa
import Alamofire

class HomeViewController: NSViewController {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var staticLabel: NSTextField!
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    @IBOutlet weak var dragView: DragView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragView.delegate = self
        loadingSpinner.isHidden = true
    }
}

extension HomeViewController: DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL) {
        loadingSpinner.isHidden = false
        loadingSpinner.startAnimation(self.view)
        staticLabel.isHidden = true
        
        Alamofire.upload(multipartFormData: { (data: MultipartFormData) in
            data.append(URL as URL, withName: "upload")
        }, to: "http://uploads.im/api?format=json") { [weak self] (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard
                        let dataDict = response.result.value as? NSDictionary,
                        let data = dataDict["data"] as? NSDictionary,
                        let imgUrl = data["img_url"] as? String else { return }
                    
                    self?.loadingSpinner.isHidden = true
                    self?.loadingSpinner.stopAnimation(self?.view)
                    self?.staticLabel.isHidden = false
                    self?.showSuccessAlert(url: imgUrl)
                }
            case .failure(let encodingError):
                self?.staticLabel.isHidden = false
                print(encodingError)
            }
        }
    }
    
    fileprivate func showSuccessAlert(url: String) {
        let alert = NSAlert()
        alert.messageText = url
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Copy to clipboard")
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            NSPasteboard.general().clearContents()
            NSPasteboard.general().setString(url, forType: NSPasteboardTypeString)
        }
    }
}

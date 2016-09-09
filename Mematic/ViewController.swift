//
//  ViewController.swift
//  Mematic
//
//  Created by Y50-70 on 09/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit
import AssetsLibrary

// Meme structure
struct Meme {
    let topText: String!
    let bottomText: String!
    let originalImage: UIImage!
    let memedImage: UIImage!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!

    // Predefine text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : 0.3
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        //topTextView.defaultTextAttributes = memeTextAttributes
        topTextView.delegate = self
        //bottomTextView.defaultTextAttributes = memeTextAttributes
        bottomTextView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Disables camera if not available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // Displays image selected from image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        memeImageView.image = pickerImage
        dismissViewControllerAnimated(true, completion: nil)
    }

    // Choose image from album
    @IBAction func chooseImageFromAlbum(sender: AnyObject) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerView, animated: true, completion: nil)
    }

    // Choose image from camera
    @IBAction func chooseImageFromCamera(sender: AnyObject) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        self.presentViewController(pickerView, animated: true, completion: nil)
    }

    // Subscription to observers
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }

    // Unsubscription from observers
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    

    // Shows keyboard
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    // Hides keyboard
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }

    // Get keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    // Hides keyboard on hitting return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    // Clears text field
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    // Generates meme image
    func generateMemedImage() -> UIImage {

        // Hides toolbar and navigation bar
        toolbar.hidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        // Captures the screen
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Show toolbar and navigation bar
        toolbar.hidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        return memedImage
    }

    // Saves Image
    @IBAction func saveMemeImage(sender: AnyObject) {
        //Create the meme
        let meme = Meme( topText: topTextView.text!,
                         bottomText: bottomTextView.text!, originalImage:
            memeImageView.image, memedImage: generateMemedImage())

        // Call to save image to photo Library
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // Logs result of saving image
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            print("Successfully Saved")
        } else {
            print("Error while saving!")
        }
    }

    // Action to share image
    @IBAction func shareMeme(sender: AnyObject) {
        let firstActivityItem = "my text"
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        self.navigationController!.presentViewController(activityViewController, animated: true, completion: nil)
    }
}


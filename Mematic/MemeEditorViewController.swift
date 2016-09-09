//
//  MemeEditorViewController.swift
//  Mematic
//
//  Created by Y50-70 on 09/09/16.
//  Copyright © 2016 Chashmeet Singh. All rights reserved.
//

import UIKit
import AssetsLibrary

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!


    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.5
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTextField(topTextView, defaultText: "TOP")
        prepareTextField(bottomTextView, defaultText: "BOTTOM")
    }

    func prepareTextField(textField: UITextField, defaultText: String) {
        // Predefine text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3
        ]
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.autocapitalizationType = .AllCharacters
        textField.textAlignment = .Center

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
        chooseImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    // Choose image from camera
    @IBAction func chooseImageFromCamera(sender: AnyObject) {
        chooseImage(UIImagePickerControllerSourceType.Camera)
    }

    func chooseImage(source: UIImagePickerControllerSourceType) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        pickerView.sourceType = source
        self.presentViewController(pickerView, animated: true, completion: nil)
    }

    // Subscription to observers
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
        if bottomTextView.editing {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }

    // Hides keyboard
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }

    // Generates meme image
    func generateMemedImage() -> UIImage {

        // Hides toolbar and navigation bar
        toolbar.hidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)

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
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        return memedImage
    }

    // Saves Image
    @IBAction func saveMemeImage(sender: AnyObject) {
        saveImageToPhotoLibrary()
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
        let memedImage = generateMemedImage()
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        activityViewController.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                self.saveImageToPhotoLibrary()
            }
        }

        self.navigationController!.presentViewController(activityViewController, animated: true, completion: nil)
    }

    func saveImageToPhotoLibrary() {
        //Create the meme
        let meme = Meme( topText: self.topTextView.text!,
                         bottomText: self.bottomTextView.text!, originalImage:
            memeImageView.image, memedImage: self.generateMemedImage())

        // Call to save image to photo Library
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, self, #selector(MemeEditorViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}


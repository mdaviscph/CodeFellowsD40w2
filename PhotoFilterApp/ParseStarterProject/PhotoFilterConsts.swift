//
//  PhotoFilterConsts.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/10/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import CoreGraphics

struct StringConsts {
  static let ImportPhotoFrom = "Import a Photo"
  static let PickImport = "from..."
  static let CameraAction = "Camera"
  static let SavedPhotosAlbumAction = "Saved Photos Album"
  static let PhotoLibraryAction = "Photo Library"
  static let GalleryAction = "Gallery"
  static let CancelAction = "Cancel"
  static let ChooseFilter = "Choose a Filter"
  static let SaveOrShare = "Save or Share"
  static let PickSave = "your photo to..."
  static let UploadAction = "Save to the Cloud"
  static let SaveToPhoneAction = "Save to Phone (not yet..)"
  static let ShareOnTwitterAction = "Share on Twitter"
  static let ParsePostClassname = "PhotoFilterApp"
  static let PostImage = "Image"
  static let PostImageFilename = "test.jpg"
  static let TwitterImageText = "testing tweeting with image from an iOS app that I am working on"
  }

struct SizeConsts {
  static let CollectionViewAnimationDuration = 0.3
  static let CollectionViewBottomConstantShow:CGFloat = 8
  static let CollectionViewBottomConstantHidden:CGFloat = -120
  static let GalleryCellTargetSize = CGSize(width: 100, height: 100)
  static let DisplayImageTargetSize = CGSize(width: 600, height: 600)
  static let UploadImageSize = CGSize(width: 600, height: 600)
  static let TwitterImageSize = CGSize(width: 600, height: 600)
  static let GalleryCellMinimumSize: CGFloat = 45
  static let GalleryCellMaximumSize: CGFloat = 300
}
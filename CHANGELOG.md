## 10.0.1

* Fix issue that Scale the image to align with the crop rect only when scaleDelta is small.(#738)
* Change the color from dialogBackgroundColor to scaffoldBackgroundColor for defaultSlidePageBackgroundHandler.

## 10.0.0

* Add WebHtmlElementStrategy for ExtendedNetworkImageProvider on Web
* Migrate to 3.29.0 
  
## 9.1.0

* Removed the `enableMemoryCache` variable in `ExtendedImage`,please Use `clearMemoryCacheWhenDispose` instead for managing memory cache behavior. 
* Scale the image to align with the crop rect and make crop rect as bigger as possible when rotate Image on Editor mode.(#713)

## 9.0.9

* Fix drag crop rect can't zoom in the image(#723)

## 9.0.8

* Fix the issue with 90-degree judgment when rotate image.
* Fix SetState will Reset ExtendedImage and clear the Crop State. (#712)

## 9.0.7

* Fix crop rect transform not invert
* Support editor config history
* Add updateConfig and get config from editor controller

## 9.0.6

* Fix issue about worng scale for crop rect when scale is more than max scale

## 9.0.5

* Fix issue about worng scale for crop rect when scale is more than max scale

## 9.0.4

* Public [ImageEditorController.currentIndex],[ImageEditorController.history],[ImageEditorController.saveCurrentState]
* Scale the crop rect if the image can't be scaled(max scale) when rotate the image.

## 9.0.3

* Breaking change: update the term 'angle' to 'degree'.

## 9.0.2

* Update eidtor crop rect when srceen size is changed.

## 9.0.1

* Take care about web platform, update eidtor layer size when srceen size is changed.
* Make the list can be scrolled on web platform.

## 9.0.0

* Feature:
  1. support to change free angle rotation on editor mode.
  2. support to control whether the cropping box follows rotation on editor mode.
  3. support flip and rotate animation on editor mode.
  4. support undo and redo on editor mode.
  5. support update cropAspectRatio without reset state on editor mode.
  6. add [ImageEditorController] for [EditorConfig] to control the editor state.
  
* Issues:
  1. Fix issue about free angle rotation. (#702, #627, #78, #441)
  2. Fix issue about control whether the cropping box also rotate follows the rotation. (#691, #277)
  3. Fix issue about flip animation. (#397)
  4. Fix issue about crop rect gets invalid randomly on zooming in and out. (#548) 
  5. Fix issue about undo and redo. (#553)

* Breaking change:
  1. EditorCropLayerPainter.paintMask method the [Size] argument to [Rect].
  2. Remove flipX support.
  3. Change the cropping process, now they are rotate, flipY and getCropRect.


## 8.3.1

* Fix issue that unsmooth zooming when using ExtendedImageGesturePageView (#631)
* Add [ExtendedImageGesturePageView.shouldAccpetHorizontalOrVerticalDrag] to custum whether should accpet horizontal or vertical drag at that time.

## 8.3.0

* Add [imageGestureState] parameter for ImageBuilderForGesture call back, add [wrapGestureWidget] method for [ExtendedImageGestureState] and add [GestureWidgetDelegate]. All of them are using to build a custom gesture widget when the image is in ExtendedImageMode.gesture mode.

* Add Live Photo Demo to show how to use the new feature.

## 8.2.4

* Fix issue that pageSpacing not work as expected after flutter 3.22.0 (#692)

## 8.2.3

* fix _DragGestureRecognizer build error after https://github.com/flutter/flutter/pull/151627

## 8.2.2

* Fix issue that pageSpacing not work as expected after flutter 3.22.0 (#692)

## 8.2.1

* dart fix

## 8.2.0

* Migrate to 3.16.0 

## 8.1.1

* Fix issue with onDragEnd

## 8.1.0

* Migrate to 3.13.0 
* Breaking change: remove preloadPagesCount of ExtendedImageGesturePageView. The cacheExtent of Viewport should be 0. 
* Add demo to instead of preloadPagesCount of ExtendedImageGesturePageView


## 8.0.2

* [EditorCropLayerPainter.paintMask] not use BlendMode.clear now, due to '--web-renderer html' is not support.

## 8.0.1

* Dart sdk: '>=2.18.0 <4.0.0'

## 8.0.0

* Migrate to Flutter 3.10.0 and Dart 3.0.0 (#557,#563,#570,#572,#573)
* Cherry Pick https://github.com/flutter/flutter/pull/110131
* Cherry Pick https://github.com/flutter/flutter/pull/119495

## 7.0.2

* publish v6.4.1 for flutter 3.3.0 and v6.2.2 for flutter 3.0.5

## 7.0.1

* update judging condition of delta(minGesturePageDelta) at it's sliding page when set ExtendedImageMode.gesture

## 7.0.0

* Migrate to 3.7.0 (#545)

## 6.4.1

* latest code on Flutter 3.3.0 

## 6.4.0

* add [ExtendedImage.globalStateWidgetBuilder] to support to override State Widget if loadStateChanged is not define.(#541)

## 6.3.4

* add preloadPagesCount for ExtendedImageGesturePageView

## 6.3.3

* draw editor with BlendMode.clear.

## 6.3.2

* support to set insets for paint image at the beginning.(#417)
* merge code from official (#515)
  
## 6.3.1

* fix issue that rebuild viewportDimension is not right when pageSpacing is not zero(ExtendedImageGesturePageView #516)

## 6.3.0

* Migrate to 3.3.0

## 6.2.2

* latest code on Flutter 3.0.5 

## 6.2.1

* Add DeviceGestureSettings for ExtendedVerticalDragGestureRecognizer and ExtendedHorizontalDragGestureRecognizer.(#482,#483)

## 6.2.0

* Migrate to 3.0.0

## 6.1.0

* override == and hashCode for ExtendedResizeImage
* fix issue that ExtendedResizeImage can't get rawImageData(#477)
* ExtendedResizeImage.maxBytes is actual bytes of Image, not decode bytes.
* fix issue that max scale look bigger after zoom in and zoom out (#476)

## 6.0.3

* Improve:
  add [EditorConfig.initialCropAspectRatio] to support to set initial CropAspectRatio(#462 It's good for that you can set initial CropAspectRatio at first time and set CropAspectRatio to custom, so that the users can change CropAspectRatio as they want). 


## 6.0.2+1

* Issues:
  1. Hide `FileImage` from `extended_image_library` explicitly.

## 6.0.2

* Issues:
  1. Remove the deprecated constructor for the `ExtendedVelocityTracker`. (#460)
  2. Hide `File` from `extended_image_library` explicitly.

## 6.0.1

* Issues:
  Fix VelocityTracker is not type ExtendedVelocityTracker

## 6.0.0

* Breaking change:
  Migrate to 2.8

## 5.1.3

* Issues:
  1. fix issue that solve gesture conflict between MovePage and vertical pan.

## 5.1.2

* Issues:
  1. fix issue that mouse wheel/double tap are not working.(#404)

## 5.1.1

* Bumping flutter sdk minimum version to 2.5.0
## 5.1.0

* Improve:
  add [ExtendedPageController.shouldIgnorePointerWhenScrolling] to solve issue that we can's zoom image before [PageView] stop scroll in two way.  

## 5.0.0

* Improve:
  1. solve gesture conflict between Scale and Horizontal/Vertical drag.
  2. support to set page spacing. [ExtendedPageController.pageSpacing]
  3. add [ExtendedImage.opacity].
  4. fix that we can't zoom image before [PageView] stop scroll.

* Breaking change:
  1. use [ExtendedPageController] instead of [PageController].
  2. use [ExtendedImageGesturePageView.canScrollPage] instead of [ExtendedImageGesturePageView.canMovePage].

## 4.2.1

* Improve:
  1. fix description of reverseMousePointerScrollDirection

## 4.2.0

* Issues:
  1. fix issue that inverse zoom by mouse wheel.(#382)
  2. fix issue that crop_layer with/height is negative

## 4.1.0

* Improve:
  1. add [ExtendedImage.network.cacheMaxAge] to set max age to be cached.
  2. update demo about hero, make it better when slide out.

## 4.0.1

* Issues:
  1. fix issue that we should end method with a call to super.dispose().(#329).

## 4.0.0

* Breaking change:

  1. we cache raw image pixels as default behavior at previous versions, it's not good for heap memory usage. so add [ExtendedImageProvider.cacheRawData] to support whether should cache the raw image pixels. It's [false] now.

* Improve:

  1. add [ExtendedResizeImage] to support resize image more convenient.
  2. add [ExtendedImageProvider.imageCacheName] to support custom ImageCache to store ExtendedImageProvider.
  3. add MemoryUsageDemo. #315

* Issues:
  1. fix issue that [EditorConfig.editActionDetailsIsChanged] is not fire when change crop area. #317

## 3.0.0

* Improve:

  1. support null-safety
  2. add [ExtendedNetworkImageProvider.printError]
  3. merge code from Flutter 2.0

* Breaking change:

  1. remove [TransparentMaterialPageRoute] and [TransparentMaterialPageRoute]

## 2.0.0

* Improve:
  1. add cacheKey for NetworkProvider. #288
  2. web capability at pub.dev.
  3. add change event for editor. #300

* Breaking change:
  1. Use [EditorCropLayerPainter] instead of [ExtendedImageCropLayerCornerPainter]

## 1.6.0

* Improve:

  1. public ExtendedImageSlidePageHandler for slide other widget. #298

## 1.5.0

* Improve:

  1. public handleLoadingProgress for default constructor of ExtendedImage. #274

## 1.4.0

* Improve:

  1. add hitTestBehavior for GestureConfig and EditorConfig. #271

## 1.3.0

* Features:
  1. support zoom with mouse wheel.

## 1.2.0

* Features:
  1. add posibility to draw custom crop layout corners
  2. add corner shape(ExtendedImageCropLayerPainterCircleCorner())

## 1.1.2

* Issues:
  1. fix issue that flickering when zooming out(#235).

## 1.1.1

* Issues:
  1. fix issue that slide offset is not right.

## 1.1.0

* Features:
  1. add cacheHeight and cacheWidth params for all constructors.
  2. add isAntiAlias parameter.
  3. add GestureDetailsIsChanged call back for GestureConfig(#214).

* Improve:
  1. more demo.

## 1.0.0

* Improve:

  1. merge from Defer image decoding when scrolling fast(https://github.com/flutter/flutter/pull/49389).

  2. flutter sdk minimum version limit to 1.17.0.


## 0.9.0

* Features:
  1. add cacheHeight and cacheWidth params for ExtendedImage.network.
  2. add Key extendedImageGestureKey for ExtendedImageGesture.

## 0.8.0

* Features:
  1. add call back CanScrollPage for ExtendedImageGesturePageView.

## 0.7.4

* Issues:
  1. fix ScrollPhysics is not working for ExtendedImageGesturePageView

## 0.7.3+1

* Improve:
  1. remove docs from master branch and release web at github_page branch.

## 0.7.3

* Improve:
  1. fix build error on high flutter sdk(> 1.6.0)
  2. fix analysiz_options

## 0.7.2

* Features:
  1. support loading progress for network
  2. public HttpClient of ExtendedNetworkImageProvider
  3. public ExtendedImageGestureState for SlideOffsetHandler/SlideEndHandler/            SlideScaleHandler to get scale of image

## 0.7.1

* Improve:
  1. scale parameter of method(handleDoubleTap) is support animationMinScale and animationMaxScale now.

## 0.7.0

* Features:
  1. support web.
  2. add [clearMemoryCacheWhenDispose] parameter that whether clear memory cache when image is disposed.

* Issues:
  1. fix animationMinScale and animationMaxScale are not working for gif.
  2. fix scale parameter of method(handleDoubleTap) is beyond minScale and maxScale.

## 0.6.9

* Features:
  1. support customize offset when slide page.

## 0.6.8

* Issues:
  1. fix breaking change for flutter 1.10.15 about miss load parameter.

## 0.6.7

* Issues:
  1. fix issue that ExtendedImageGesturePageView didn't work well when set initial alignment.

## 0.6.6

* Features:
  1. support init image with alignment when initialScale >1.0.
* Issues:
  1. fix issue that scrollDirection didn't work when set it dynamically(ExtendedImageGesturePageView ).
* Improve:
  1. add WaterfallFlow demo.

## 0.6.5

* Features:
  1. add completedWidget for ExtendedImageState, it is include gesture or editor, so that you would't miss them
* Improve:
  2. improve documents about Load State

## 0.6.4

* Issues:
  1. fix issue that rawImageData can't be cached for ExtendedExactAssetImageProvider/ExtendedAssetImageProvider.
* Improve:
  1. add demo about ImageEditor with native library, it's faster.

## 0.6.3

* Issues:
  1. fix issue that forget canvas.restore after canvas.clipRect
* Breaking Change:
  2. ImageEditor：you should crop image data before flip or rotate image data now.
* Improve:
  3. increase cropping speed

## 0.6.2

* Features:
  1. add InitCropRectType(imageRect,layoutRect) for EditorConfig to define init crop rect base on initial image rect or image layout rect.
* Breaking Change:
  1. make sure the image is all painted to crop,the fit of image must be BoxFit.contain.

## 0.6.1

* Issues:
  1. fix issue about drag slowly in ImageEditor

## 0.6.0

* Issues:
  1. fix issue about strange behaviour at slide out page

## 0.5.9

* Issues:
  1. add HeroBuilderForSlidingPage call back to fix strange hero animation

## 0.5.8

* Features:
  1. support to crop,rotate,flip image

## 0.5.6

* Improve:
  1. add key for ExtendedImageSlidePage

## 0.5.5

* Features:
  1. add call back CanMovePage for ExtendedImageGesturePageView. related issue. #32

## 0.5.4

* Issues:
  1. fix issue about borderRadius and border
  2. fix demo error about extended_text

## 0.5.3

* Improve:
  1. merge codes base on v1.7.8

## 0.5.1

* Features:
  1. add call back onSlidingPage when is sliding page, you can change other widgets state in page.ExtendedImageSlidePage
  2. add enableSlideOutPage parameter to define whether enable slide out page. ExtendedImage

## 0.4.3

* Breaking Change:
  1. parameter gestureConfig is obsolete. initGestureConfigHandler is used to setting GestureConfig now.

* Issues:
  1. fix issue about slide page.

* Features:
  1. support to slide page at loading/failed state

## 0.4.2

* Improve:
  1. add README-ZH.md

## 0.4.1

* Improve:
  1. add SlideType to support slide only image or whole pageExtendedImageSlidePage

## 0.4.0

* Features:
  1. support to slide out page

## 0.3.8

* Improve:
  1. update path_provider 1.1.0

## 0.3.6

* Improve:
  1. handle load failed when re-addListener

## 0.3.4

* Features:
  1. add physics parameter for ExtendedImageGesturePageView

## 0.3.3

* Improve:
  1. disabled informationCollector to keep backwards compatibility for now (ExtendedNetworkImageProvider)

## 0.3.2

* Improve:
  1. import extended_image_library for network cache

## 0.3.1
* Issues:
  1. fix issue that AnimationController.stop() called after AnimationController.dispose().
* Improve:
  1. show how to build a double tap scale animation.

## 0.2.9

* Improve:
  1. add handleDoubleTap method to support zoom image base on double tap position.

## 0.2.8

* Improve:
  1. add inertia scroll when image is zoom in and it's moving page.

## 0.2.7

* Issues:
  1. fix issue that wrong behavior of page view scroll when image has big width or big height.

## 0.2.6

* Issues:
  1. fix issue that wrong behavior of page view scroll when image is zoom in.

## 0.2.5

* Improve:
  1. add onDoubleTap parameter to custom double tap behavior under ExtendedImageMode.Gesture

## 0.2.3

* Features:
  1. add enableMemoryCache parameter, whether cache in PaintingBinding.instance.imageCache
  2. add clearMemoryCacheIfFailed parameter, when failed to load image, whether clear memory cache,if true, image will reload in next time.
* Breaking Change:
  1. auto cancel network request is obsolete.

## 0.2.2

* Improve:
  1. update path_provider version from 0.4.1 to 0.5.0+1

## 0.2.1

* Features:
  1. add cancelToken,retries,timeLimit and timeRetry parameters for ExtendedImage.network method
  2. add default cancelToken for ExtendedImage.network method
* Issues:
  1. fix issue about cancel network image request
  2. fix gesture page view scrolls not smooth

## 0.2.0

* Features:
  1. support zoom/pan image and view image in page view like wechat(support zoom in and scroll next or previous image)

## 0.1.8

* Breaking Change:
  1. remove image_picker_saver from extended_image.
  obsolete saveNetworkImageToPhoto method(if you want to save photo,you can import image_picker_saver and get data from getNetworkImageData method)

## 0.1.7

* Improve:
  1. public instantiateImageCodec method so that you can handle image data by override this in ExtendedNetworkImageProvider

## 0.1.6

* Improve:
  1. add getNetworkImageData method

## 0.1.5

* Improve:
  1. change toMd5 to keyToMd5

## 0.1.4

* Improve:
  1. public imageProvider for ExtendedImageState

## 0.1.3
* First Release:
  1. Release ExtendedImage.

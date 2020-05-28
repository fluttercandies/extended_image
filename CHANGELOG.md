## [0.9.0]

* Features:
  Add cacheHeight and cacheWidth params for ExtendedImage.network. 
  Add Key extendedImageGestureKey for ExtendedImageGesture.

## [0.8.0]

* Features:
  Add call back [CanScrollPage] for ExtendedImageGesturePageView. 

## [0.7.4]

* Issues:
  Fix ScrollPhysics is not working for ExtendedImageGesturePageView
  
## [0.7.3+1]

* remove docs.

## [0.7.3]

* Improve:
  fix build error on high flutter sdk(> 1.6.0)
  fix analysiz_options

## [0.7.2]

* Features:
  support loading progress for network
  public HttpClient of ExtendedNetworkImageProvider
  public ExtendedImageGestureState for SlideOffsetHandler/SlideEndHandler/SlideScaleHandler to get scale of image
  
## [0.7.1]

* Improve:
  scale parameter of method(handleDoubleTap) is support animationMinScale and animationMaxScale now.  

## [0.7.0]

* Features:
  Support web.
  Add clearMemoryCacheWhenDispose parameter that whether clear memory cache when image is disposed.
* Issues:
  Fix animationMinScale and animationMaxScale are not working for gif.  
  Fix scale parameter of method(handleDoubleTap) is beyond minScale and maxScale.

## [0.6.9]

* Features:
  Support customize offset when slide page.

## [0.6.8]

* Issues:
  Fix breaking change for flutter 1.10.15 about miss load parameter.

## [0.6.7]

* Issues:
  Fix issue that ExtendedImageGesturePageView didn't work well when set initial alignment.

## [0.6.6]

* Features:
  Support init image with alignment when initialScale >1.0.
* Issues:
  Fix issue that scrollDirection didn't work when set it dynamically(ExtendedImageGesturePageView ).
* Improve:
  Add WaterfallFlow demo.

## [0.6.5]

* Features:
  Add completedWidget for ExtendedImageState, it is include gesture or editor, so that you would't miss them
* Improve:
  Improve documents about Load State 

## [0.6.4]

* Issues:
  Fix issue that rawImageData can't be cached for ExtendedExactAssetImageProvider/ExtendedAssetImageProvider.
* Improve:
  Add demo about ImageEditor with native library, it's faster. 

## [0.6.3]

* Issues:
  Fix issue that forget canvas.restore after canvas.clipRect
* Breaking Change:
  ImageEditor：you should crop image data before flip or rotate image data now.
* Improve:
  Increase cropping speed

## [0.6.2]

* Features:
  Add InitCropRectType(imageRect,layoutRect) for EditorConfig to define init crop rect base on initial image rect or image layout rect.
* Breaking Change:
  Make sure the image is all painted to crop,the fit of image must be BoxFit.contain.
    
## [0.6.1]

* Issues:
  Fix issue about drag slowly in ImageEditor

## [0.6.0]

* Issues:
  Fix issue about strange behaviour at slide out page
  
## [0.5.9]

* Add HeroBuilderForSlidingPage call back to fix strange hero animation
  
## [0.5.8]

* Features:
  Support to crop,rotate,flip image
  
## [0.5.6]

* Add key for ExtendedImageSlidePage

## [0.5.5]

* Features:
  Add call back [CanMovePage] for ExtendedImageGesturePageView. [related issue](https://github.com/fluttercandies/extended_image/issues/32) 
  
## [0.5.4]

* Issues:
  Fix issue about borderRadius and border
  Fix demo error about extended_text 

## [0.5.3]

* Improve codes base on v1.7.8

## [0.5.1]

* Features:
  Add call back [onSlidingPage] when is sliding page, you can change other widgets state in page.[ExtendedImageSlidePage]
* Add [enableSlideOutPage] parameter to define whether enable slide out page. [ExtendedImage]  

## [0.4.3]

* Breaking Change:
  Parameter [gestureConfig] is obsolete. [initGestureConfigHandler] is used to setting GestureConfig now.

* Issues:
  Fix issue about slide page.
  
* Features: 
  Support to slide page at loading/failed state

## [0.4.2]

* add README-ZH.md
  
## [0.4.1]

* add SlideType to support slide only image or whole page[ExtendedImageSlidePage]

## [0.4.0]

* support to slide out page

## [0.3.8]

* update path_provider 1.1.0

## [0.3.6]

* handle load failed when re-addListener

## [0.3.4]

* add physics parameter for ExtendedImageGesturePageView

## [0.3.3]

* disabled informationCollector to keep backwards compatibility for now (ExtendedNetworkImageProvider)

## [0.3.2]

* import extended_image_library for network cache

## [0.3.1]

* fix issue that AnimationController.stop() called after AnimationController.dispose().
* show how to build a double tap scale animation.

## [0.2.9]

* add handleDoubleTap method to support zoom image base on double tap position.

## [0.2.8]

* add inertia scroll when image is zoom in and it's moving page.

## [0.2.7]

* fix issue that wrong behavior of page view scroll when image has big width or big height.

## [0.2.6]

* fix issue that wrong behavior of page view scroll when image is zoom in.

## [0.2.5]

* add onDoubleTap parameter to custom double tap behavior under ExtendedImageMode.Gesture

## [0.2.3]

* add enableMemoryCache parameter, whether cache in PaintingBinding.instance.imageCache
* add clearMemoryCacheIfFailed parameter, when failed to load image, whether clear memory cache,if true, image will reload in next time.
* auto cancel network request is obsolete.

## [0.2.2]

* update path_provider version from 0.4.1 to 0.5.0+1

## [0.2.1]

* add cancelToken,retries,timeLimit and timeRetry parameters for ExtendedImage.network method
* add default cancelToken for ExtendedImage.network method
* fix issue about cancel network image request
* fix gesture page view scrolls not smooth

## [0.2.0]

* support zoom/pan image and view image in page view like wechat(support zoom in and scroll next or previous image)

## [0.1.8]

* remove image_picker_saver from extended_image.
  obsolete saveNetworkImageToPhoto method(if you want to save photo,you can import image_picker_saver and get data from getNetworkImageData method)

## [0.1.7]

* public instantiateImageCodec method so that you can handle image data by override this in ExtendedNetworkImageProvider

## [0.1.6]

* add getNetworkImageData method

## [0.1.5]

* change toMd5 to keyToMd5

## [0.1.4]

* public imageProvider for ExtendedImageState

## [0.1.3]

* add extended image.

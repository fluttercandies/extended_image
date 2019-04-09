## [0.2.1]

* add cancelToken,retries,timeLimit and timeRetry parameters for ExtendedImage.network method
* add default cancelToken for ExtendedImage.network method
* fix issue about cancel network image request

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

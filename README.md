# PhotosAssessment

## Tech Stack:
- iOS: 13
- Architecture: MVP
- UI: programmatic

## TODO:
- Write Unit Tests
- Make full usage of PHImageRequestOptionsDeliveryMode.opportunistic to improve responsiveness and balance image quality (Photos may call your result handler once to provide a low-quality image suitable for displaying temporarily while it prepares a high-quality image.)
- Redraw saliency rectangle depending on a visible part of the image when change imageView.contentMode or rotate a device (use VNImageBasedRequest regionOfInterest property)



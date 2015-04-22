/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "UIImageExtras.h"




@implementation UIImage (OpenFlowExtras)

- (UIImage *)rescaleImageToSize:(CGSize)size {
	CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	[self drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

- (UIImage *)cropImageToRect:(CGRect)cropRect {
	// Begin the drawing (again)
	UIGraphicsBeginImageContext(cropRect.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
	CGContextTranslateCTM(ctx, 0.0, cropRect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	// Draw view into context
	CGRect drawRect = CGRectMake(-cropRect.origin.x, cropRect.origin.y - (self.size.height - cropRect.size.height) , self.size.width, self.size.height);
	CGContextDrawImage(ctx, drawRect, self.CGImage);
	
	// Create the new UIImage from the context
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the drawing
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox {
	// Make the shortest side be equivalent to the cropping box.
	CGFloat newHeight, newWidth;
	if (self.size.width < self.size.height) {
		newWidth = croppingBox.width;
		newHeight = (self.size.height / self.size.width) * croppingBox.width;
	} else {
		newHeight = croppingBox.height;
		newWidth = (self.size.width / self.size.height) *croppingBox.height;
	}
	return CGSizeMake(newWidth, newHeight);
}

-(CGSize)calculateNewSizeWithoutBlank:(CGSize)destSize
{
    CGSize oriSize=self.size;
    CGSize resultSize;
    if(oriSize.width==0||oriSize.height==0||destSize.width==0||destSize.height==0)
    {
        resultSize=CGSizeMake(0, 0);
    }
    else
    {
        if(oriSize.width/oriSize.height<=destSize.width/destSize.height)
        {
            resultSize.width=oriSize.width;
            resultSize.height=(resultSize.width/destSize.width)*destSize.height;
        }
        else
        {
            resultSize.height=oriSize.height;
            resultSize.width=(resultSize.height/destSize.height)*destSize.width;
        }
    }
    
    return resultSize;
}

-(UIImage*)cropCenterAndScaleImageToSizeWithoutBlank:(CGSize)destSize
{
    CGSize resultSize=[self calculateNewSizeWithoutBlank:destSize];
    CGRect resultRect;
    if(resultSize.width<=self.size.width)
    {
        resultRect.origin.x=(self.size.width-resultSize.width)*0.5;
        resultRect.origin.y=0;
        resultRect.size=resultSize;
    }
    else
    {
        resultRect.origin.x=0;
        resultRect.origin.y=(self.size.height-resultSize.height)*0.3;//略偏上
        resultRect.size=resultSize;
    }
    UIImage* cropedImage=[self cropImageToRect:resultRect];
    return [cropedImage rescaleImageToSize:destSize];
}

//- (CGSize)calculateNewSizeForCroppingBox:(CGSize)croppingBox {
//	// Make the shortest side be equivalent to the cropping box.
//	CGFloat newHeight, newWidth;
//	if (self.size.width < self.size.height) {
//        if (croppingBox.width<self.size.width) {
//            newWidth = croppingBox.width;
//        }else
//        {
//            newWidth = self.size.width;
//        }
//        
//        newHeight = (self.size.width / croppingBox.width) * self.size.height;
//        
//    } else {
//        
//        if (croppingBox.height<self.size.height) {
//            newHeight = croppingBox.height;
//        }else
//        {
//            newHeight = self.size.height;
//        }
//		
//		newWidth = (self.size.height / croppingBox.height) *self.size.width;
//	}
//	
//	return CGSizeMake(newWidth, newHeight);
//}

- (UIImage *)cropCenterAndScaleImageToSize:(CGSize)cropSize {
	UIImage *scaledImage = [self rescaleImageToSize:[self calculateNewSizeForCroppingBox:cropSize]];
	return [scaledImage cropImageToRect:CGRectMake((scaledImage.size.width-cropSize.width)/2, (scaledImage.size.height-cropSize.height)/2, cropSize.width, cropSize.height)];
}


- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode
{
    CGSize imgSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    CGSize outputSize = imgSize;
    if (cropMode == enSvCropExpand) {
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radian));
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radian);
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
#import <IOMobileFrameBuffer.h>
#import <QuartzCore/QuartzCore.h>
//#import <IOKit/IOKit.h>
#import <IOSurface/IOSurface.h>
#import <IOSurface/IOSurfaceAccelerator.h>

extern "C" IOReturn IOSurfaceLock(IOSurfaceRef buffer, uint32_t options, uint32_t *seed);
extern "C" IOReturn IOSurfaceUnlock(IOSurfaceRef buffer, uint32_t options, uint32_t *seed);
extern "C" size_t IOSurfaceGetWidth(IOSurfaceRef buffer);
extern "C" size_t IOSurfaceGetHeight(IOSurfaceRef buffer);
extern "C" IOSurfaceRef IOSurfaceCreate(CFDictionaryRef properties);
extern "C" void *IOSurfaceGetBaseAddress(IOSurfaceRef buffer);
extern "C" size_t IOSurfaceGetBytesPerRow(IOSurfaceRef buffer);
extern "C" UIImage *_UICreateScreenUIImage();

extern const CFStringRef kIOSurfaceAllocSize;
extern const CFStringRef kIOSurfaceWidth;
extern const CFStringRef kIOSurfaceHeight;
extern const CFStringRef kIOSurfaceIsGlobal;
extern const CFStringRef kIOSurfaceBytesPerRow;
extern const CFStringRef kIOSurfaceBytesPerElement;
extern const CFStringRef kIOSurfacePixelFormat;

#define RecordScript_PREFERENCE @"/var/mobile/Library/Preferences/com.BlockTest.RecordScript.plist"

/*以下是脚本规则*/
#define TouchUp    0
#define TouchDown  1
#define ScreenShot 2


int imageIndex = 0;
extern "C" CGImageRef UIGetScreenImage();

typedef void (^CDUnknownBlockType)(void); 

@interface SpringBoard: NSObject
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
+ (id)sharedApplication;
 - (id)screenshotManager;
@end
@interface SBScreenshotManager: NSObject
- (void)saveScreenshotsWithCompletion:(id)sender;
- (void)saveScreenshots;
@end

%hook UIWindow

- (void)sendEvent:(UIEvent *)event
{
  
    %orig;

    
    if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"])
    {
    //打开脚本文件，寻找文件末尾，根据事件生成脚本

    NSString *appId = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleIdentifier"];
    //NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleDisplayName"];
    NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
    NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
        NSLog(@"pathOfScript is %@",pathOfScript);
    //创建一个文件操作符
    NSFileHandle *outfile;
    outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
    //将文件偏移量置于文件末尾用于写入脚本
    [outfile seekToEndOfFile];
    NSArray *toucharra =[[event allTouches] allObjects];
    //捕获窗口的每一个点击操作
    for (UITouch *touch in toucharra){
    NSLog(@"touch = %@",touch);
    NSLog(@"touch view = %@",touch.view);
    NSString *viewName;
    NSString *viewFrame;
    NSString *superviewName;
    if(touch.view !=nil)
    {
      NSString *viewStr = [NSString stringWithFormat:@"%@",touch.view];
      viewName = [[viewStr substringFromIndex:[viewStr rangeOfString:@"<"].location + 1]substringToIndex:[viewStr rangeOfString:@":"].location - 1];
      NSString *frame_tmp = [viewStr substringFromIndex:[viewStr rangeOfString:@"("].location ];
      viewFrame = [frame_tmp substringToIndex:[frame_tmp rangeOfString:@");"].location + 1];
      NSString *superviewStr = [NSString stringWithFormat:@"%@",touch.view.superview];
      superviewName = [[superviewStr substringFromIndex:[superviewStr rangeOfString:@"<"].location + 1]substringToIndex:[superviewStr rangeOfString:@":"].location - 1];
    }
    else
    {
      viewName = @"fff";
      viewFrame = @"fff";
      superviewName = @"fff";
    }
    NSLog(@"touch! viewName is %@",viewName);
    NSLog(@"touch! viewFrame is %@",viewFrame);
    NSLog(@"touch! superviewName is %@",superviewName);
//    NSLog(@"touch view ID = %@",viewID);
    NSLog(@"touch location in view = %@",NSStringFromCGPoint([touch locationInView:touch.view]));
    switch (touch.phase)
    {
        case UITouchPhaseBegan:
        {
            NSString *str = [[NSString alloc]initWithFormat:@"%d %f %f %lf %@ %@ %@ %f %f\n",TouchDown,[touch locationInView:touch.window].x,[touch locationInView:touch.window].y,[[NSDate date] timeIntervalSince1970],viewName,superviewName,viewFrame,[touch locationInView:touch.view].x,[touch locationInView:touch.view].y];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
           
            [outfile writeData:data];
           
            break;
        }
        case UITouchPhaseMoved:
        {
            NSString *str = [[NSString alloc]initWithFormat:@"%d %f %f %lf %@ %@ %@ %f %f\n",TouchDown,[touch locationInView:touch.window].x,[touch locationInView:touch.window].y,[[NSDate date] timeIntervalSince1970],viewName,superviewName,viewFrame,[touch locationInView:touch.view].x,[touch locationInView:touch.view].y];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

        
            [outfile writeData:data];
           
         
            break;
        }
        case UITouchPhaseEnded:
        {
           
            NSString *str = [[NSString alloc]initWithFormat:@"%d %f %f %lf %@ %@ %@ %f %f\n",TouchUp,[touch locationInView:touch.window].x,[touch locationInView:touch.window].y,[[NSDate date] timeIntervalSince1970],viewName,superviewName,viewFrame,[touch locationInView:touch.view].x,[touch locationInView:touch.view].y];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            
           [outfile writeData:data];
           
            
            break;
}
        case UITouchPhaseCancelled:{

            NSString *str = [[NSString alloc]initWithFormat:@"%d %f %f %lf %@ %@ %@ %f %f\n",TouchUp,[touch locationInView:touch.window].x,[touch locationInView:touch.window].y,[[NSDate date] timeIntervalSince1970],viewName,superviewName,viewFrame,[touch locationInView:touch.view].x,[touch locationInView:touch.view].y];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            
            [outfile writeData:data];
            
            
            break;
        }
    }
    }
     NSLog(@"关闭文件流");
     [outfile closeFile];

//提取当前界面控件的代码
     NSString *widgetSet = [[[UIApplication sharedApplication]keyWindow]performSelector:@selector(recursiveDescription)];
    // NSLog(@"widgetSet  is %@",widgetSet);
     NSArray *UIArray_temp1 = [widgetSet componentsSeparatedByString:@"\n"];
    int  count=[UIArray_temp1 count];
     NSLog(@"count = %d",count);
     NSMutableArray *UIArray = [NSMutableArray arrayWithCapacity:5];
     int count_temp = 0;
     while(count_temp < count -1 )
     {
	[UIArray addObject:[UIArray_temp1 objectAtIndex:count_temp]];
	NSLog(@"each UI:%@",UIArray_temp1[count_temp]);
	count_temp ++;
     }
/*     NSString *widgetID = @"0x13c56eb70";
     NSLog(@"widgetID start at %d",(int)[widgetSet rangeOfString:widgetID].location);
     NSString *tmp0 = [widgetSet substringFromIndex:[widgetSet rangeOfString:widgetID].location];
//     NSLog(@"widgetID  tmp0 is %@",tmp0);
     NSLog(@"widgetID_X start at %d",(int)[tmp0 rangeOfString:@"("].location);
     NSString *tmp1 = [tmp0 substringFromIndex:[tmp0 rangeOfString:@"("].location + 1];
     NSLog(@"widgetID  tmp1 is %@",tmp1);
     NSLog(@"widgetID_Y start at %d",(int)[tmp1 rangeOfString:@";"].location);
     NSString *tmp2 = [tmp1 substringToIndex:[tmp1 rangeOfString:@";"].location - 1];
     NSLog(@"widgetID  tmp2 is %@",tmp2);
     NSLog(@"widgetID in widgetSet is %@",widgetSet);
     float baseX = [tmp2 substringToIndex:[tmp2 rangeOfString:@" "].location - 1].floatValue;
     float baseY = [tmp2 substringFromIndex:[tmp2 rangeOfString:@" "].location + 1].floatValue;
     NSLog(@"widgetID  baseX = %f baseY = %f",baseX,baseY);*/

 }
}

%end




%hook SBScreenShotter

-(void)saveScreenshot:(BOOL)screenshot{

 //在脚本文件中记录一次截图操作
  
    	if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"]){
    	NSString *appId = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
       // NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleDisplayName"];

	NSLog(@"****** in SBScreenShotter *********");
    //写脚本
        NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
        NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
        NSLog(@"pathOfScript is %@",pathOfScript);
        //创建一个文件操作符
        NSFileHandle *outfile;
        outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
        //将文件偏移量置于文件末尾用于写入脚本
        [outfile seekToEndOfFile];

        NSString *str = [[NSString alloc]initWithFormat:@"%d %lf\n",ScreenShot,[[NSDate date] timeIntervalSince1970]];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [outfile writeData:data];
        [str release];
        [outfile closeFile];
        SBScreenshotManager *manager = [[%c(SpringBoard) sharedApplication] screenshotManager];             //获得SpringBoard实例以后，获得
    [manager saveScreenshotsWithCompletion:nil];        //调用截图方法
    
    //存图片
        
        NSString *imagePrefix = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
        NSString *imagefilename = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_orig%d.png",imagePrefix,imageIndex]];

        /* IOS7截图保存
        CGImageRef cgScreen = UIGetScreenImage();
        if (cgScreen) {
            
            UIImage *result = [UIImage imageWithCGImage:cgScreen];
            if (![UIImagePNGRepresentation(result) writeToFile:imageDesPath atomically:YES]) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"截图失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
            imageIndex++;
            CGImageRelease(cgScreen);
            
        }

*/

//iOS8截图保存 
/*
     UIGraphicsBeginImageContext(self.view.bounds.size);
         [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
         UIImage *snapShotImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();

         UIImage *image = snapShotImage;
*/


    IOMobileFramebufferConnection connect;
    kern_return_t result;
    CoreSurfaceBufferRef screenSurface = NULL;
    io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleH1CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleM2CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleCLCD"));

    result = IOMobileFramebufferOpen(framebufferService, mach_task_self(), 0, &connect);
    result = IOMobileFramebufferGetLayerDefaultSurface(connect, 0, &screenSurface);

    uint32_t aseed;
    IOSurfaceLock((IOSurfaceRef)screenSurface, 0x00000001, &aseed);
    size_t width = IOSurfaceGetWidth((IOSurfaceRef)screenSurface);

    size_t height = IOSurfaceGetHeight((IOSurfaceRef)screenSurface);
    CFMutableDictionaryRef dict;
    size_t pitch = width*4, size = width*height*4;

    int bPE=4;

    char pixelFormat[4] = {'A','R','G','B'};
    dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dict, kIOSurfaceIsGlobal, kCFBooleanTrue);
    CFDictionarySetValue(dict, kIOSurfaceBytesPerRow, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch));
    CFDictionarySetValue(dict, kIOSurfaceBytesPerElement, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bPE));
    CFDictionarySetValue(dict, kIOSurfaceWidth, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &width));
    CFDictionarySetValue(dict, kIOSurfaceHeight, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &height));
    CFDictionarySetValue(dict, kIOSurfacePixelFormat, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat));
    CFDictionarySetValue(dict, kIOSurfaceAllocSize, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &size));

    IOSurfaceRef destSurf = IOSurfaceCreate(dict);
    IOSurfaceAcceleratorRef outAcc;
    IOSurfaceAcceleratorCreate(NULL, 0, &outAcc);

    IOSurfaceAcceleratorTransferSurface(outAcc, (IOSurfaceRef)screenSurface, destSurf, dict, NULL);
    IOSurfaceUnlock((IOSurfaceRef)screenSurface, kIOSurfaceLockReadOnly, &aseed);
    CFRelease(outAcc);

    CGDataProviderRef provider =  CGDataProviderCreateWithData(NULL,  IOSurfaceGetBaseAddress(destSurf), (width * height * 4), NULL);

    CGImageRef cgImage = CGImageCreate(width, height, 8,8*4, IOSurfaceGetBytesPerRow(destSurf), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst |kCGBitmapByteOrder32Little, provider, NULL, YES, kCGRenderingIntentDefault);

    UIImage *image = [UIImage imageWithCGImage:cgImage];
        
    if (![UIImagePNGRepresentation(image) writeToFile:imagefilename atomically:YES]) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"截图失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }

    }
    else{
        NSLog(@"当前录制状态: %@",[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"]);
        %orig;
    }


}
%end

%hook SpringBoard

- (void)saveScreenshotsWithCompletion:(CDUnknownBlockType)arg1 {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"hook截屏1" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
	 if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"]){
        NSString *appId = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
       // NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleDisplayName"];

        NSLog(@"****** in SBScreenShotter *********");
    //写脚本
        NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
        NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
        NSLog(@"pathOfScript is %@",pathOfScript);
        //创建一个文件操作符
        NSFileHandle *outfile;
        outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
        //将文件偏移量置于文件末尾用于写入脚本
        [outfile seekToEndOfFile];

        NSString *str = [[NSString alloc]initWithFormat:@"%d %lf\n",ScreenShot,[[NSDate date] timeIntervalSince1970]];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [outfile writeData:data];
        [str release];
        [outfile closeFile];
        %orig;	
	}
}

- (void)saveScreenshots{
	 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"hook截屏0" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
         if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"]){
        NSString *appId = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
       // NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleDisplayName"];

        NSLog(@"****** in SBScreenShotter *********");
    //写脚本
        NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
        NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
        NSLog(@"pathOfScript is %@",pathOfScript);
        //创建一个文件操作符
        NSFileHandle *outfile;
        outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
        //将文件偏移量置于文件末尾用于写入脚本
        [outfile seekToEndOfFile];

        NSString *str = [[NSString alloc]initWithFormat:@"%d %lf\n",ScreenShot,[[NSDate date] timeIntervalSince1970]];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [outfile writeData:data];
        [str release];
        [outfile closeFile];
 	%orig;
        }
}

%end

%hook VolumeControl
-(void)decreaseVolume{
	NSLog(@"******** decrease Volume ******");
    if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"])
    {

        
        //获取分辨率信息，写入脚本文件
                NSString *appId = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
                NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
                NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
               //创建一个文件操作符
                NSFileHandle *outfile;
                outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
                //将文件偏移量置于文件末尾用于写入脚本
                [outfile seekToEndOfFile];

                 //获取分辨率信息，写入脚本文件
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                NSString *resolution = [NSString stringWithFormat:@"**********%.0f*%.0fend**********",screenBounds.size.width,screenBounds.size.height];
                NSData *data = [resolution dataUsingEncoding:NSUTF8StringEncoding];
            
                 NSLog(@"resolution = %@",resolution);


                [outfile writeData:data];
               // [resolution release];
                [outfile closeFile];



        //修改偏好文件//告诉系统处于测试状态
        NSDictionary *preference = [NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE];
     
        [preference setValue:@"NO" forKey:@"isRecording"];
  
        
        [preference writeToFile:RecordScript_PREFERENCE atomically:YES];
        NSLog(@"结束录制");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"录制结束" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    
    else{
    %orig;
    }

}


-(void)increaseVolume{
    
    NSLog(@"******** increase Volume ******");

    if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"WillRecord"] isEqual: @"YES"])
    {
        if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"NO"])
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"录制开始" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
             //获取分辨率信息，写入脚本文件
                NSString *appId = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"ImageNamePrefix"];
                NSString *DocumentPath = [[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"DocumentPath"];
                NSString *pathOfScript = [DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Script.txt",appId]];
               //创建一个文件操作符
                NSFileHandle *outfile;
                outfile = [NSFileHandle fileHandleForWritingAtPath:pathOfScript];
                //将文件偏移量置于文件末尾用于写入脚本
                [outfile seekToEndOfFile];

                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                NSString *resolution = [NSString stringWithFormat:@"**********%.0f*%.0f**********\n",screenBounds.size.width,screenBounds.size.height];
                NSLog(@"resolution = %@",resolution);

                NSData *data = [resolution dataUsingEncoding:NSUTF8StringEncoding];
            
                [outfile writeData:data];
                

                //修改偏好文件//告诉系统处于测试状态
                
                NSDictionary *preference = [NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE];
                
                [preference setValue:@"YES" forKey:@"isRecording"];
                [preference setValue:@"NO" forKey:@"WillRecord"];

        
                [preference writeToFile:RecordScript_PREFERENCE atomically:YES];
                NSLog(@"开始录制");

                //[resolution release];
                [outfile closeFile];

            }
    }
    else{
        %orig;
    }
    
}

%end

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    if([[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"WillRecord"] isEqual: @"YES"]||[[[NSDictionary dictionaryWithContentsOfFile:RecordScript_PREFERENCE] objectForKey:@"isRecording"] isEqual: @"YES"])
    {
        NSLog(@" -----  ------  弹出框隐藏------ -----");
    }
    else
    {
        %orig;
    }
 }
%end


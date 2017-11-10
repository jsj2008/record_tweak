@interface SBScreenShotter
-(void)saveScreenshot:(BOOL)screenshot;
@end

@interface SpringBoard: NSObject
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
+(id)sharedApplication;
-(id)screenshotManager;
@end

@interface SBScreenshotManager: NSObject
-(void)saveScreenshotsWithCompletion:(id)sender;
- (void)saveScreenshots;
@end


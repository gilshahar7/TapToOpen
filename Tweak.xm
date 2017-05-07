@interface NCNotificationShortLookViewController
-(id)_presentedLongLookViewController;
-(void)addGestureRecognizer:(id)arg1;
@property (assign, nonatomic) UIView *view;
@end

@interface NCNotificationListCell
-(void)_executeDefaultActionIfCompleted;
-(void)setExecutingDefaultAction:(BOOL)arg1;
-(void)setSupportsSwipeToDefaultAction:(BOOL)arg1 ;
-(BOOL)isActionButtonsFullyRevealed;
-(NCNotificationShortLookViewController *)contentViewController;

@end

@interface SBLockScreenManager
+(SBLockScreenManager *)sharedInstance;
-(BOOL)isUILocked;
@end

%hook NCNotificationListCell
CGFloat myThreshold = 0;
-(CGFloat)_defaultActionExecuteThreshold{return myThreshold;}
-(CGFloat)_defaultActionTriggerThreshold{return myThreshold;}
-(CGFloat)_defaultActionOvershootContentOffset{return 0;}
-(void)layoutSubviews{
	%orig;
	bool isLocked = [[%c(SBLockScreenManager) sharedInstance] isUILocked];
	if(isLocked == true){
		if(MSHookIvar<NSMutableArray *>([self contentViewController].view, "_gestureRecognizers") == nil)
		{
			UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dood:)];
			[[self contentViewController].view addGestureRecognizer:singleFingerTap];
			[self setSupportsSwipeToDefaultAction:false];
		}
	}
}
%new
-(void)dood:(UITapGestureRecognizer *)recognizer{
	bool isLocked = [[%c(SBLockScreenManager) sharedInstance] isUILocked];
	if((isLocked == true) && ([self isActionButtonsFullyRevealed] == false) && ([[self contentViewController] _presentedLongLookViewController] == nil))
	{		
		myThreshold = -1;
		[self setSupportsSwipeToDefaultAction:true];
		[self _executeDefaultActionIfCompleted];
		[self setSupportsSwipeToDefaultAction:false];
		myThreshold = 0;
	}
}
%end

@interface SPSearchResult : NSObject
@property (nonatomic,retain) NSString * fbr; 
-(void)setTitle:(NSString *)arg1 ;
-(void)setSearchResultDomain:(unsigned)arg1 ;
-(void)setUrl:(NSString *)arg1 ;
@end

@interface SPSearchResultSection
@property (nonatomic, retain) NSString *displayIdentifier;
@property (nonatomic) unsigned int domain;
- (void)addResults:(SPSearchResult *)arg1;
@end

@interface SPSearchAgent
- (id)queryString;
@end

@interface SPUISearchViewController
- (void)actionManager:(id)arg1 presentViewController:(id)arg2 completion:(id /* block */)arg3 modally:(BOOL)arg4;
- (id)_actionManager;
- (void)actionManager:(id)arg1 dismissViewController:(id)arg2 completion:(id /* block */)arg3 animated:(BOOL)arg4;
+(SPUISearchViewController *)sharedInstance;
@end

static UIReferenceLibraryViewController *controller = nil;

%hook SBIconController
- (_Bool)dismissSpotlightIfNecessary {
	if(controller) {
		[(SPUISearchViewController *)[%c(SPUISearchViewController) sharedInstance] actionManager:[(SPUISearchViewController *)[%c(SPUISearchViewController) sharedInstance] _actionManager] dismissViewController:controller completion:^{controller = nil;} animated:YES];
	}
	return %orig;
}
%end

%hook SPUISearchViewController
-(void)openURL:(NSURL *)arg1  {
	%log;

	HBLogDebug(@"path = %@", arg1.pathComponents);
	if([arg1.pathComponents[0] isEqualToString:@"twerk_define:"]) {
		HBLogDebug(@"inside with %@", arg1.pathComponents[1]);
		controller = [[UIReferenceLibraryViewController alloc] initWithTerm:arg1.pathComponents[1]];
		[self actionManager:[self _actionManager] presentViewController:controller completion:nil modally:YES];
	} else {
		%orig;
	}
}
%end

%hook SPUISearchModel 
- (void)addSections:(NSMutableArray *)arg1 {
	%log;
	SPSearchResultSection *firstSection = [arg1 objectAtIndex:0];
	if(firstSection.domain == 1) {
		if([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:[self queryString]]) {
			NSString *searchDefQuery = [NSString stringWithFormat:@"twerk_define://%@", [self queryString]];

			SPSearchResult *myOtherCustomThing = [[%c(SPSearchResult) alloc] init];
			[myOtherCustomThing setTitle:@"Search Dictionary"];
			[myOtherCustomThing setSearchResultDomain:1];
			[myOtherCustomThing setUrl:searchDefQuery];
			myOtherCustomThing.fbr = @"search_define"; 

			[firstSection addResults:myOtherCustomThing];
		}
	}
	
	%orig(arg1);
}
%end
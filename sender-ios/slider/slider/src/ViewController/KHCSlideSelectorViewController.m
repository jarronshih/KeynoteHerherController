//
//  KHCSlideSelectorViewController.m
//  slider
//
//  Created by Chuck Lin on 6/6/14.
//
//

#import "KHCSlideSelectorViewController.h"
#import "KHCSSPSlideshare.h"
#import "KHCSSPSpeakerDeck.h"
#import "KHCSlideItem.h"
#import "KHCSlideTableViewCell.h"
#import "KHCConfirmPageViewController.h"

@interface KHCSlideSelectorViewController ()
{
    UIActivityIndicatorView *_activityIndicatorView;
    NSString *cellIdentifier;
    NSArray *_slides;
    NSObject<KHCSlideItem> *selectedSlide;
}
@property (nonatomic, retain) UITableView *tableview;
@end

@implementation KHCSlideSelectorViewController

- (id)init
{
    self = [super init];
    if (self) {
        UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        [view setBackgroundColor:[UIColor whiteColor]];
        self.view = view;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //size helper
    CGSize size = self.view.frame.size;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.center = CGPointMake(size.width / 2.0, size.height / 2.0);
    [_activityIndicatorView startAnimating];
    [self.view addSubview:_activityIndicatorView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CGSize size = self.view.frame.size;

    NSLog(@"SSP name: %@", _sspName);
    NSLog(@"User name: %@", _userName);
    
    _slides = [[NSArray alloc] initWithObjects: nil];

    if ([_sspName isEqualToString: @"SlideShare"]) {
        _slides = [KHCSSPSlideshare getUserSlideList:self.userName];
    } else if ([_sspName isEqualToString:@"SpeakerDeck"]) {
        _slides = [KHCSSPSpeakerDeck getUserSlideList:self.userName];
    }

    NSLog(@"Print slide titles");
    for (NSObject<KHCSlideItem> *slide in _slides) {
        NSLog(@"Slide title: %@", slide.title);
    }
    NSLog(@"End printing");

    if ([_slides count] <= 0) {
        UILabel *noSlides = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 100)];
        [noSlides setText:@"No slides found"];
        noSlides.center = CGPointMake(size.width / 2.0, size.height / 2.0);
        [noSlides setTextAlignment:NSTextAlignmentCenter];
        [_activityIndicatorView removeFromSuperview];
        [self.view addSubview:noSlides];
    } else {
        cellIdentifier = @"slideCell";
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, size.width, size.height)];
        [_tableview registerClass:[KHCSlideTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [_tableview setDelegate:self];
        [_tableview setDataSource:self];
        [_activityIndicatorView removeFromSuperview];
        [self.view addSubview:_tableview];
    }
}

- (void) didClickAddSlide
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSlide" object:selectedSlide];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_slides count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHCSlideTableViewCell *cell = [_tableview dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    if (cell == nil) {
        cell = [[KHCSlideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    // Display slide info in the tablecell
    NSObject<KHCSlideItem> *slide = [_slides objectAtIndex:indexPath.row];

    [cell.titleLabel setText:slide.title];
    //    [cell.imageView setImage:[UIImage imageWitzzhData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[slide cover_url]]]]];
    [cell.pageNumLabel setText:[NSString stringWithFormat:@"Pages: %d", (slide.max_page-slide.min_page+1)]];
    return cell;
}

#pragma mark - TableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedSlide = [_slides objectAtIndex:indexPath.row];

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KHCConfirmPageViewController *confirmPage = (KHCConfirmPageViewController*) [storyBoard instantiateViewControllerWithIdentifier: @"KHCConfirmPage"];

    // must being set before we force load the view
    [confirmPage setSlide:selectedSlide];
    // force to load the view, so we can change the rightBarButton
    [confirmPage view];
    confirmPage.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(didClickAddSlide)];

    [self.navigationController pushViewController:confirmPage animated:YES];
}

@end
//
//  KHCSlideListViewController.h
//  slider
//
//  Created by Chuck Lin on 6/1/14.
//
//

#import <UIKit/UIKit.h>

@interface KHCSlideListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{
        IBOutlet UISearchBar *searchBar;
}

- (IBAction)addSlideClicked:(id)sender;
@end

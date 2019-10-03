#import "YearViewController.h"
#import "Ride-Swift.h"

@interface YearViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *>* years;

@end

@implementation YearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureData {
    ConfigRegistration *regConfig = self.coordinator.regConfig;
    self.years = [regConfig.carManager getYearsWithOrder:NO andMinYear:regConfig.cityDetail.minCarYear];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.years count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"YearViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Museo-300" size:cell.detailTextLabel.font.pointSize]];
    }
    
    NSString *year =  [self.years objectAtIndex:indexPath.row];
    cell.textLabel.text = year;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *year =  [self.years objectAtIndex:indexPath.row];
    self.coordinator.car.year = year;
    [self.coordinator showNextScreenFromScreen:DSScreenCarYear];
}

@end

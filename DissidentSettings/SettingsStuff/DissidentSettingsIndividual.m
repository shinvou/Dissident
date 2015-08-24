#import "DissidentSettingsIndividual.h"

static NSString *cellIdentifier = @"dissidentSettingsIndividual";

@implementation DissidentSettingsIndividual

- (id)init
{
  if (self = [super init]) {
    int adSubstraction = [[objc_getClass("DissidentSM") sharedInstance] isPurchased] ? 0 : 50;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 20 - adSubstraction) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelectionDuringEditing = YES;

    [[self view] addSubview:_tableView];

    if (adSubstraction == 50) {
      UIView *adBackground = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, kScreenWidth, 50)];
    	adBackground.backgroundColor = UIColorRGB(74, 74, 74);
      [[self view] addSubview:adBackground];
    }

    [_tableView registerClass:[DissidentUITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Individual settings"];

  [_tableView setEditing:YES animated:NO];

  UIButton *addIndividual = [UIButton buttonWithType:UIButtonTypeContactAdd];
  [addIndividual addTarget:self action:@selector(addIndividualTapped) forControlEvents:UIControlEventTouchUpInside];
  [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:addIndividual]];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[objc_getClass("DissidentSM") sharedInstance] identifiersWithBackgroundModeSelected].count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = [[[objc_getClass("DissidentSM") sharedInstance] identifiersWithBackgroundModeSelected] objectAtIndex:indexPath.row];

  [[objc_getClass("DissidentSM") sharedInstance] setPreventTerminationEnabled:NO forIdentifier:identifier];
  [[objc_getClass("DissidentSM") sharedInstance] setBackgroundModeSelected:NO forIdentifier:identifier];
  [[objc_getClass("DissidentSM") sharedInstance] setAutomaticLaunchEnabled:NO forIdentifier:identifier];
  [[objc_getClass("DissidentSM") sharedInstance] setAutomaticRelaunchEnabled:NO forIdentifier:identifier];
  [[objc_getClass("DissidentSM") sharedInstance] removeIdentifier:identifier forBackgroundMode:[[objc_getClass("DissidentSM") sharedInstance] backgroundModeForIdentifier:identifier]];

  [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  DissidentUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
    cell = [[DissidentUITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  }

  NSString *currentIdentifier = [[[objc_getClass("DissidentSM") sharedInstance] identifiersWithBackgroundModeSelected] objectAtIndex:indexPath.row];

  cell.textLabel.text = [[ALApplicationList sharedApplicationList].applications objectForKey:currentIdentifier];
  cell.imageView.image = [[ALApplicationList sharedApplicationList] iconOfSize:29 forDisplayIdentifier:currentIdentifier];
  cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

  DissidentMethod dissidentMethod = [[objc_getClass("DissidentSM") sharedInstance] backgroundModeForIdentifier:currentIdentifier];

  if (dissidentMethod == DissidentMethodOff) {
    cell.detailTextLabel.text = @"Off";
  } else if (dissidentMethod == DissidentMethodFastFreeze) {
    cell.detailTextLabel.text = @"Fast Freeze";
  } else if (dissidentMethod == DissidentMethodNative) {
    cell.detailTextLabel.text = @"Native";
  } else if (dissidentMethod == DissidentMethodUnlimitedNative) {
    cell.detailTextLabel.text = @"Unlimited Native";
  } else {
    cell.detailTextLabel.text = @"Foreground";
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  NSString *identifier = [[[objc_getClass("DissidentSM") sharedInstance] identifiersWithBackgroundModeSelected] objectAtIndex:indexPath.row];

  DissidentSettingsIndividualApplication *dissidentSettingsIndividualApplication = [[DissidentSettingsIndividualApplication alloc] initWithIdentifier:identifier];
  [self.navigationController pushViewController:dissidentSettingsIndividualApplication animated:YES];
}

- (void)addIndividualTapped
{
  DissidentSettingsIndividualChooser *dissidentSettingsIndividualChooser = [[DissidentSettingsIndividualChooser alloc] init];
  [self.navigationController pushViewController:dissidentSettingsIndividualChooser animated:YES];
}

@end

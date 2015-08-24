#import "DissidentSettingsGlobal.h"

static NSString *cellIdentifier = @"dissidentSettingsGlobal";

@implementation DissidentSettingsGlobal

- (id)init
{
  if (self = [super init]) {
    int adSubstraction = [[objc_getClass("DissidentSM") sharedInstance] isPurchased] ? 0 : 50;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 20 - adSubstraction) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [[self view] addSubview:_tableView];

    if (adSubstraction == 50) {
      UIView *adBackground = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, kScreenWidth, 50)];
    	adBackground.backgroundColor = UIColorRGB(74, 74, 74);
      [[self view] addSubview:adBackground];
    }

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Global settings"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }

  return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 1) {
    return @"BACKGROUND MODE";
  }

  return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  if (section == 0) {
    return @"If enabled, closing apps via the app switcher won't actually close the app itself.\n\nThis option is perfect to use with Fast Freeze.";
  }

  NSString *offDescription = @"OFF\nDisables the backgrounding capability completely. The app has to restart every time you close it.";
  NSString *fastFreezeDescription = @"FAST FREEZE\nThis mode is similar to what 'Smart Close' by rpetrich did. Usually an app has up to 10 minutes to perform tasks in the background before it gets suspended in memory. Since this can be an unnecessary battery drain, Fast Freeze will suspend the app right after you close it.";
  NSString *nativeDescription = @"NATIVE\nThis is Apple's built in way of backgrounding.";
  NSString *unlimitedNativeDescription = @"UNLIMITED NATIVE\nThis background mode allows apps to execute background tasks for an unlimited period of time, so the app won't get suspended in memory after 10 minutes.";
  NSString *foregroundDescription = @"FOREGROUND\nForeground tricks the system into thinking that the app wasn't closed and is still running in foreground. This is the perfect way to continue to listen to internet streams or videos while using another app.";

  return [NSString stringWithFormat:@"\n%@\n\n%@\n\n%@\n\n%@\n\n%@", offDescription, fastFreezeDescription, nativeDescription, unlimitedNativeDescription, foregroundDescription];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }

  if (indexPath.section == 0) {
    cell.textLabel.text = @"Prevent termination";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    BOOL hasPreventTerminationSettings = [[objc_getClass("DissidentSM") sharedInstance] globalHasPreventTerminationSettings];

    _preventTerminationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_preventTerminationSwitch setOn:hasPreventTerminationSettings animated:NO];
    [_preventTerminationSwitch addTarget:self action:@selector(preventSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = _preventTerminationSwitch;
  } else {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Off";
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"Fast Freeze";
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"Native";
    } else if (indexPath.row == 3) {
      cell.textLabel.text = @"Unlimited Native";
    } else {
      cell.textLabel.text = @"Foreground";
    }

    if ([[objc_getClass("DissidentSM") sharedInstance] globalBackgroundMode] != DissidentMethodErrorOccured) {
      if ([[objc_getClass("DissidentSM") sharedInstance] globalBackgroundMode] == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      }
    } else {
      if (indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      }
    }

    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) _selectedIndexPath = indexPath;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 1) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [[objc_getClass("DissidentSM") sharedInstance] setGlobalBackgroundMode:indexPath.row];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedIndexPath = indexPath;
  }
}

- (void)preventSwitchChanged:(id)sender
{
  UISwitch *launchSwitch = sender;
  [[objc_getClass("DissidentSM") sharedInstance] setGlobalPreventTerminationEnabled:launchSwitch.on];

  [launchSwitch setOn:launchSwitch.on animated:YES];
}

@end

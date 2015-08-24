#import "DissidentSettings.h"

static NSString *cellIdentifier = @"dissidentSettings";

@implementation DissidentSettings

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

  UIButton *tweetButton = [[UIButton alloc] initWithFrame:CGRectZero];
  [tweetButton setImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/Heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
  [tweetButton sizeToFit];
  [tweetButton setTintColor:UIColorRGB(74, 74, 74)];
  [tweetButton addTarget:self action:@selector(handleTweet) forControlEvents:UIControlEventTouchUpInside];
  [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:tweetButton]];

  [self setTitle:@"Dissident"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 3) {
    return 2;
  }

  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return 286.0;
  }

  return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,286)];

    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 206)];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:60];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = UIColorRGB(74, 74, 74);
    label.text = @"#pantarhei";

    [headerView addSubview:label];

    return headerView;
  }

  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 3) {
    return @"CONTACT DEVELOPER";
  } else if (section == 4) {
    return @"CONTACT ICON DESIGNER";
  }

  return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  if (section == 0) {
    return @"These settings are used by every app.";
  } else if (section == 1) {
    return @"These settings override the global settings.";
  } else if (section == 3) {
    return @"Feel free to follow me on Twitter for any updates on my apps and tweaks or contact me for support questions.\n \nThis tweak is Open-Source, so make sure to check out my GitHub.";
  } else if (section == 4) {
    return @"Chon Lee did a great job on the icon of Dissident, follow him on Twitter and also take a look at his themes.";
  }

  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  if (indexPath.section == 0) {
    cell.textLabel.text = @"Global";
  } else if (indexPath.section == 1) {
    cell.textLabel.text = @"Individual";
  } else if (indexPath.section == 2) {
    cell.textLabel.text = @"Other settings";
  } else if (indexPath.section == 3) {
    if (indexPath.row == 0) {
      cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/twitter.png"];
      cell.textLabel.text = @"@biscoditch";
    } else {
      cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/github.png"];
      cell.textLabel.text = @"https://github.com/shinvou";
    }
  } else if (indexPath.section == 4) {
    cell.imageView.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/twitter.png"];
    cell.textLabel.text = @"@HikoMitsuketa";
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    DissidentSettingsGlobal *dissidentSettingsGlobal = [[DissidentSettingsGlobal alloc] init];
    [self.navigationController pushViewController:dissidentSettingsGlobal animated:YES];
  } else if (indexPath.section == 1) {
    DissidentSettingsIndividual *dissidentSettingsIndividual = [[DissidentSettingsIndividual alloc] init];
    [self.navigationController pushViewController:dissidentSettingsIndividual animated:YES];
  } else if (indexPath.section == 2) {
    DissidentSettingsOther *dissidentSettingsOther = [[DissidentSettingsOther alloc] init];
    [self.navigationController pushViewController:dissidentSettingsOther animated:YES];
  } else if (indexPath.section == 3) {
    if (indexPath.row == 0) {
      [[objc_getClass("SBUIController") sharedInstanceIfExists] clickedMenuButton];
      [self openTwitterForUsername:@"biscoditch"];
    } else {
      [[objc_getClass("SBUIController") sharedInstanceIfExists] clickedMenuButton];
      [self openGithubForUsername:@"shinvou"];
    }
  } else if (indexPath.section == 4) {
    [[objc_getClass("SBUIController") sharedInstanceIfExists] clickedMenuButton];
    [self openTwitterForUsername:@"HikoMitsuketa"];
  }
}

- (void)handleTweet
{
  SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
  [composeController setInitialText:@"I’m using Dissident by @biscoditch for real app background management on my device!"];
  [self presentViewController:composeController animated:YES completion:nil];
}

- (void)openTwitterForUsername:(NSString *)username
{
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]]];
  } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@", username]]];
  } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetings:///user?screen_name=%@", username]]];
  } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", username]]];
  } else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://mobile.twitter.com/%@", username]]];
  }
}

- (void)openGithubForUsername:(NSString *)username
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@", username]]];
}

@end

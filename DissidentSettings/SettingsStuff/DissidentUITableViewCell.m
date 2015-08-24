#import "DissidentUITableViewCell.h"

@implementation DissidentUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];

    if (self) {
      // Sheesh, we exist. Is this real life?
    }

    return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  // Hide the editing accessory when the delete button is visible, otherwise
  if (self.showingDeleteConfirmation) {
    self.editingAccessoryType = UITableViewCellAccessoryNone;
  } else {
    self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
}

@end

#import "Dissident.h"

int (*original__BSAuditTokenTaskHasEntitlement)(int unknownFlag, NSString *entitlement);
int replaced__BSAuditTokenTaskHasEntitlement(int unknownFlag, NSString *entitlement)
{
	if ([entitlement isEqualToString:@"com.apple.multitasking.unlimitedassertions"]) {
		return 1;
	}

	return original__BSAuditTokenTaskHasEntitlement(unknownFlag, entitlement);
}

%ctor {
	@autoreleasepool {
		if ([[[NSClassFromString(@"NSProcessInfo") processInfo] processName] isEqualToString:@"assertiond"]) {
			MSHookFunction(MSFindSymbol(NULL, "_BSAuditTokenTaskHasEntitlement"), (void *)replaced__BSAuditTokenTaskHasEntitlement, (void **)&original__BSAuditTokenTaskHasEntitlement);
		}
	}
}

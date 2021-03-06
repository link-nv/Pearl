/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  PearlArrayTVC.m
//
//  Created by Maarten Billemont on 05/11/10.
//  Copyright 2010 Lhunath. All rights reserved.
//

#define PearlATVCCellID         @"Pearl.ArrayTVC.cell"
#define PearlATVCRowName        @"Pearl.ArrayTVC.name"
#define PearlATVCRowDetail      @"Pearl.ArrayTVC.detail"
#define PearlATVCRowStyle       @"Pearl.ArrayTVC.style"
#define PearlATVCRowToggled     @"Pearl.ArrayTVC.toggled"
#define PearlATVCRowDelegate    @"Pearl.ArrayTVC.delegate"
#define PearlATVCRowContext     @"Pearl.ArrayTVC.context"
#define PearlATVCCellStyle      @"Pearl.ArrayTVC.cellstyle"

@interface PearlArrayTVC(Private)

- (void)addRowWithName:(NSString *)aName withDetail:(NSString *)aDetail cellStyle:(UITableViewCellStyle)aCellStyle
              rowStyle:(PearlArrayTVCRowStyle)aRowStyle toggled:(BOOL)isToggled toSection:(NSString *)aSection
          withDelegate:(id<PearlArrayTVCDelegate>)aDelegate context:(id)aContext;

@end

@implementation PearlArrayTVC

- (id)initWithCoder:(NSCoder *)aDecoder {

    if (!(self = [super initWithCoder:aDecoder]))
        return self;

    NSAssert([NSThread currentThread].isMainThread, @"Should be on the main thread; was on thread: %@", [NSThread currentThread].name);

    _sections = [NSMutableArray new];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (void)removeAllRows {

    [_sections removeAllObjects];
}

- (void)removeRowWithName:(NSString *)aName fromSection:(NSString *)aSection {

    for (NSDictionary *section in _sections)
        if (!aSection || [[[section allKeys] lastObject] isEqualToString:aSection]) {
            NSMutableArray *sectionRows = [[section allValues] lastObject];

            for (NSDictionary *row in sectionRows)
                if ((aName == nil && [row objectForKey:PearlATVCRowName] == [NSNull null]) ||
                    [[row objectForKey:PearlATVCRowName] isEqualToString:aName]) {
                    [sectionRows removeObject:row];
                    return;
                }
        }
}

- (void)removeRowWithContext:(id)aContext fromSection:(NSString *)aSection {

    for (NSDictionary *section in _sections)
        if (!aSection || [[[section allKeys] lastObject] isEqualToString:aSection]) {
            NSMutableArray *sectionRows = [[section allValues] lastObject];

            for (NSDictionary *row in sectionRows)
                if (NSNullToNil([row objectForKey:PearlATVCRowContext]) == aContext) {
                    [sectionRows removeObject:row];
                    return;
                }
        }
}

- (void)addRowWithName:(NSString *)aName style:(PearlArrayTVCRowStyle)aStyle toggled:(BOOL)isToggled toSection:(NSString *)aSection
          withDelegate:(id<PearlArrayTVCDelegate>)aDelegate context:(id)aContext {

    [self addRowWithName:aName withDetail:nil cellStyle:UITableViewCellStyleDefault rowStyle:aStyle toggled:isToggled toSection:aSection
            withDelegate:aDelegate context:aContext];
}

- (void)addRowWithName:(NSString *)aName withDetail:(NSString *)aDetail toSection:(NSString *)aSection
          withDelegate:(id<PearlArrayTVCDelegate>)aDelegate
               context:(id)aContext {

    [self addRowWithName:aName withDetail:aDetail cellStyle:UITableViewCellStyleValue1 rowStyle:PearlArrayTVCRowStylePlain toggled:NO
               toSection:aSection withDelegate:aDelegate context:aContext];
}

- (void)addRowWithName:(NSString *)aName withDetail:(NSString *)aDetail cellStyle:(UITableViewCellStyle)aCellStyle
              rowStyle:(PearlArrayTVCRowStyle)aRowStyle toggled:(BOOL)isToggled toSection:(NSString *)aSection
          withDelegate:(id<PearlArrayTVCDelegate>)aDelegate context:(id)aContext {

    NSMutableArray *sectionRows = nil;
    for (NSDictionary *section in _sections)
        if ([[[section allKeys] lastObject] isEqualToString:aSection]) {
            sectionRows = [[section allValues] lastObject];
            break;
        }
    if (!sectionRows)
        [_sections addObject:[NSDictionary dictionaryWithObject:sectionRows = [NSMutableArray array] forKey:aSection]];

    [sectionRows addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
            NilToNSNull(aName),                          PearlATVCRowName,
            NilToNSNull(aDetail),                        PearlATVCRowDetail,
            [NSNumber numberWithUnsignedInt:aRowStyle],  PearlATVCRowStyle,
            [NSNumber numberWithUnsignedInt:aCellStyle], PearlATVCCellStyle,
            [NSNumber numberWithBool:isToggled],         PearlATVCRowToggled,
            NilToNSNull(aDelegate),                      PearlATVCRowDelegate,
            NilToNSNull(aContext),                       PearlATVCRowContext,
            nil]];
}

- (void)customizeCell:(UITableViewCell *)cell forRow:(NSDictionary *)row withContext:(id)context {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return (NSInteger)[_sections count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {

    return (NSInteger)[(NSArray *)[[[_sections objectAtIndex:(NSUInteger)section] allValues] lastObject] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [[[_sections objectAtIndex:(NSUInteger)section] allKeys] lastObject];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *sectionRows = [[[_sections objectAtIndex:(NSUInteger)indexPath.section] allValues] lastObject];
    NSDictionary *row = [sectionRows objectAtIndex:(NSUInteger)indexPath.row];

    UITableViewCellStyle cellStyle = (UITableViewCellStyle)[NSNullToNil([row objectForKey:PearlATVCCellStyle]) integerValue];
    NSString *identifier = [NSString stringWithFormat:@"%@-%d", PearlATVCCellID, cellStyle];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:identifier];

    cell.textLabel.text = NSNullToNil([row objectForKey:PearlATVCRowName]);
    cell.detailTextLabel.text = NSNullToNil([row objectForKey:PearlATVCRowDetail]);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    switch ([NSNullToNil([row objectForKey:PearlATVCRowStyle]) unsignedIntValue]) {
        case PearlArrayTVCRowStylePlain:
            break;
        case PearlArrayTVCRowStyleLink: {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
        }
        case PearlArrayTVCRowStyleDisclosure: {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case PearlArrayTVCRowStyleCheck: {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if ([[row objectForKey:PearlATVCRowToggled] boolValue])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
        case PearlArrayTVCRowStyleToggle: {
            UISwitch *switchView = [[UISwitch alloc] init];
            switchView.on = [[row objectForKey:PearlATVCRowToggled] boolValue];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryView = switchView;
            break;
        }
    }

    [self customizeCell:cell forRow:row withContext:NSNullToNil([row objectForKey:PearlATVCRowContext])];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *sectionName = [[[_sections objectAtIndex:(NSUInteger)indexPath.section] allKeys] lastObject];
    NSArray *sectionRows = [[[_sections objectAtIndex:(NSUInteger)indexPath.section] allValues] lastObject];
    NSMutableDictionary *row = [sectionRows objectAtIndex:(NSUInteger)indexPath.row];

    BOOL newToggled = ![[row objectForKey:PearlATVCRowToggled] boolValue];
    if ([NSNullToNil([row objectForKey:PearlATVCRowDelegate]) shouldActivateRowNamed:NSNullToNil([row objectForKey:PearlATVCRowName])
                                                                           inSection:sectionName
                                                                         withContext:NSNullToNil([row objectForKey:PearlATVCRowContext])
                                                                            toggleTo:newToggled]) {
        [row setObject:[NSNumber numberWithBool:newToggled] forKey:PearlATVCRowToggled];
        switch ([NSNullToNil([row objectForKey:PearlATVCRowStyle]) unsignedIntValue]) {
            case PearlArrayTVCRowStyleToggle: {
                [(UISwitch *)[[self.tableView cellForRowAtIndexPath:indexPath] accessoryView] setOn:newToggled animated:YES];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
            }
            case PearlArrayTVCRowStyleCheck: {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            default:
                break;
        }
    }
}

@end

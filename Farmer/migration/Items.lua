local _, addon = ...;

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Items', {
    showBags = 'showBagCount',
    showTotal = 'showTotalCount',
    rarity = 'filterByRarity',
    minimumRarity = 'minimumRarity',
    reagents = 'alwaysShowReagents',
    questItems = 'alwaysShowQuestItems',
    recipes = 'alwaysShowRecipes',
    special = 'alwaysShowFocusItems',
    focus = 'onlyShowFocusItems',
    focusItems = 'focusItems',
  });
end);

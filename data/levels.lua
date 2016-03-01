--
-- User: Pedro
-- Date: 3/1/2016
--

levels = {}

stage1 = {}
stage1['name'] = "Day One"
stage1['enemyBoundA'] = 1
stage1['enemyBoundB'] = 1
stage1['enemyCount'] = 40
stage1['leftBuddyPresent'] = true
stage1['rightBuddyPresent'] = true

stage2 = {}
stage2['name'] = "Day Two"
stage2['enemyBoundA'] = 1
stage2['enemyBoundB'] = 2
stage2['enemyCount'] = 60
stage2['leftBuddyPresent'] = true
stage2['rightBuddyPresent'] = false

stage3 = {}
stage3['name'] = "Day Three"
stage3['enemyBoundA'] = 1
stage3['enemyBoundB'] = 2
stage3['enemyCount'] = 80
stage3['leftBuddyPresent'] = false
stage3['rightBuddyPresent'] = false

stage4 = {}
stage4['name'] = "Day Four"
stage4['enemyBoundA'] = 1
stage4['enemyBoundB'] = 3
stage4['enemyCount'] = 75
stage4['leftBuddyPresent'] = false
stage4['rightBuddyPresent'] = false

table.insert(levels, stage1)
table.insert(levels, stage2)
table.insert(levels, stage3)
table.insert(levels, stage4)

return levels
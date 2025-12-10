# CatFishing #

## Summary ##

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```

For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

## Loc Nguyen ##

### Main Role 1: Level and World Designer ###

### Day/Night Cycle ###

Our game includes a day/night cycle to encourage player to return to the island and interact with it. When it is night time, player would not be able to enter the ocean from the island. If they are already in the ocean and it is becoming late, with the inspiration from Stardew Valley, the player would "pass out", get teleported back to the island, and lose half of the fish they are carrying.

- [*Main game clock*](https://github.com/3yaa/catfishing/blob/658e5dfbbf2c341ce6b17bd8107e8072f4b1f74b/scripts/ocean_area.gd#L27): The clock is a `Timer` alternating between 2 different durations for day and night that can be individually adjusted for game feel. For other components that depends on the clock, they can access the signal `clock.cycle_changed` or check the boolean variable `clock.is_day`. It can also be paused, using `pause_clock()` and `resume_clock()`, for cases like when player entering minigame.
- [*One-way barrier*](https://github.com/3yaa/catfishing/blob/658e5dfbbf2c341ce6b17bd8107e8072f4b1f74b/scripts/ocean_area.gd#L27): A barrier that is raised at night when player is on the island, preventing them from entering the ocean while still allowing them to return to the island. It is implemented by enabling/disabling a `CollisionShape2D` depending on the player's position and time logic. 
- [*Staying late in ocean*](https://github.com/3yaa/catfishing/blob/658e5dfbbf2c341ce6b17bd8107e8072f4b1f74b/scripts/player.gd#L129): If player hasn't returned by halfway through the night `clock.get_remaining_time() < 0.5 * clock.night_duration`, they will be teleported back to the island and lose some of their fish. For simplicity, they would lose half of the fish in their inventory, which are the ones located at the odd indices for the sense of "randomness". With more time, I wish to make a true random selection with a random amount as well.
- [*Visual*](https://github.com/3yaa/catfishing/blob/658e5dfbbf2c341ce6b17bd8107e8072f4b1f74b/scripts/day_night_theme.gd): The main background is swapped based on day or night. A color filter is also applied through `ColorRect` on top of the game to make other assests in the foreground appear darker at night.

|  |  |
:-------------------------:|:-------------------------:
![Day](./document_images/day.png) | ![Night](./document_images/night.png)


### NPCs System ###

The game includes NPCs that spawn as drowning cats for the player to rescue, after which they would become shopskeepers on the island. This rescuing gameplay was designed to encourage player to go further into the ocean and explore more if the game scales up, giving player more incentive to buy upgrades.

There is a [NPC](https://github.com/3yaa/catfishing/blob/5a17f738dc10ffede2887f316b9a12b835bbd458/scripts/npc/npc.gd) class that each NPC can extend from. NPC is of type `Area2D` to check for player proximity via `_on_body_entered()` before allowing interaction. Player can interact with NPC by pressing the (E) key. Depending on the state `npc.rescued`, the interaction would either be rescuing the NPC or opening up their equivalent shop. This state also determines the NPC's location on the game, the different animations to used, and the dialogue shown to player when they are nearby. An example: [Fish Shop NPC](https://github.com/3yaa/catfishing/blob/5a17f738dc10ffede2887f316b9a12b835bbd458/scripts/npc/npc_fish_shop.gd)


### Shoping System ###

There are 3 shops in the game. Fish Shop allows player to sell the fish they caught to earn money and pay their debt. Upgrade Shop allows player to buy upgrades to increase their stats. Cosmetic Shop allows player to buy cosmetic items for the island. 

(Buttons animation was done by Taef)

![Game Economy](./document_images/game_economy.PNG)

#### Fish Shop ####

When player opens the shop, they would be able to see the number of fish in their inventory as well as their total value. There is one Sell button that allows player to sell all of their fish at once. In [the selling process](https://github.com/3yaa/catfishing/blob/cce26d3bf1e058d89f71f988fb39006d5b8a7127/scripts/fish_shop_manager.gd#L127), that amount of money would be added to `player.money`, their inventory `fish_logic.fish_inventory` would be cleared, and the display of the shop would be updated.

![Fish Shop](./document_images/shop_selling.png)

#### Upgrade Shop ####

In this shop, there are 2 types of upgrades that player can buy: stats upgrades and minigame power-ups. These upgrades are kept track by variables in `player.gd`. Stats upgrades help player with the main game with things like increasing their chance of getting higher quality fish or earning money faster. They are point-based system where player can keep buying to increase their stats. (e.g. [`buy_luck()`](https://github.com/3yaa/catfishing/blob/cce26d3bf1e058d89f71f988fb39006d5b8a7127/scripts/upgrade_shop_manager.gd#L139)) Power-ups are abilities that can be used in the minigame. They are one-time purchases that player can buy to unlock forever. (e.g. [`buy_power1()`](https://github.com/3yaa/catfishing/blob/cce26d3bf1e058d89f71f988fb39006d5b8a7127/scripts/upgrade_shop_manager.gd#L159)). When the shop is opened and after each buy, the [shop display is updated](https://github.com/3yaa/catfishing/blob/cce26d3bf1e058d89f71f988fb39006d5b8a7127/scripts/upgrade_shop_manager.gd#L101) to reflect the latest stats of player. If a power-up is already bought, its button would be disabled and marked as "Owned".

![Upgrade Shop](./document_images/shop_upgrades.png)


#### Cosmetic Shop ####

For cosmetic, we decided to use pre-set items because of time constraint. Each item is a `Sprite2D` node that is arranged on the island, all contained within the `Cosmetics` scene. At the start of the game, all of these item would be hidden away. When an item is purchased, its visibility would then be turned on. 


## Jamie Jang ##

### Main Role: AI and Behavior Designer ###

### Fish reeling logic: ###
The fish has three field variables that are essential to its behavior, fish_rarity, size, and value.

fish_rarity:
The fish_rarity is chosen randomly based on a formula: 

SUPER_RARE\% + RARE\% + COMMON\% = 100.0, 

where the constraints are that:

SUPER_RARE = player.luck\% 
RARE = (2 * player.luck)\%
COMMON = [100 - (3 * player.luck)]\%

The fish rarity formula is bound to the player’s luck stat which can be upgraded to increase the chances of rarer fish appearing. To replicate this optimization problem, we roll a random integer between 1 and 100, and if the roll falls under the thresholds, roll < player.luck\%, roll < player.luck * 3, and everything else for SUPER_RARE, RARE, and COMMON respectively, that is what it will be assigned to. I used elif statements to ensure the behavior reflects this formula. 

reeling: 
For the actual reeling, based on the player’s reel_skill, a conditional is used to determine if each instance reeled a fish or not. The conditional used is: 
	
if reel_chance > roll:

roll is just a random float between 0 and 100, so the chance to reel in a fish each interval is roughly player.reel_skill \%. reel_chance is initially the player’s reel_skill at the start of every fishing attempt. However, each interval will increase this chance by 10.0, making it so any subsequent interval should increase the likelihood of reeling a fish in. Upgrading your reel_skill should essentially lead to less intervals passing, meaning that you should have to wait less. 

[Reel Logic:]([https://github.com/3yaa/catfishing/blob/main/scripts/fish_logic.gd](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/fish_logic.gd#L29-L76))

## Fish creation/value logic: ##
size: 
The size is a float that is randomly assigned between size_min and size_max, two variables that never change during runtime. 

value: 
The value is calculated based on the previous two fields, the rarity and the size. The formulas is as follows:

value = (base_price + size)  * player.salesman * (rarity + 1)

The base_price refers to just a normal base_price of the fish that can be modified by the developer. This is to ensure that the scalars work as intended. I.e. it would be unreasonable for a common fish with a large size to be more expensive than a very small super rare fish. The size is the base “value” of the fish which is multiplied by two scalars to get the final value. The first scalar, player.salesman is another player stat that determines how much the fish will sell for on top of its size (like bargaining to sell for more). The (rarity + 1) scalar refers to any integer between 1 and 3. The enum Rarity has 3 elements, and to determine the enum randomly, we choose a random integer between 0 and 2. Thus, the scalar would be this random integer + 1 so the rarity scalar would be between 1 and 3. The rarity largely dictates how much rarer the fish truly is. 

[Fish Creation Logic:](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/fish_logic.gd#L101-L127)

### Blackjack fish AI: ###
The target score for blackjack is set to max_val, which may change due to powerups/modifiers, and there are also two variables, common_offset and rare_offset. For the purpose of explaining the AI however, please assume that the max_val is 21and the common_offset and rare_offset are 7 and 4 respectively.

Common fish:
The purpose of common fish is to lead to somewhat quick and easy games while
punishing those that keep hitting for high numbers. The common fish has a very simple heuristic where they will keep hitting as long as their sum is < max_val - common_offset, or sum is < 14.The fish should stop hitting once they reach any number greater than 13. This is because in theory, the average sum of two randomly drawn cards is around 14.6~, so the objective is for common fish to stop hitting a little under this value at 14 .This will allow the fish to produce hands ranging from 14-21 This allows for the fish to hit higher values as well as low values. This should teach the player that always aiming for 21 is not the answer; this will lead the player to consistently bust and lose the fish. Instead, the strategy should be to aim for moderately high values between 18-21. 

For example, if the fish’s initial sum of its hand is 13:

[A, 2, 3, 4, 5, 6, 7, 8] → Safe, sum between 14-21
[9, 10] → Bust, sum between 22-23

The idea is that the common fish should usually be safe from a bust, so if a player is too ambitious and hits on higher numbers, they may lose rounds that they would have won if they stood instead. 

The general strategy for common fish would be to try and play it safe; don't get too greedy but don't be too conservative. You should aim for a moderately high number (15+). There should be tweaks to this strategy based on the card that you can see from the fish (for example if 
they have an ace (1/11) you may want to aim for higher numbers as usual (18+).

Rare fish:
	The purpose of rare fish is to introduce a difficulty that common fish are unable to bring. The rare fish also follows a simple heuristic, keep hitting as long as their sum is < max_val - rare_offset, which is sum < 17. This is because the possible hands choices for an initial sum of 16 would lead to this outcome:

[A, 2, 3, 4, 5] → Safe, sum between 17-21
[6, 7, 8, 9, 10] → Bust, sum between 22-26

This should yield a roughly 50\% chance for a safe or a bust. Because there is no replacement, it is not exactly 50\% but it should hover around that value. This strategy may lead to more overall busts from the rare fish, but it should produce higher values on average.
Despite the fish busting more frequently, it should force the player to play more aggressively, as playing too passively would result in them consistently losing. 

The general strategy against the rare fish should be to try and aim for relatively high numbers (17-21) so that in the case the fish does indeed hit, they will either bust or have a sum less than your final sum. 

Super rare fish:

This is the hardest difficulty for the fish, and they will be able to see the player’s hand, giving them a major advantage. The super rare fish is going to be largely luck-based to win against, as they will ALWAYS hit so long as their score is less than yours. Their objective is to force a draw or win. 
	
For example, say the player’s sum is 20 and the fish’s initial sum is 10. Some permutations that would lead to the fish’s victory include (but are not limited to):

[(A), (2, 9), (3, 8), (4, 7), (5, 6), (3, 3, 5), (4, 2, 5), (4, 4, 2, 1), (2, 2, 2, 2, 3), …]

The idea is that this fish should have a wide variety of options available to them due to the various permutations that would lead them to 21. Hence, the player should aim to get a high sum as frequently as possible. 

However, if the player’s sum is 20 and fish’s initial sum is 19:

[(A), (A, A), (2)]

The fish’s victory conditions are far smaller than before, so they are more than likely to bust. As mentioned before, the average hand has a sum of 14.6~, so although the fish has an advantage, hitting every time will be a matter of luck as opposed to skill. 

The general strategy against the Super Rare fish is to have a high sum (19-21), so if the fish does not initially have a larger sum than your final hand, there will be a greater chance that the fish will bust trying to surpass your score. 

[Blackjack Logic](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/minigame/blackjack.gd#L104-L155)

#### Behavior Tree: ####

Reeling Logic:
![Reeling_logic](document_images/IMG_0460.jpg)

Common Fish Behavior:
![Common fish](document_images/IMG_0461.jpg)

Rare Fish Behavior:
![Rare fish](document_images/IMG_0462.jpg)

Super Rare Fish Behavior:
![Super Rare fish](document_images/IMG_0463.jpg)

#### Tuning ####
fish_logic.gd:
size_min, size_max, they can be changed to any float so long as size_min < size_max. 
base_price, it is the base price of any fish, this can be changed to any float so long as the decimal points are to the hundredths place. 
fishing_cooldown is the intervals between each “check” to see if the fish was reeled in

[Variables](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/fish_logic.gd#L9-L13)


### Sub-Role: Player Onboarding and Tutorial Design ###
Documentation for Sub-Role
    
### Tutorial Design: ###
The tutorial starts in the beginning, and it should walk the player through the basic core mechanics. The player should walk to the ocean, and save a cat who will later buy your fish for money used for progression. Then, the player should learn to fish, which will prompt a minigame when a fish “bites.” The minigame is blackjack, and the basic rules and features will be explained to the player. After successfully catching the fish (or failing to catch the fish, the result is unimportant), the player will be told that during night, the player must return back to the island. Once the player is back on the island, they will be prompted to talk to the cat that they saved earlier and can sell the fish by interacting with the NPC. This should mark the end of the tutorial, it covers the core mechanics: movement, fishing, rescuing npcs, blackjack, and progression. There are intentionally “unexplored” aspects of the game such as the uses of money, (which will later be revealed to upgrade skills or buy cosmetics from NPCs). This was done to give the player some freedom to discover the game as well. Showing everything in the tutorial may discourage the player to explore and enjoy the game; ending on somewhat of a cliffhanger intends to motivate the player to explore the game to find other aspects. 

The tutorial itself is largely based on signal logic, with signals being awaited and button presses (or other conditions) emitting completion signals. Most of the tutorial can be progressed through by pressing the interact button “E” which will emit the respective signal and continue. Some other conditions may be pressing other buttons such as the fishing button or awaiting the player to reach the ocean or land. 

The learning curve in general should not be very high, which is also why the tutorial is intentionally on the shorter side to reflect this. 

[Tutorial](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/tutorial_manager.gd#L32-L188)

### Hint Design: ###
There will be random hints after the tutorial on the top of the screen to explain some unintuitive facts about the game, especially features (such as stat upgrades and what each stat does) that are introduced after the tutorial. These were moved to hints instead of being integrated into the tutorial to avoid redundancy and give the player the chance to explore and learn more about the game themselves. The hints should try and offset the omission of features from the tutorial. Things that may seem unintuitive to players should eventually be revealed to them in the form of hints. 

The hints should appear for 10 seconds and disappear for another 20, leading to 2 hints per minute. This should be enough time to read each hint and be frequent enough to provide any useful information without overloading the player with more information. I opted for 2 hints per minute so there should be about 10 hints in 5~ minutes, which should get through most or all of the hints in the timeframe.

[Hints](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/hints.gd#L22-L54)


## Other contributions ## 
### Debt Paid asset: ### 
Drew the "Debt Paid" asset that is shown when the debt is fully paid off. 

### Music: ###
Made the music played in the main theme and quietly in the background within the game (Not to be confused with the sound effects).

### Debt: ###
Implement debt payments within one of the NPCs. 

[Main Debt related code](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/fish_shop_manager.gd#L45-L68)
[Debt gd](https://github.com/3yaa/catfishing/blob/ee1cbe05b00215d02373b8d100fc9a1afdb8c774/scripts/debt.gd#L1-L9)


## Main Roles ##

## Sub-Roles ##

## Other Contributions ##

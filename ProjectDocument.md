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

### NPCs System ###

The game includes NPCs that spawn as drowning cats for the player to rescue, after which they would become shopskeepers on the island. This rescuing gameplay was designed to encourage player to go further into the ocean and explore more if the game scales up, giving player more incentive to buy upgrades.

There is a [NPC](https://github.com/3yaa/catfishing/blob/5a17f738dc10ffede2887f316b9a12b835bbd458/scripts/npc/npc.gd) class that each NPC can extend from. NPC is of type `Area2D` to check for player proximity via `_on_body_entered()` before allowing interaction. Player can interact with NPC by pressing the (E) key. Depending on the state `npc.rescued`, the interaction would either be rescuing the NPC or opening up their equivalent shop. This state also determines the NPC's location on the game, the different animations to used, and the dialogue shown to player when they are nearby. An example: [Fish Shop NPC](https://github.com/3yaa/catfishing/blob/5a17f738dc10ffede2887f316b9a12b835bbd458/scripts/npc/npc_fish_shop.gd)


### Shoping System ###

There are 3 shops in the game. Fish Shop allows player to sell the fish they caught to earn money and pay their debt. Upgrade Shop allows player to buy upgrades to increase their stats. Cosmetic Shop allows player to buy cosmetic items on the island. 

![Game Economy](document_images/game_economy.png)


## Main Roles ##

## Sub-Roles ##

## Other Contributions ##
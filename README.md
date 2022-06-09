# SuperGlue

SuperGlue is _(read: will be)_ a Garry's Mod add-on that allows you to rigidly attach any number of props together by grouping them under a single physics mesh. The novel approach taken by SuperGlue allows for rigid, glitchless prop combinations that retain the functionality, constraints, physics, and pose of the original props. SuperGlued contraptions also work seamlessly with the vanilla Duplicator tool, and are persistent across singleplayer saves. At its core, SuperGlue is the tool that the Weld tool should've been.

## Core Functionalities

SuperGlue takes a fundementally different, novel approach to object joining in Source that allows it to do things previous tools weren't capable of. SuperGlue can:

* Rigidly attach (weld) any number of props together in a single operation
* Retain properties of the original props
  * Functionality
  * Constraints
  * Physics properties
  * Position and angle
* Work seamlessly with vanilla Duplicator tool
* Be persistent across singleplayer saves
* Work in multiplayer

|Function                          |PolyWeld (current)|Forge|PolyWeld (pre-2015)|SuperGlue|
|----------------------------------|------------------|-----|-------------------|---------|
|Combine 2 objects                 |:x:               |:heavy_check_mark:|:heavy_check_mark: |:heavy_check_mark:|
|Preserve Constraints              |:x:               |:heavy_check_mark:|:heavy_check_mark: |:heavy_check_mark:|
|Multiplayer                       |:x:               |:heavy_check_mark:|:heavy_check_mark: |:heavy_check_mark:|
|Combine 3+ objects                |:x:               |:x:  |:heavy_check_mark: |:heavy_check_mark:|
|Visual Selection Indicator        |:x:               |:x:  |:heavy_check_mark: |:heavy_check_mark:|
|Reversible                        |:x:               |:x:  |:x:                |:heavy_check_mark:|
|Retain Center of Mass             |:x:               |:x:  |:x:                |:heavy_check_mark:|
|Saves in Singleplayer             |:x:               |:x:  |:x:                |:heavy_check_mark:|
|Works with Vanilla Duplicator tool|:x:               |:x:  |:x:                |:heavy_check_mark:|

## Standing on the shoulders of giants

SuperGlue is certainly not the first to attempt to solve this problem. This addon takes inspiration from a number of projects that came before it, and those developers deserve credit.

### [PolyWeld](https://steamcommunity.com/sharedfiles/filedetails/?id=344795193) by [Bobblehead](https://steamcommunity.com/id/bobbleheadbob)

 PolyWeld, formally known as _Improved Polyweld Tool_, is as ubiquitous in the gmod community as the weld tool itself. This tool worked fantastically and was capable of the leading goal of this project, _rigidly attaching any number of props together in a single operation_. That said, it did not work across saves, duplications, or reloads. That said, the addon was widely popular until around 2015, until a bug appeared in PolyWeld that caused the entity selection process to be effectively random, which effectively rendered PolyWeld useless. Unfortunately, it seems to have been since abandonded by its creators. There are a number of flaws fundemental to the design of Forge that SuperGlue looks to resolve. Some of these are:

* Limitation of joining two props at a time
* Incompadible with vanilla duplicator
* Usually butchers child constraints
* Mutilates center-of-gravity
* Deleted across local saves.

That said, SuperGlue takes a lot of inspiration from PolyWeld, and I want to thank the authors of PolyWeld for their years of hard work.

### [Forge](https://steamcommunity.com/sharedfiles/filedetails/?id=2518703605) by [WFL](https://steamcommunity.com/id/willdebee) and [deBanzie](https://steamcommunity.com/id/theendisverynear)

Forge, formally _Forge Constraint_, is a highly polished, visually attractive PolyWeld-style tool that combines two objects at a time and attempts to retain their constraints. The Forge tool looks and feels much more pleasant than anything built into Garry's Mod. The authors of this plugin did a lot of fantastic work, but unfortunately, all of the listed design issues that plague PolyWeld also plague Forge. Additionally, the limitation of two props at a time, a system fundemental to the design of Forge, makes it nearly unusable for complex geometry, as it forces the server to recalculate the entire mesh for each object, which can take literal months for complex machines due to a limitation in the Source Engine.

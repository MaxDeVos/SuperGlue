# SuperGlue
SuperGlue is _(read: will be)_ a Garry's Mod add-on that allows you to rigidly attach any number of props together by grouping them under a single physics mesh. The approach taken by SuperGlue allows for rigid, glitchless prop combinations that retain the functionality, constraints, physics, and pose of the original props. It will also be compatible with the vanilla Duplicator tool, and SuperGlue combinations will be persistent across singleplayer saves. At its core, SuperGlue is the tool that the Weld tool should've been.

## Core Functionalities
* Rigidly attach (weld) any number of props together in a single operation
* Retain properties of the original props
  * Functionality
  * Constraints
  * Physics properties
  * Position and angle
* Persistent across singleplayer saves
* Compadible with vanilla Duplicator tool
* Works in multiplayer

## Standing on the shoulders of giants
SuperGlue is certainly not the first to attempt to solve this problem. Before SuperGlue came [PolyWeld by Bobblehead](https://steamcommunity.com/sharedfiles/filedetails/?id=344795193&searchtext=polyweld), formally known as _Improved Polyweld Tool_. This tool worked fantastically and acomplished the vast majority of the functionalities this plugin aims to acomplish. However, a function at the core of PolyWeld, known as Entity:PhysicsInitMultiConvex, was broken by Valve around 2015, which has since rendered PolyWeld inoperable, and it seems to have been since abandonded by its creators. SuperGlue takes a lot of inspiration from PolyWeld, and I want to thank the authors of PolyWeld for their years of hard work.

# Malfiauxtts
A repository for all mods relating to the Malifaux Tabletop Simulator mod

To build the mod

Step 1.  Press the build button on the work spreadsheet

Step 2.  Update model Prototype with New tokens
    In tabletop sim open the 4EStatCardCreater/ Card Builder v2 mod
    Stay in th e4EStatCardCreater/ Card Builder v2 mod
    replace line 14 with contents of model prototype 2 google doc
    find the comments REPLACE WITH CONTENTS OF model prototype 2 GOOGLE DOC and replace what is in bweteen the two comments with the contests of prototype 2
    find the comments REPLACE WITH CONTENTS OF model prototype 1 GOOGLE DOC and replace what is in bweteen the two comments with the contests of prototype 1

Step 3.  Import model and refrences/upgrade cards.
    Stay in th e4EStatCardCreater/ Card Builder v2 mod
    Open the libeary object and replace modellibeary json with the json in the ModelLibrary google docs
    replace crewcardlibeary json with the json in the RefcardLibrary google docs
    replace upgrasdelibeary json with the json in the upgrade google docs
    Press the gen cards button.  This will take a few minutes
    When the process is done overwrite  V2 Filled
Step 4.  Import tokens
    Open the 4EBaseModComponents/Tokens V2 mod
    Open the libeary object and replace special token libeary json with the json in the special tokens google docs
    Press the gen cards button
    When the process is done overwrite Tokens V2 Filled

Step 5.  Import Markers
    Open the 4EBaseModComponents/Markers V2 mod
    Open the libeary object and replace special sarkers libeary json with the json in the  special markers google docs
    Press the gen cards button
    When the process is done overwrite Markers V2 Filled

Step 6. Create a folder named the date of the update
    run from the command line UtilityScripts/buildMod.py ###NAME OF FOLDER CREATED###/wip.json
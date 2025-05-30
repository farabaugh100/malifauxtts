import sys
import json
def importObjects(destinationData,fileName,objList):

    destinationIdList=[]
    for obj in destinationData["ObjectStates"]:
        destinationIdList.append(obj["GUID"])
    with open(fileName, 'r') as file:
        originData = json.load(file)


    objToExport=[]
    for obj in originData["ObjectStates"]:
        if obj["GUID"] in objList:
            print(obj["Nickname"])
            objToExport.append(obj)

    for obj in objToExport:
        if obj["GUID"] in destinationIdList:
            print(obj["GUID"]+" Exists in destination file")
        else:
            destinationData["ObjectStates"].append(obj)
#Script to pull objects from one Mod and inject them into another.  
#The script isn't smart enough to not overlap objects so you should prepare the destination file for the injection
#takes command line arguments for the two files.  Source first then destination.
#Right now the ids to pull are hardcoded.  Probably should be a command line arg too but I was feeling lazy.
print(sys.argv)

bareMod="../BareMod/Bare_Mod.json"
destinationFilename=sys.argv[1]

with open(bareMod, 'r') as file:
    destinationData = json.load(file)



#Import flip Panel
flipPanelFile='../FlipPanel/Malifaux Breachside Gamma - added flip panels.json'
flipPanelIds=["502932","1e8c61","83a171","31e7ff","a1b94b","5bc572","8138b3","572b26","4101c7","febe4d","566809","df38a2","b1137e","045b9e","9332c8","82bf88","c8d8aa","b854ca","d224ab"]
print("flip panel")
importObjects(destinationData,flipPanelFile,flipPanelIds)
#Scheme Panel
schemePanelFile='../schemescript/TS_Save_13298.json'
schemePanelIds=["b1938a","420546","61fe0d","d5e9df","697be6","e2578a","725c42","47995f","914a0a","7e13e8","bb6c9e","0e2d1d","45bdbf"]#last 3 are the scheme deck
print("scheme panel")
importObjects(destinationData,schemePanelFile,schemePanelIds)
#Models
modelsFile='../4EStatCardCreater/TS_Save_13302.json'
modelsIds=["000000","000888","f5da9d","88b910","000839","fb3900","11cdcb","d95ea4","c98d47","64e45c","313d9c"]
print("models")
importObjects(destinationData,modelsFile,modelsIds)
#Tokens
tokensFile='../4EBaseModComponents/TS_Save_13305.json'
tokensIds=["3ea749"]
print("tokens")
importObjects(destinationData,tokensFile,tokensIds)
#Markers
markersFile='../4EBaseModComponents/TS_Save_13306.json'
markersIds=["7abb2f","83ac1c","edf269","fe97e9","898648","7c0835","b469ee","31f5d9","44e232","68a770","10de55"]
print("markers")
importObjects(destinationData,markersFile,markersIds)



with open(destinationFilename, 'w', encoding='utf-8') as f:
    json.dump(destinationData, f, ensure_ascii=False, indent=4)



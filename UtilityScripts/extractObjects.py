import sys
import json

#Script to pull objects from one Mod and inject them into another.  
#The script isn't smart enough to not overlap objects so you should prepare the destination file for the injection
#takes command line arguments for the two files.  Source first then destination.
#Right now the ids to pull are hardcoded.  Probably should be a command line arg too but I was feeling lazy.

originFilename=sys.argv[1]
idsToFetch=["502932","1e8c61","83a171","31e7ff","a1b94b","5bc572","8138b3","572b26","4101c7","febe4d","566809","df38a2","b1137e","045b9e","9332c8","82bf88","c8d8aa","b854ca","d224ab"]
with open(originFilename, 'r') as file:
    originData = json.load(file)


objToExport=[]
for obj in originData["ObjectStates"]:
    if obj["GUID"] in idsToFetch:
        objToExport.append(obj)


destinationFilename=sys.argv[2]

with open(destinationFilename, 'r') as file:
    destinationData = json.load(file)

destinationIdList=[]

for obj in destinationData["ObjectStates"]:
    destinationIdList.append(obj["GUID"])



for obj in objToExport:
    if obj["GUID"] in destinationIdList:
        print(obj["GUID"]+" Exists in destination file")
    else:
        destinationData["ObjectStates"].append(obj)

destinationIdList=[]

for obj in destinationData["ObjectStates"]:
    destinationIdList.append(obj["GUID"])



with open(destinationFilename, 'w', encoding='utf-8') as f:
    json.dump(destinationData, f, ensure_ascii=False, indent=4)
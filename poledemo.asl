state("PoleDemo-Win64-Shipping"){
    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.FirstPoint
    bool isFirstLevelSelected: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x2E8;

    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.Temp_int_variable
    int selectedLevelInteracts: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x37C;

    // World.OwningGameInstance.StoryUMG.CurrentStoryLineData.ChapterID
    int chapterID: 0x3A13160, 0x170, 0x380, 0x4A0;

    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.OtherActor.Name
    long otherActorFName:  0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x1780, 0x18;

    // World.Name
    long worldFName: 0x3A13160, 0x18;
}

startup
{
    // vars.Log = (Action<object>)((output) => print("[Pole ASL] " + output));
    vars.EndTriggers = new List<string> {"TutorialLevelEndingManager", "LevelEndingDoor"};
    vars.STORY_LEVEL = "StoryLevel";
    vars.DYE_DUNES = "PaintDesertLevel";

    settings.Add("split_chapter", true, "Split on chapter complete");
    settings.Add("split_boss", true, "Split on entering boss room");
}

init 
{
    vars.FNamePool = (IntPtr)(modules.First().BaseAddress + 0x38FB4C0);
    vars.GetNameFromFName = (Func<long, string>) ( longKey => {
        int key = (int)(longKey & uint.MaxValue);
        int chunkOffset = key >> 16;
        int nameOffset = (ushort)key;
        IntPtr namePoolChunk = memory.ReadValue<IntPtr>((IntPtr)vars.FNamePool + (chunkOffset+2) * 0x8);
        Int16 nameEntry = game.ReadValue<Int16>((IntPtr)namePoolChunk + 2 * nameOffset);
        int nameLength = nameEntry >> 6;
        return game.ReadString((IntPtr)namePoolChunk + 2 * nameOffset + 2, nameLength);
    });

    old.otherActorName = "";
    old.worldName = "";
}

update
{
    current.otherActorName = vars.GetNameFromFName(current.otherActorFName);
    current.worldName = vars.GetNameFromFName(current.worldFName);
}

start
{
    return current.selectedLevelInteracts >= 2 && 
           old.selectedLevelInteracts < 2 && 
           current.isFirstLevelSelected;
}

split 
{
    if (
        current.chapterID != old.chapterID && 
        current.chapterID == 1000 &&
        current.worldName == vars.STORY_LEVEL 
    ) {
        return true;
    }

    if (current.otherActorName != old.otherActorName) {
        if (vars.EndTriggers.Contains(current.otherActorName) && current.worldName != vars.DYE_DUNES) {
            return settings["split_chapter"];
        }
        if (current.otherActorName == "BossRoomOpener") {
            return settings["split_boss"];
        }
    }
}
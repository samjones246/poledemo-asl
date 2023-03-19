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
    vars.Log = (Action<object>)((output) => print("[Pole ASL] " + output));
    vars.STORY_LEVEL = "StoryLevel";
    vars.LevelNames = new List<string> {
        "TutorialLevel",
        "Desert_SideLevel_2",
        "Desert_SideLevel_3",
    };

    settings.Add("split_chapter", true, "Split on chapter complete");
    settings.Add("split_boss", true, "Split on entering boss room");
}

init 
{
    vars.FNamePool = (IntPtr)(modules.First().BaseAddress + 0x38FB4C0);
    vars.GetNameFromFName = (Func<long, string>) ( longKey => {
        int key = (int)(longKey & uint.MaxValue);
        int partial = (int)(longKey >> 32);
        int chunkOffset = key >> 16;
        int nameOffset = (ushort)key;
        IntPtr namePoolChunk = memory.ReadValue<IntPtr>((IntPtr)vars.FNamePool + (chunkOffset+2) * 0x8);
        Int16 nameEntry = game.ReadValue<Int16>((IntPtr)namePoolChunk + 2 * nameOffset);
        int nameLength = nameEntry >> 6;
        string output = game.ReadString((IntPtr)namePoolChunk + 2 * nameOffset + 2, nameLength);
        return (partial == 0) ? output : output + "_" + partial.ToString();
    });

    vars.EndingTriggered = new MemoryWatcherList
    {
        new MemoryWatcher<bool>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xE0, 0x2A2)) { Name = "TutorialLevel"},
        new MemoryWatcher<bool>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xE8, 0x2A1)) { Name = "Desert_SideLevel_2"},
        new MemoryWatcher<bool>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xF0, 0x2A1)) { Name = "Desert_SideLevel_3"},
    };

    vars.EndingManagerName = new MemoryWatcherList
    {
        new MemoryWatcher<int>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xE0, 0x18)) { Name = "TutorialLevel"},
        new MemoryWatcher<int>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xE8, 0x18)) { Name = "Desert_SideLevel_2"},
        new MemoryWatcher<int>(new DeepPointer(0x3A13160, 0x30, 0xA8, 0xF0, 0x18)) { Name = "Desert_SideLevel_3"},
    };

    var endingManagerNames = new List<int> {0x687F9, 0x67FDD};
    vars.IsEndingManagerName = (Func<int, bool>) (name => endingManagerNames.Contains(name));

    old.otherActorName = "";
    old.worldName = "";
}

update
{
    vars.EndingTriggered.UpdateAll(game);
    vars.EndingManagerName.UpdateAll(game);
    current.endingDoorTouched = false;
    foreach (string level in vars.LevelNames) {
        if (
            vars.IsEndingManagerName(vars.EndingManagerName[level].Current) &&
            vars.IsEndingManagerName(vars.EndingManagerName[level].Old) &&
            vars.EndingTriggered[level].Current
        ) {
            current.endingDoorTouched = true;
            // vars.Log("Ending Door Touched");
            break;
        }
    }
    current.otherActorName = vars.GetNameFromFName(current.otherActorFName);
    current.worldName = vars.GetNameFromFName(current.worldFName);
    // if (current.worldName != old.worldName) {
    //     vars.Log("World: " + current.worldName);
    // }
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

    if (current.endingDoorTouched && !old.endingDoorTouched) {
        return settings["split_chapter"];
    }

    if (current.otherActorName != old.otherActorName) {
        if (current.otherActorName.StartsWith("BossRoomOpener")) {
            return settings["split_boss"];
        }
    }
}
state("PoleDemo-Win64-Shipping"){
    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.FirstPoint
    bool isFirstLevelSelected: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x2E8;

    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.Temp_int_variable
    int selectedLevelInteracts: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x37C;

    // World.OwningGameInstance.StoryUMG.CurrentStoryLineData.ChapterID
    int chapterID: 0x3A13160, 0x170, 0x380, 0x4A0;

    // World.OwningGameInstance.CurrentLevelProgress
    byte currentLevelProgress: 0x3A13160, 0x170, 0x448;
}

init 
{
     vars.inLevel = false;
     vars.levelIndex = 0;
}

startup
{
    // vars.Log = (Action<object>)((output) => print("[Pole ASL] " + output));
    vars.Levels = new int[] {0x0E, 0x10, 0x01};

    settings.Add("split_chapter", true, "Split on chapter complete");
}

update
{
    if (current.currentLevelProgress != old.currentLevelProgress) {
        // vars.Log("CurrentLevelProgress: " + current.currentLevelProgress.ToString());
    }

    if (current.selectedLevelInteracts == 2 && old.selectedLevelInteracts != 2) {
        // vars.Log("InLevel: true");
        vars.inLevel = true;
    }
}

start
{
    if(current.selectedLevelInteracts >= 2 && 
        old.selectedLevelInteracts < 2 && 
        current.isFirstLevelSelected
    ) {
        vars.levelIndex = 1;
        return true;
    }
}

split 
{
    if (
        current.chapterID != old.chapterID && 
        current.chapterID == 1000 &&
        vars.levelIndex == 4
    ) {
        // vars.Log("Final split");
        return true;
    }

    if (
        (current.currentLevelProgress == 14 || current.currentLevelProgress == 16) && 
        current.currentLevelProgress != old.currentLevelProgress &&
        vars.inLevel
    ) {
        // vars.Log("Chapter Split");
        // vars.Log("InLevel: False");
        vars.inLevel = false;
        vars.levelIndex += 1;
        return settings["split_chapter"];
    }
}
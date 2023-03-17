state("PoleDemo-Win64-Shipping"){
    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.PoleStates
    byte poleState: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A0;

    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.FirstPoint
    bool isFirstLevelSelected: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x2E8;

    // World.OwningGameInstance.StoryUMG.CurrentStoryLineData.ChapterID
    int chapterID: 0x3A13160, 0x170, 0x380, 0x4A0;

    // World.OwningGameInstance.CurrentLevelProgress
    byte currentLevelProgress: 0x3A13160, 0x170, 0x448;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[Pole ASL] " + output));
    vars.POLE_DOWN = 0x03;
    vars.POLE_MOVING = 0x07;

    settings.Add("split_chapter", true, "Split on chapter complete");
}

init
{
    old.selectedLevelInteracts = 0;
}

update
{
    if (current.poleState != old.poleState) {
        if (current.poleState == vars.POLE_DOWN) {
            current.selectedLevelInteracts = old.selectedLevelInteracts + 1;
        }
        else if (current.poleState == vars.POLE_MOVING) {
            current.selectedLevelInteracts = 0;
        } else {
            current.selectedLevelInteracts = old.selectedLevelInteracts;
        }
    }

    if (current.currentLevelProgress != old.currentLevelProgress) {
        vars.Log("CurrentLevelProgress: " + current.currentLevelProgress.ToString());
    }
}

start
{
    if(current.selectedLevelInteracts == 2 && 
        old.selectedLevelInteracts == 1 && 
        current.isFirstLevelSelected
    ) {
        current.selectedLevelInteracts = 0;
        return true;
    }
}

split 
{
    if (current.chapterID != old.chapterID && current.chapterID == 1000) {
        return true;
    }

    if (
        (current.currentLevelProgress == 14 || current.currentLevelProgress == 16) && 
        old.currentLevelProgress == 1
    ) {
        return settings["split_chapter"];
    }
}
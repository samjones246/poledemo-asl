state("PoleDemo-Win64-Shipping"){
    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.PoleStates
    int poleState: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A0;

    // World.OwningGameInstance.LocalPlayers[0].PlayerController.Character.HubPointManager.PointWithPoleMan.FirstPoint
    bool isFirstLevelSelected: 0x3A13160, 0x170, 0x38, 0x0, 0x30, 0x280, 0x6A8, 0x280, 0x2E8;

    // World.OwningGameInstance.StoryUMG.CurrentStoryLineData.ChapterID
    int chapterID: 0x3A13160, 0x170, 0x380, 0x4A0;
}

startup
{
    vars.Log = (Action<object>)((output) => print("[Pole ASL] " + output));
    vars.POLE_DOWN = 0x03;
    vars.POLE_MOVING = 0x07;
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
}

start
{
    return current.selectedLevelInteracts == 2 && 
           old.selectedLevelInteracts == 1 && 
           current.isFirstLevelSelected;
}

split {
    if (current.chapterID != old.chapterID && current.chapterID == 1000) {
        return true;
    }
}
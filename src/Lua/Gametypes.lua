G_AddGametype({
    name = "Pizza Time",
    identifier = "PTV3",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_none,
    headerleftcolor = 98,
    headerrightcolor = 51,
    description = "Go head-to-head against your friends! Use items, kill enemies, and be the one that starts Pizza Time in the classic mode you know and love, but better!"
})

G_AddGametype({
    name = "Death Mode",
    identifier = "PTV3DM",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_none,
    headerleftcolor = 163,
    headerrightcolor = 35,
    description = "Pizzaface woke up early and is ready to exact his revenge! Collect clocks to keep him at bay as you battle to be the last one alive in this pizza massacre!"
})
--!strict

export type PlayerData = {
    version: number,
    gold: number,
    level: number,
    xp: number,
    inventory: {[string]: number},
    settings: {
        musicVolume: number,
        sfxVolume: number,
    },
}

return {}

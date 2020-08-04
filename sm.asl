state("PPSSPPWindows64") { } 


startup {
		vars.scanTarget = new SigScanTarget (0, "48 45 52 4F 53 4B 49 4E 5F 49 6E 69 74 53 69 6E 67 6C 65 50 6C 61 79 65 72");
		// search for string, addr for planet loading is offset by 0x100
}


init {
	refreshRate = 1000/30;
	
	var ptr = IntPtr.Zero;

	
	foreach (var page in game.MemoryPages(true)) {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		
		if (ptr == IntPtr.Zero) {
			ptr = scanner.Scan(vars.scanTarget);
		} else {
			break;
		}
	}
	
	//vars.planetLoading = new MemoryWatcher<byte>(ptr + 0x100);
	//vars.pokiSpawn = new MemoryWatcher<int>(ptr + 0xC7A6F0);
	vars.currentPlanet = new MemoryWatcher<int>(ptr + 0x54254);
	
	vars.watchers = new MemoryWatcherList() {
		//vars.planetLoading
		//vars.pokiSpawn
		vars.currentPlanet
	};
}

update {
	// Generic updating before timer control actions
	vars.watchers.UpdateAll(game);
}


start {
	// This is probably fucking trash LOL
		//if (vars.pokiSpawn.Current == 1 && vars.pokiSpawn.Old == 0)
		//return true;
}

split {
	// Splits automatically
	if (vars.currentPlanet.Current != vars.currentPlanet.Old)
		return true;
}


reset {
	// Resets automatically
	
}

isLoading {
	// Load remover
}


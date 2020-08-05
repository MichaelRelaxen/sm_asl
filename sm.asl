state("PPSSPPWindows64") { } 


startup {
		vars.scanTarget = new SigScanTarget (0, "48 45 52 4F 53 4B 49 4E 5F 49 6E 69 74 53 69 6E 67 6C 65 50 6C 61 79 65 72");
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
	
	vars.currentPlanet = new MemoryWatcher<int>(ptr + 0x54254);
	vars.dreamtimeCheck = new MemoryWatcher<int>(ptr+ 0x54264);
	vars.pokiSpawn = new MemoryWatcher<int>(ptr + 0xC7A6F0);
	vars.planetLoading = new MemoryWatcher<byte>(ptr + 0x100);
	
	vars.watchers = new MemoryWatcherList() {
		vars.currentPlanet,
		vars.dreamtimeCheck,
		vars.pokiSpawn,
		vars.planetLoading
	};
}

update {
	vars.watchers.UpdateAll(game);
}


split {
	if (vars.currentPlanet.Current != vars.currentPlanet.Old) {
		return true;
		// Does not work with Dreamtime, is it even the address for planet ID? 
	}
	else if (vars.dreamtimeCheck.Current != vars.dreamtimeCheck.Old) {
		return true;
		// THIS IS NOT A GOOD IDEA LOL
	}
	else if (vars.planetLoading.Current == 1 && vars.planetLoading.Old == 0) {
		return true;
		//THIS IS EVEN WORSE oh NO
	}
}

		

start {
	return vars.pokiSpawn.Current == 1 && vars.pokiSpawn.Old == 0;
}

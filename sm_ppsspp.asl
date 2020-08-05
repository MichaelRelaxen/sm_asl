state("PPSSPPWindows64") { } 


startup {
		vars.scanTarget = new SigScanTarget (0, "48 45 52 4F 53 4B 49 4E 5F 49 6E 69 74 53 69 6E 67 6C 65 50 6C 61 79 65 72");
		
		settings.Add("RemainsSplit", true, "Split on Remains");
		settings.SetToolTip("RemainsSplit", "Toggle this to make the autosplitter split on entering MOO Remains.");
		settings.Add("SplitOtto", true, "Split on Otto entry");
		settings.SetToolTip("SplitOtto", "Toggle this to make the autosplitter split on entering Otto.");
		settings.Add("ChallaxSplit", true, "Split on Challax");
		settings.SetToolTip("ChallaxSplit", "Toggle this to make the autosplitter split on entering Challax");
		settings.Add("IClankSplit", true, "Split after Inside Clank");
		settings.SetToolTip("IClankSplit", "Toggle this to make the autosplitter split on leaving Inside Clank");
		settings.Add("QuodronaSplit", true, "Split on Quodrona");
		settings.SetToolTip("QuodronaSplit", "Toggle this to make the autosplitter split on entering Quodrona");
		settings.Add("AutoReset", true, "Toggle this to auto-reset (NG+)");
		settings.SetToolTip("AutoReset", "Toggle to automatically reset on poki load, intended for NG+ runs");
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
	
	vars.currentPlanet = new MemoryWatcher<int>(ptr + 0x190);
	vars.pokiSpawn = new MemoryWatcher<int>(ptr + 0xC7A6F0);
	vars.ottoEntry = new MemoryWatcher<float>(ptr + 0xBAB4F8);
	vars.ottoDeath = new MemoryWatcher<byte>(ptr + 0x8005C);
	
	vars.watchers = new MemoryWatcherList() {
		vars.currentPlanet,
		vars.pokiSpawn,
		vars.ottoEntry,
		vars.ottoDeath
	};
}

update {
	vars.watchers.UpdateAll(game);
}

/*
split {
		return vars.currentPlanet.Current != vars.currentPlanet.Old;
} 



Todo: Add custom settings for planets like Remains etc
Offset - 0x190
	Main Menu 0x00
	Pokitaru 0x01
	Ryllus 0x02
	Kalidon 0x03
	Metalis 0x04
	Dreamtime 0x05
	MOO 0x06
	Challax 0x07
	Dayni 0x08
	IC 0x09
	Quodrona 0x0A
	Giant Clank Metalis 0x0F
	Giant Clank Challax 0x15
	Remains 0x17
*/
split {
	if (vars.currentPlanet.Current == 2 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
		return true;
		//Ryllus from anywhere
	}
	if (vars.currentPlanet.Current == 3 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
		return true;
		//Kalidon from anywhere
	}
	if (vars.currentPlanet.Current == 4 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
		return true;
		//Metalis from anywhere
	}
	if (vars.currentPlanet.Current == 5 && vars.currentPlanet.Old == 15) {
		return true;
		//Dreamtime from Giant Clank
	}
	if (vars.currentPlanet.Current == 6 && vars.currentPlanet.Old == 5) {
		return true;
		//MOO from dreamtime
	}
	if (settings["ChallaxSplit"]) {
		if (vars.currentPlanet.Current == 7 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
			return true;
		}
		//Challax from anywhere
	}
	if (vars.currentPlanet.Current == 8 && vars.currentPlanet.Old == 7) {
		return true;
		//Dayni from challax transition
	}
	if (vars.currentPlanet.Current == 9 && vars.currentPlanet.Old == 8) {
		return true;
		//Inside clank from Dayni
	}
	if (settings["IClankSplit"]) {
		if (vars.currentPlanet.Current == 8 && vars.currentPlanet.Old == 9) {
			return true;
		}
	}
	if (settings["QuodronaSplit"]) {
		
		if (vars.currentPlanet.Current == 10 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
			return true;
		//Quodrona from anywhere
		}
	}
	if (settings["RemainsSplit"]) {
		if (vars.currentPlanet.Current == 23 && vars.currentPlanet.Current != vars.currentPlanet.Old) {
			return true;
		}
		//Split only on remains if toggled on, from anywhere
	}
	if (vars.currentPlanet.Current == 15 && vars.currentPlanet.Old == 4) {
		return true;
		//Giant Clank 1 from Metalis
	}
	if (vars.currentPlanet.Current == 21 && vars.currentPlanet.Old == 7) {
		return true;
		//Giant clank 2 from Challax
	}
	if (settings["SplitOtto"]) {
		if (vars.currentPlanet.Current == 10) {
			if (vars.ottoEntry.Current == 5000 && vars.ottoEntry.Old <= 0) {
				return true;
		//Otto split
			}
		}
	}
	
}
	

start {
	if (vars.currentPlanet.Current ==  1)
	{
		return vars.pokiSpawn.Current == 1 && vars.pokiSpawn.Old == 0;
	}
}

reset {
	if (vars.currentPlanet.Current == 0) {
		return true;
	}
	if (settings["AutoReset"]) {
		if (vars.currentPlanet.Current ==  1)
	{
		return vars.pokiSpawn.Current == 1 && vars.pokiSpawn.Old == 0;
		}
	}
	
}

run("32-bit");
Stack.getStatistics(voxelCount, mean, min, max, stdDev);
run("Subtract...", "value="+mean+" stack");
run("Divide...", "value="+stdDev+" stack");
run("Enhance Contrast", "saturated=0.35");

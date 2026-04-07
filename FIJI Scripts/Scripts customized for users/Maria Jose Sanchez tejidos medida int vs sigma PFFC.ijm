// Mide Intensidad en ROIs de tegidos usando corrección pseudo flat field correction aplicando diferentes sigma
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 
//
// UNICAMENTE Hay que tener abierta la imagen del unico canal ChIBA1 y los ROI deseados y nombrados en el ROI manager

run("Select None");
roiManager("deselect");
waitForUser("Comprueba que estan los ROI bien en el ROI manager y la unica imagen es adecuada.");
close("\\Others");
//run("Clear Results");
roiManager("deselect");
run("Select None");
valores = newArray(8, 25, 50, 90, 115, 170, 240, 340, 500, 750, 1000, 1250, 1500, 1750, 2000, 2400, 2750, 3000, 3400);
imagen = getImageID();
run("16-bit");
title = getTitle();
title = replace(title, "\\ ", "");
title = replace(title, "\\-", "_");
run("Set Measurements...", "area mean modal integrated median skewness kurtosis display redirect=None decimal=3");

// 0 = sin PFFC
selectImage(imagen);
run("Duplicate...", "title="+title+"_sigma=0_roi");
roiManager("Measure");
close("*sigma*");

for (i = 0; i < valores.length; i++) {
	selectImage(imagen);
	run("Duplicate...", "title="+title+"_sigma="+valores[i]+"_roi");
	run("Pseudo flat field correction", "blurring="+valores[i]+" hide");
	roiManager("Measure");
	close("*sigma*");
}

// 3700 = sin PFFC
selectImage(imagen);
run("Duplicate...", "title="+title+"_sigma=3700_roi");
roiManager("Measure");
close("*sigma*");


close("*");

waitForUser("macro terminado");



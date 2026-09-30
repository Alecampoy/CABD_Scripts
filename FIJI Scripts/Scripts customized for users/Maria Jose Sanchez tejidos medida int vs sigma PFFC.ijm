// Mide Intensidad en ROIs de tegidos usando corrección pseudo flat field correction aplicando diferentes sigma
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 
//
// UNICAMENTE Hay que tener abierta la imagen del unico canal ChIBA1 y los ROI deseados y nombrados en el ROI manager

run("Select None");
roiManager("deselect");
waitForUser("Comprueba que estan los ROI bien en el ROI manager y la unica imagen es adecuada.");
dir = getDirectory("Directorio para guardar los resultados");
close("\\Others");
//run("Clear Results");
roiManager("deselect");
run("Select None");
valores = newArray(8, 25, 50, 90, 115, 170, 240, 340, 500, 750, 1000, 1250, 1500, 1750, 2000, 2400, 2750, 3000, 3400);
imagen_original = getImageID();
title = getTitle();
title = replace(title, "\\ ", "");
title = replace(title, "\\-", "_");
run("Set Measurements...", "area mean modal integrated median skewness kurtosis display redirect=None decimal=3");

// PFFC sin conversion - resulta de la suma de las intensidaddes en la proyección. 
// Creo que es altamente susceptible al grosor de la muestra
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title="+title+"_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi");
	run("Pseudo flat field correction", "blurring="+valores[i]+" hide");
	roiManager("Measure");
	close("*sigma*");
}

selectWindow("Results");
saveAs("Results", Results+condition_title+"_Results.csv");


// PFFC con conversion 16bits sistematica 
// Para ello uso enhance contrast y normalize 0-1 antes de realizar la conversión, para tenerla controlada
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title="+title+"_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi");
	run("Pseudo flat field correction", "blurring="+valores[i]+" hide");
	roiManager("Measure");
	close("*sigma*");
}

// Convoluted Bckg substraction 16 o 32 bits?
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title="+title+"_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi");
	run("Pseudo flat field correction", "blurring="+valores[i]+" hide");
	roiManager("Measure");
	close("*sigma*");
}
close("*");

waitForUser("macro terminado");



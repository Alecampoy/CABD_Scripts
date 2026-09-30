// Mide Intensidad en ROIs de tegidos usando corrección pseudo flat field correction aplicando diferentes sigma
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 
//
// UNICAMENTE Hay que tener abierta la imagen del unico canal ChIBA1 y los ROI deseados y nombrados en el ROI manager

run("Select None");
run("Clear Results");
roiManager("deselect");
waitForUser("Comprueba que estan los ROI bien en el ROI manager y la unica imagen es adecuada.");
dir = getDirectory("Directorio para guardar los resultados");
close("\\Others");
//run("Clear Results");
roiManager("deselect");
run("Select None");
valores = newArray(8, 25, 50, 90, 150, 300, 500, 750, 1000, 1250, 1500, 1750, 2000, 2400, 2750, 3000);
imagen_original = getImageID();
title = getTitle();
title = replace(title, "\\ ", "");
title = replace(title, "\\-", "_");
rename("original");
run("Set Measurements...", "area mean modal integrated median skewness kurtosis display redirect=None decimal=3");

/*
// PFFC sin conversion - resulta de la suma de las intensidaddes en la proyección. 
// Creo que esta medida es altamente susceptible al grosor de la muestra
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title="+title+"_PFFC_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	// run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi"); // No necesita duplicado ya que el plugin genera una imagen nueva
	run("Pseudo Flat Field Correction (2D/3D)", "flatfieldradius="+valores[i]+" force2dfilter=false activechannelonly=false showbackgroundimage=false stackslice=1");
	rename(title+"_PFFC_SUMraw_sigma="+valores[i]+"_roi");
	selectImage(title+"_PFFC_SUMraw_sigma="+valores[i]+"_roi");
	roiManager("Measure");
	close("*sigma*");
}

selectWindow("Results");
saveAs("Results", dir+"PFFC_SUMraw_Results.csv");
run("Clear Results");


// PFFC con conversion 16bits sistematica 
// Para ello uso enhance contrast y normalize 0-1 antes de realizar la conversión, para tenerla controlada por el número de pixeles saturados a 0.35
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title=PFFC_SUM16bits");
run("Enhance Contrast...", "saturated=0.35 normalize");
setOption("ScaleConversions", true);
run("16-bit");
PFFC_SUM16 = getImageID();
run("Duplicate...", "title="+title+"_PFFC_SUM16bits_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(PFFC_SUM16);
	run("Duplicate...", "title="+title+"_PFFC_SUM16bits_sigma="+valores[i]+"_roi");
	run("Pseudo flat field correction", "blurring="+valores[i]+" hide");
	roiManager("Measure");
	close("*sigma*");
}
close("PFFC_SUM16bits");

selectWindow("Results");
saveAs("Results", dir+"PFFC_SUM16bits_Results.csv");
run("Clear Results");
*/

/*
// Convoluted Bckg substraction SIN conversión. Imagen de 32 bits
// Creo que esta medida es también altamente susceptible al grosor de la muestra
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title="+title+"_CBS_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	// run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi");
	// No necesita duplicado ya que el plugin genera una imagen nueva
	run("Convoluted Background Subtraction (2D/3D)", "filtermethod=Gaussian filterradius="+valores[i]+" force2dfiltering=true stackslice=1 processonthefly=false");
	rename(title+"_CBS_SUMraw_sigma="+valores[i]+"_roi");
	selectImage(title+"_CBS_SUMraw_sigma="+valores[i]+"_roi");
	roiManager("Measure");
	close("*sigma*");
}

selectWindow("Results");
saveAs("Results", dir+"CBS_SUMraw_Results.csv");
run("Clear Results");
*/

// Convoluted Bckg substraction con conversion 16bits sistematica 
// Para ello uso enhance contrast y normalize 0-1 antes de realizar la conversión, para tenerla controlada por el número de pixeles saturados a 0.35
// 0 = sin correccion
selectImage(imagen_original);
run("Duplicate...", "title=CBS_SUM16bits");
run("Enhance Contrast...", "saturated=0.35 normalize");
setOption("ScaleConversions", true);
run("16-bit");
CBS_SUM16 = getImageID();
run("Duplicate...", "title="+title+"_CBS_SUM16bits_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(CBS_SUM16);
	run("Duplicate...", "title="+title+"_CBS_SUM16bits_sigma="+valores[i]+"_roi");
	run("Convoluted Background Subtraction", "convolution=Gaussian radius="+valores[i]);
	roiManager("Measure");
	close("*sigma*");
}
close("CBS_SUM16bits");

selectWindow("Results");
saveAs("Results", dir+"CBS_SUM16bits_Results.csv");
run("Clear Results");




close("*");

waitForUser("macro terminado");



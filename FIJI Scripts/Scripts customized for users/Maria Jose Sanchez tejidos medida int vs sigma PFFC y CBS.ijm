// Mide Intensidad en ROIs de tegidos usando corrección pseudo flat field y Convoluted Bacground Substraction aplicando diferentes sigma
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 


run("Close All");
run("Clear Results");
print("\\Clear");
roiManager("reset");
run("Options...", "black");
run("Input/Output...", "file=.tsv copy_column copy_row save_column save_row");

dir = getDirectory("directorio donde estan las imagenes y los ROI");
saving_dir = getDirectory("directorio para guardar los resultados");
filelist = getFileList(dir); // lista con las imagenes dentro de cada carpeta

// valores de medida
valores_pffc = newArray(8, 25, 50, 90, 150, 300, 500, 750, 1000, 1250, 1500, 1750, 2000, 2500);
valores_cbs = newArray(8, 25, 50, 90, 150, 300, 450);
run("Set Measurements...", "area mean modal centroid integrated median skewness kurtosis stack display redirect=None decimal=3");

//__________________________________________

//
// 1- PFFC sobre el plano de enfoque
//
for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen_original = getImageID();
		title = getTitle();
		run("Select None");
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip");
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// Bucle para sigma
		selectImage(imagen_original);
		run("Duplicate...", "title="+title+"_PFFC_planoenfoq_sigma=0_roi"); // 0 = sin correccion
		roiManager("Measure");
		close("*sigma*");
		for (j = 0; j < valores_pffc.length; j++) {
			selectImage(imagen_original);
			run("Duplicate...", "title="+title+"_PFFC_planoenfoq_sigma="+valores[j]+"_roi"); 
			run("Pseudo flat field correction", "blurring="+valores[j]+" hide");
			roiManager("Measure");
			close("*sigma*");
		}
    }
}
selectWindow("Results");
saveAs("Results", saving_dir+title+"PFFC_planoenfoq_Results.csv");
run("Clear Results");

//__________________________________________

//
// 2 - CBS sobre el plano de enfoque
//
for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen_original = getImageID();
		title = getTitle();
		run("Select None");
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip");
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// Bucle para sigma
		selectImage(imagen_original);
		run("Duplicate...", "title="+title+"_CBS_planoenfoq_sigma=0_roi"); // 0 = sin correccion
		roiManager("Measure");
		close("*sigma*");
		for (j = 0; j < valores_pffc.length; m++) {
			selectImage(imagen_original);
			run("Duplicate...", "title="+title+"_CBS_planoenfoq_sigma="+valores[j]+"_roi"); 
			run("Convoluted Background Subtraction", "convolution=Gaussian radius="+valores[j]);
			roiManager("Measure");
			close("*sigma*");
		}
    }
}
selectWindow("Results");
saveAs("Results", saving_dir+title+"CBS_planoenfoq_Results.csv");
run("Clear Results");

//__________________________________________

//
// 3 - PFFC sobre la proyección Suma en 32 bits
// Creo que esta medida es altamente susceptible al grosor de la muestra
//

for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen_original = getImageID();
		title = getTitle();
		run("Select None");
		// Proyección Suma
		run("Z Project...", "projection=[Sum Slices]");
		imagen_sum = getImageID();
		selectImage(imagen_original);
		close();
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip");
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// Bucle para sigma
		selectImage(imagen_sum);
		run("Duplicate...", "title="+title+"_PFFC_SUMraw_sigma=0_roi"); // 0 = sin correccion
		roiManager("Measure");
		close("*sigma*");
		for (j = 0; j < valores_pffc.length; j++) {
			selectImage(imagen_sum);
			// permite 32bits y no necesita duplicado
			run("Pseudo Flat Field Correction (2D/3D)", "flatfieldradius="+valores[j]+" force2dfilter=false activechannelonly=false showbackgroundimage=false stackslice=1"); 
			rename(title+"_PFFC_SUMraw_sigma="+valores[j]+"_roi");
			selectImage(title+"_PFFC_SUMraw_sigma="+valores[j]+"_roi");
			roiManager("Measure");
			close("*sigma*");
		}
    }
}
selectWindow("Results");
saveAs("Results", saving_dir+title+"PFFC_SUMraw_Results.csv");
run("Clear Results");

//__________________________________________

//
// 4 - PFFC sobre la proyección Suma convertida a 16 bits
// Se busca renormalizar la proyeccion suma a 16 bits. No confio demasiado
//

SEGUIR AQUI
for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen_original = getImageID();
		title = getTitle();
		run("Select None");
		// Proyección Suma
		run("Z Project...", "projection=[Sum Slices]");
		imagen_sum = getImageID();
		selectImage(imagen_original);
		close();
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip");
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// Bucle para sigma
		selectImage(imagen_sum);
		run("Duplicate...", "title="+title+"_PFFC_SUMraw_sigma=0_roi"); // 0 = sin correccion
		roiManager("Measure");
		close("*sigma*");
		for (j = 0; j < valores_pffc.length; j++) {
			selectImage(imagen_sum);
			// permite 32bits y no necesita duplicado
			run("Pseudo Flat Field Correction (2D/3D)", "flatfieldradius="+valores[j]+" force2dfilter=false activechannelonly=false showbackgroundimage=false stackslice=1"); 
			rename(title+"_PFFC_SUMraw_sigma="+valores[j]+"_roi");
			selectImage(title+"_PFFC_SUMraw_sigma="+valores[j]+"_roi");
			roiManager("Measure");
			close("*sigma*");
		}
    }
}


// PFFC con conversion 16bits sistematica 
// Para ello uso enhance contrast y normalize 0-1 antes de realizar la conversión, para tenerla controlada por el número de pixeles saturados a 0.25
selectImage(imagen_original);
run("Duplicate...", "title=PFFC_SUM16bits");
run("Enhance Contrast...", "saturated=0.25 normalize");
setOption("ScaleConversions", true);
run("16-bit");
PFFC_SUM16 = getImageID();
// 0 = sin correccion
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
saveAs("Results", saving_dir+title+"PFFC_SUM16bits_Results.csv");
run("Clear Results");


/* queda pendiente de añasaving_dir esta parte si se corrige el problema de que aparece un mensaje cuando se llama desde el macro
// Convoluted Bckg substraction SIN conversión. Imagen de 32 bits
// Creo que esta medida es también altamente susceptible al grosor de la muestra
selectImage(imagen_original);
// 0 = sin correccion
run("Duplicate...", "title="+title+"_CBS_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
for (i = 0; i < valores.length; i++) {
	selectImage(imagen_original);
	// run("Duplicate...", "title="+title+"_SUMraw_sigma="+valores[i]+"_roi");
	// No necesita duplicado ya que el plugin genera una imagen nueva
	run("Convoluted Background Subtraction (2D/3D)", "filtermethod=Gaussian filterradius="+valores[i]+" force2dfiltering=false stackslice=1 processonthefly=false");
	rename(title+"_CBS_SUMraw_sigma="+valores[i]+"_roi");
	selectImage(title+"_CBS_SUMraw_sigma="+valores[i]+"_roi");
	roiManager("Measure");
	close("*sigma*");
}

selectWindow("Results");
saveAs("Results", saving_dir+title+"CBS_SUMraw_Results.csv");
run("Clear Results");
*/



// Convoluted Bckg substraction SIN conversión. Imagen de 32 bits // Para un valor fijo de sigma
// Creo que esta medida es también altamente susceptible al grosor de la muestra
selectImage(imagen_original);
// 0 = sin correccion
run("Duplicate...", "title="+title+"_CBS_SUMraw_sigma=0_roi");
roiManager("Measure");
close("*sigma*");
selectImage(imagen_original);
run("Convoluted Background Subtraction (2D/3D)", "filtermethod=Gaussian filterradius=200 force2dfiltering=false stackslice=1 processonthefly=false");
rename(title+"_CBS_SUMraw_sigma=200_roi");
selectImage(title+"_CBS_SUMraw_sigma=200_roi");
roiManager("Measure");
close("*sigma*");


selectWindow("Results");
saveAs("Results", saving_dir+title+"CBS_SUMraw_Results.csv");
run("Clear Results");


// Convoluted Bckg substraction con conversion 16bits sistematica 
// Para ello uso enhance contrast y normalize 0-1 antes de realizar la conversión, para tenerla controlada por el número de pixeles saturados a 0.35
valores = newArray(8, 25, 50, 75, 100, 200, 400, 750, 1000);
selectImage(imagen_original);
run("Duplicate...", "title=CBS_SUM16bits");
run("Enhance Contrast...", "saturated=0.25 normalize");
setOption("ScaleConversions", true);
run("16-bit");
CBS_SUM16 = getImageID();
// 0 = sin correccion
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
saveAs("Results", saving_dir+title+"CBS_SUM16bits_Results.csv");
run("Clear Results");




close("*");
waitForUser("macro terminado");
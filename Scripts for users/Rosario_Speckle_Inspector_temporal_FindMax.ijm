///////////////////////////////////////////////////////////////////////////////////////////////
/* Author: Ale Campoy
 * Microscopy Unit (CABD)
 * Date: Septiembre.2024
 * User: Marivi & Araceli
 * 	
 * Description: Contaje de drosophila dentro de un roi para cada punto temporal
 * 
 * Input: Stack temporal + Rois indicados
 * 
 * Output: 
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////

// Directorio para los resultado
dir = getDirectory("Selecciona el directorio para los resultados");
title = getTitle();
main_image = getImageID();
prominence = 38 // Valor del parametro de FIND MAXIMA

// Salvamos los 3 ROI iniciales
roiManager("deselect");
roiManager("save", dir+title+"_FM_ROIs.zip");

// Convierte la imagen inicial a ByN
run("Select None");
run("8-bit");
run("Median...", "radius=2 stack"); // FILTRO APLICADO A LA IMAGEN ANTES DE FIND MAXIMA

// Cuenta para cada ROI las particulas que hay y las añade al summary
rois = roiManager("count");
roiManager("deselect");
i = 0;
n = nSlices();
for (i = 0; i < rois; i++) {
	selectImage(main_image);
	roiManager("select", i);
	roi_name = RoiManager.getName(i);
	for (j=1; j<=n; j++) {
		setSlice(j);
		run("Find Maxima...", "prominence="+prominence+" exclude light output=Count");
	}
	// guarda salva y cierra
	selectWindow("Results");
	saveAs("Results", dir+title+"_result of roi "+roi_name+"_FindMax_"+prominence+".tsv");
	run("Clear Results");
}

close("*");
run("Close All");
roiManager("reset");  



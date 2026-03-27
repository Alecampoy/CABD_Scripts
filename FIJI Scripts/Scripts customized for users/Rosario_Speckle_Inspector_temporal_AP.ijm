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

// Salvamos los 3 ROI iniciales
roiManager("deselect");
roiManager("save", dir+title+"_AP_ROIs.zip");

// Convierte la imagen inicial a ByN
run("Select None");
run("8-bit");
run("Gaussian Blur...", "sigma=1 stack");

// Threshold para detectar las moscas
msg = " NO pulsar \"Apply\".\n Usar la barra \"Threshold\"  hasta encontrar un valor adecuado\n Importante apuntar el valor";
run("Threshold...");  	 // open Threshold tool
waitForUser(msg);
getThreshold(lower, upper);
setThreshold(lower, upper);

// Cuenta para cada ROI las particulas que hay y las añade al summary
rois = roiManager("count");
roiManager("deselect");
i = 0;
for (i = 0; i < rois; i++) {
selectImage(main_image);
roiManager("select", i);
roi_name = RoiManager.getName(i);
run("Analyze Particles...", "exclude summarize stack");
// guarda salva y cierra
selectWindow("Summary of "+title);
saveAs("Results", dir+title+"_result of roi "+roi_name+"_Thresh_"+upper+".tsv");
close("Summary");
}

close("*");
run("Close All");
roiManager("reset");
resetThreshold();





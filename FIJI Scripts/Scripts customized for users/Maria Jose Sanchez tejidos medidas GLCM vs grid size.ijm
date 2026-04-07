// Mide metricas de la matriz GLCM en ROIs rectangulares de tegidos
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 
//
// Abrir UNICAMENTE la imagen y los ROI RECTANGULARES que se quieran medir (tantos como quieras).

print("\\Clear");
run("Clear Results");
close("\\Others");

valores = newArray(1, 3, 5, 9, 13, 17, 26, 32, 40, 48);
imagen = getImageID();
title = getTitle();
title = replace(title, "\\ ", "");
title = replace(title, "\\-", "_");

waitForUser("Comprueba que hay UNICAMENTE una imagen con ROIs Rectangulares");
run("Select None");
roiManager("deselect");

// Cabecera medida
print("imagen,","ROI,","Correlation size,","Angular Second Moment,","Contrast,","Correlation,","Inverse Difference Moment,","Entropy");

// loop sobre los ROI
n_rois = roiManager("count");
for (n = 0; n < n_rois; n++){
	selectImage(imagen);
	roiManager("select", n);
	roi_name = call("ij.plugin.frame.RoiManager.getName", n);
	run("Duplicate...", "title=temp_roi");
	roi_temp = getImageID();
	// medidas del ROI
	for (i = 0; i < valores.length; i++) {
		selectImage(roi_temp);
		run("8-bit");
		run("GLCM Texture", "enter="+valores[i]+" select=[0 degrees] angular contrast correlation inverse entropy");
		// metricas
		asm = getResult("Angular Second Moment",0); 
		contrast = getResult("Contrast",0);
		correlation = getResult("Correlation",0);
		idm = getResult("Inverse Difference Moment   ",0); //Extra spaces needed due to source code error
		entropy = getResult("Entropy",0);
		print(title,",",roi_name,",",valores[i],",",asm,",",contrast,",",correlation,",",idm,",",entropy);
		run("Clear Results");		
	}
	close("temp_roi");
}

waitForUser("macro terminado, puedes salvar el resultado");

// Mide metricas de la matriz GLCM en ROIs rectangulares de tegidos
// 
// Usuarios: Alejandra Navarro, lab Maria Jose Sanchez 
//
// Abrir UNICAMENTE la imagen y los ROI RECTANGULARES que se quieran medir (tantos como quieras) que no contengan fondo negro.


run("Close All");
run("Clear Results");
print("\\Clear");
roiManager("reset");
run("Options...", "black");
run("Input/Output...", "file=.tsv copy_column copy_row save_column save_row");


run("Select None");

dir = getDirectory("directorio donde estan las imagenes y los ROI");
saving_dir = getDirectory("directorio para guardar los resultados");


// Cabecera medida
print("imagen,","ROI,","Correlation size,","Angular Second Moment,","Contrast,","Correlation,","Inverse Difference Moment,","Entropy");
valores = newArray(1, 3, 5, 9, 13, 17, 26, 32, 40, 48); 

filelist = getFileList(dir); // lista con las imagenes dentro de cada carpeta
for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen = getImageID();
		title = getTitle();
		run("Select None");
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip"));
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// loop sobre los ROI
		n_rois = roiManager("count");
		for (n = 0; n < n_rois; n++){
			selectImage(imagen);
			roiManager("select", n);
			roi_name = call("ij.plugin.frame.RoiManager.getName", n);
			run("Duplicate...", "title=temp_roi");
			//run("Enhance Contrast...", "saturated=0.8 normalize");
			roi_temp = getImageID();
			//saveAs("Tiff", dir+title+"_ROI_"+roi_name+"_EnhCont.tif");
			// medidas del ROI
			for (i = 0; i < valores.length; i++) {
				selectImage(roi_temp);
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
			selectImage(roi_temp);
			close();
		}
    }
}

selectWindow("Log");
saveAs("Text", dir+"GLCM_Results.csv");
print("macro terminado");

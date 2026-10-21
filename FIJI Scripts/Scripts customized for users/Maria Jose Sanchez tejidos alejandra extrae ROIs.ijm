// Extrae los ROI en imagenes
//
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

print("macro ejecutandose, no se muestran imagenes");
setBatchMode(true);
filelist = getFileList(dir); // lista con las imagenes dentro de cada carpeta
for (i = 0; i < lengthOf(filelist); i++) {
	run("Collect Garbage");
    if (endsWith(filelist[i], ".tif")) { 
        open(dir + File.separator + filelist[i]);
        imagen = getImageID();
		title = getTitle();
		run("Remove Overlay");
		run("Select None");
		// carga ROIs
		roi_zip = dir + File.separator + replace(filelist[i], ".tif", ".zip");
		roiManager("Open", roi_zip);
		roiManager("deselect");
		// loop sobre los ROI
		n_rois = roiManager("count");
		for (n = 0; n < n_rois; n++){
			selectImage(imagen);
			roiManager("select", n);
			roi_name = call("ij.plugin.frame.RoiManager.getName", n);
			run("Duplicate...", "title=temp_roi");
			roi_temp = getImageID();
			saveAs("Tiff", saving_dir+title+"_ROI_"+roi_name+".tif");
			selectImage(roi_temp);
			close();
		}
		selectImage(imagen);
		// Proyección Suma
		run("Z Project...", "projection=[Sum Slices]");
		// Normalizacion pre conversion a 16bits
		run("Enhance Contrast...", "saturated=0.25 normalize");
		setOption("ScaleConversions", true);
		run("16-bit");
		imagen_sum = getImageID();
		// loop sobre los ROI
		for (n = 0; n < n_rois; n++){
			selectImage(imagen_sum);
			roiManager("select", n);
			roi_name = call("ij.plugin.frame.RoiManager.getName", n);
			run("Duplicate...", "title=temp_roi");
			roi_temp = getImageID();
			saveAs("Tiff", saving_dir+title+"_ROI_"+roi_name+"_SUMproj.tif");
			selectImage(roi_temp);
			close();
		}
		roiManager("reset");
		close("*");
    }
}
setBatchMode(false);
print("macro terminado");

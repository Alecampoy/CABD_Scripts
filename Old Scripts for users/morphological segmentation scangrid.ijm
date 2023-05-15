// Scans for the best parameters for the method morphological segmentation

run("Close All");
open();

original = getTitle();
dir = File.directory;
run("Close All");
	
for (i = 0; i < 15; i++) {
	for (j = 0; j < 25; j++) {

	open(dir+original);
	enproceso = getImageID();

	
	run("Morphological Segmentation");
selectWindow("Morphological Segmentation");
wait(500);
//setTool("point");
call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "object");
wait(500);
call("inra.ijpb.plugins.MorphologicalSegmentation.setGradientRadius", i);
call("inra.ijpb.plugins.MorphologicalSegmentation.setGradientType", "Morphological");
call("inra.ijpb.plugins.MorphologicalSegmentation.segment", j, "calculateDams=true", "connectivity=4");
wait(1800);
call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Overlaid dams");
wait(500);
call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
wait(500);

	resultado = getImageID();
	rename("radiusxy="+i+" noise="+j);

	carpeta = createFolder(dir, "resultados de la prueba");
	saveAs("Tiff", carpeta+"radiusxy="+i+" noise="+j+".tiff");
	run("Close All");


	
	
}
}


function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		exit("Unable to create the folder");
	}
	return mydir;
}
	


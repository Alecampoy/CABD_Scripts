dir = getDirectory("Choose a Directory to save all images");
total = nImages;

for (i=0;i<total;i++) {
        selectImage(i+1);
        title = getTitle;
        //run("Grays");
        //c0 = title.contains('C=0'); in case we want just a channel
		//if(c0 == "true") {
			saveAs("tiff", dir+title);
			print("Imagen "+i+1+" de "+total);
			print(title);
			//}
}
run("Close All");
run("Collect Garbage");

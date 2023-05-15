// Demonstates how to use the Roi.getFeretPoints()
// function added in ImageJ 1.52m.
// Roi.getFeretPoints(x,y) macro function, which creates new x and y arrays with the end points 
// of the MaxFeret in array elements [0], [1] and MinFeret in [2], [3]. 

  Roi.getFeretPoints(x,y);
  Overlay.drawLine(x[0], y[0], x[1], y[1]);
  Overlay.show();
  Overlay.drawLine(x[2], y[2], x[3], y[3]);
  Overlay.show();

// Use with Makeline to create a line and measure its angle with the horizontal 
makeLine(x1, y1, x2, y2);


// Another way of drawing the feret using the result

	//run("Properties...", "pixel_width=1 pixel_height=1 voxel_depth=1.0000");
	List.setMeasurements;
	x1 = List.getValue("FeretX")*pw;
	y1 = List.getValue("FeretY")*pw;
	length = List.getValue("Feret");
	degrees = List.getValue("FeretAngle");
	if (degrees>90){degrees -= 180;}
	angle = degrees*PI/180;
	x2 = x1 + cos(angle)*length;
	y2 = y1 - sin(angle)*length;
	setForegroundColor(255, 0, 0);  // draw in red
	drawLine(x1/pw, y1/pw, x2/pw, y2/pw); // functions needs arguments in pixels
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class CogDisplayView extends Ui.DataField {

	// Load user settings (wheel size, number of teeth, etc...)
    var nChainRings = Application.getApp().getProperty("chainRingCount");
	var wheelCircumference = Application.getApp().getProperty("wheelCircumference")/1000.0;
	var chainRings = [Application.getApp().getProperty("chainRing1"), 
						Application.getApp().getProperty("chainRing2"),
						Application.getApp().getProperty("chainRing3")];
	var cogs = [Application.getApp().getProperty("cog1"), 
						Application.getApp().getProperty("cog2"), 
						Application.getApp().getProperty("cog3"), 
						Application.getApp().getProperty("cog4"), 
						Application.getApp().getProperty("cog5"), 
						Application.getApp().getProperty("cog6"), 
						Application.getApp().getProperty("cog7"), 
						Application.getApp().getProperty("cog8"), 
						Application.getApp().getProperty("cog9"), 
						Application.getApp().getProperty("cog10"), 
						Application.getApp().getProperty("cog11")];
	
	var ringRatios = new [nChainRings];	
						
						
	// Initialize variables
	var wheelRotSpeed = 0.0;  // wheel speed in rpm					
	var measuredRatio = 0.0;  // Ratio computed from cadence and speed	
	var developmentM  = 0.0;  // meters of development				
	var valid = false;
	
	hidden var ratioField = null;
	hidden var developmentField = null;
	

    function initialize() {
    	// Create an array of [nChainRings, 11]
    	for (var i = 0; i<nChainRings; i++){
    		ringRatios[i] = new [11];
		}
	    for (var i = 0; i<nChainRings; i++){
	    	for (var j = 0; j<11; j++){
				ringRatios[i][j] = 1.0*chainRings[i]/cogs[j];
	    	}
    	}
    	
//    	System.println(cogs);
//    	for (var i = 0; i<nChainRings; i++){
//    		System.println(chainRings[i] + ": "+ringRatios[i]);
//    	}
    	
        DataField.initialize();
        
        ratioField = createField("gearRatio",
           0, 
           FitContributor.DATA_TYPE_FLOAT,
           { :units=>"one" });
           
                   
        developmentField = createField("metersOfDevelopment",
           1, 
           FitContributor.DATA_TYPE_FLOAT, 
           { :units=>"m" });
           
        ratioField.setData(0.0);
        developmentField.setData(0.0);

    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {

    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
//        System.println("compute()");
//    	System.println("  cad="+info.currentCadence + " rpm");
//    	System.println("  spd="+info.currentSpeed * 2.2 + " mph");
    	
		if (info.currentCadence != null && info.currentSpeed != null 
			&& info.currentSpeed != 0.0 && info.currentCadence != 0  && info.currentCadence < 500)
			{
				wheelRotSpeed = info.currentSpeed / wheelCircumference;
				developmentM  = info.currentSpeed / (info.currentCadence/60.0);
				measuredRatio =  developmentM / wheelCircumference;
//				
//				System.println("  whlspd="+wheelRotSpeed + " r/s");
//    			System.println("  ratio ="+measuredRatio);
//    			System.println("  devel ="+developmentM + " m");
    			

				ratioField.setData(measuredRatio);
				developmentField.setData(developmentM);
				valid = true;
				
			} else {
				valid = false;
			}

	    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {

    	
        var bgColor = getBackgroundColor();
        var fgColor = Graphics.COLOR_WHITE;

        if (bgColor == Graphics.COLOR_WHITE) {
            fgColor = Graphics.COLOR_BLACK;
        }

        dc.setColor(fgColor, bgColor);
        dc.clear();
        dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
        
        var padding = 15;
		var x1 = padding;
		var w = dc.getWidth()-padding*2;
		var h  = 12;
		var small = ringRatios[0][0];
		var large = ringRatios[nChainRings-1][10];
		var range = large-small;
		
		    	
    	dc.setColor(Gfx.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		var x = (measuredRatio - small)/range * w + x1;
		if ( x<padding )  { x = padding;}
		if ( x>padding+w-1 ){ x = padding+w-1; }
		dc.setPenWidth(3);
		dc.drawLine(x, padding, x, padding+h);
		dc.setPenWidth(1);
		dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
		
		
		dc.drawLine(x1, padding, x1+w, padding);
		dc.drawLine(x1, padding+h, x1+w, padding+h);
		for (var i = 0; i<nChainRings; i++){
	    	for (var j = 0; j<11; j++){
	    		var r = ringRatios[i][j];
	    		var x = (r - small)/range * w + x1;
	    		if ( x<padding )  { x = padding; }
	    		if ( x>padding+w-1 ){ x = padding+w-1; }
	    		dc.drawLine(x, padding+i*(h/nChainRings), x, padding+(i+1)*(h/nChainRings));
	    	}
    	}

		if(valid){
			dc.drawText(dc.getWidth()/2d, dc.getHeight()/2, 
			   Graphics.FONT_MEDIUM, 
			   measuredRatio.format("%3.1f"), 
			   Graphics.TEXT_JUSTIFY_CENTER);
		}


    }

}
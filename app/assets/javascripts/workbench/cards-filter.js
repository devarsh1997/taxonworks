var carrouselData = function (sec, rows, columns) {

	// sec = Name of data section, this is for identify div.
	// rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls
	// columns = This is for the number of rows to be displayed
	
		this.childs = 0,
		this.start = 1,
		this.maxRow = 0,
		this.maxColumn = 1,
		this.nro = 1,
		this.sectionTag = "",
		this.filters = {};
		this.maxRow = rows;
		this.sectionTag = sec;
		this.resetChildsCount();
		if(this.maxRow >= this.childs) {
			this.navigation(false);
		}

		if(columns >= 1) {
			$('.data_section[data-section="' + this.sectionTag + '"]').css("max-width",(250*columns) + 'px');
		}
		else {
			$('.data_section[data-section="' + this.sectionTag + '"]').css("max-width", 'auto');
		}
	}

	carrouselData.prototype.addFilter = function (nameFilter) {
		this.filters[nameFilter] = false;
	}	

	carrouselData.prototype.checkChildFilter = function(childTag) {
		var find = 0;
		var isTrue = 0;
		for (var key in this.filters) {
			if(this.filters[key] == true) {
				find++;
				if ($(childTag).attr(key)) {
					isTrue++;
				}
		    }	
		}
		if(isTrue == find) {
			return true;
		}
		else {
			return false;
		}		
	}

	carrouselData.prototype.resetChildsCount = function() {
	  	this.childs = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container ').length;
	}

	carrouselData.prototype.showEmptyLabel = function(isTrue) {
		if(isTrue) {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').hide(250);
		}
		else {
			$('[data-section="' + this.sectionTag + '"] div[data-attribute="empty"]').show(250);
		}
	}

	carrouselData.prototype.changeFilter = function(filterTag)	{
		this.filters[filterTag] = !this.filters[filterTag];
		this.filterChilds();
	}	

	carrouselData.prototype.setFilterStatus = function(filterTag, value)	{
		this.filters[filterTag] = value;
		this.filterChilds();
	}	

	carrouselData.prototype.filterChilds = function() {
		var
			find = 0;
		if(this.maxRow > this.childs) {
			this.maxRow = this.childs;
		}

		for (i = 1; i <= this.maxRow; i++) {
			child = $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ (i) +')');
			if(this.checkChildFilter(child.children().children(".status"))) {
				child.show(250);
				find++;
			}
			else {
				child.hide(250);
			}
		}
		this.showEmptyLabel(find > 0);
	}	

	carrouselData.prototype.navigation = function(value) {
		if(value) {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","show");
		}
		else {
			$('.data_section[data-section="'+ this.sectionTag +'"] div.data-controls').css("display","none");
		}
	}


	carrouselData.prototype.loadingUp = function() {
    	var
    	  rows = this.maxRow,
    	  posNro = this.nro,
    	  tag = this.sectionTag;

	    if(this.nro > this.start) {
	        $('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows-1) +')').hide(100, function() {
	  	        $('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro-1) +')').show(150)
	        });      
	        if(this.nro > this.start) {
	        	this.nro--;
	      	}        
	    }  
	} 

    carrouselData.prototype.loadingDown = function() {
    	var
    	  rows = this.maxRow,
    	  posNro = this.nro,
    	  tag = this.sectionTag;

	    if((this.nro+this.maxRow) <= this.childs) {
	        $('.data_section[data-section="' + this.sectionTag + '"] > .cards-section > .card-container:nth-child('+ posNro +')' ).hide(100, function() {
	        	
	        	$('.data_section[data-section="' + tag + '"] > .cards-section > .card-container:nth-child('+ (posNro+rows) +')' ).show(150)

	        });   
	        if(this.nro < this.childs) {
	        	this.nro++;
	      	}          
    	} 
  	}	 
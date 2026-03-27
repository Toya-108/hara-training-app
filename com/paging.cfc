component {
	public function getPageSet(page,data_length,MaxRows){
		result = {}
		if(page == ""){
			page_no = 1;
			before  = 0;
			after   = 2;
		}else{
			page_no = page;
			before  = page - 1;
			after   = page + 1;
		}

		start_row   = (MaxRows * (page_no - 1)) + 1;
		end_row     = (MaxRows * page_no);
		buffer		= data_length / MaxRows;
		last_page   = Ceiling(buffer);

		op_str = page_no - 4;
		op_end = page_no + 5
	    
		if(op_end > last_page){
			op_end = last_page;
			op_str = last_page - 9;
		}
		if(op_str < 1){
			op_str = 1;
		}
		if(op_end < last_page){
			if(last_page > 10 and op_end < 11){
				op_end = 10;
			}else if(last_page <= 10){
				op_end = last_page;
			}
		}

		counter_width = 280 + (40 * ((op_end - op_str) + 1));
	 
		result["op_end"]        = op_end;
		result["op_str"]        = op_str;
		result["page_no"]       = page_no;
		result["s_page"]        = start_row;
		result["e_page"]        = end_row;
		result["last_page"]     = last_page;
		result["before"]        = before;
		result["after"]         = after;
		result["counter_width"] = counter_width;
		return result;
	}


	public function setPage(page,data_length,MaxRows){
		// prev_page = page - 1;
		// new_page  = page;
		// if(prev_page * MaxRows >= data_length){
		//   new_page = prev_page;
		// }
		//データがないページを指定された場合用の処理
		prev_page = page - 1;
		new_page  = page;
		while(prev_page * MaxRows >= data_length){
			new_page = prev_page;
			prev_page = prev_page - 1;
		}

		//ここまで
		pd = getPageSet(new_page,data_length,MaxRows);
		result = {}
		div = "";
		div = div & '<div style="font-size:10px;" align="right">';
		div = div & '<ul id="pageNav1" width="' & pd.counter_width & '">';
		div = div & '<li><a onclick="changePage(1)"><<</a></li>';
		if(pd.page_no == 1){
			div = div & '<li>&nbsp;</li>';
		} else {
			div = div & '<li><a onclick="changePage(' & pd.before & ')"><</a></li>';
		}
		for(Counter=pd.op_str;Counter<=pd.op_end;Counter++){
			div = div & '<li>';
			if(pd.page_no is Counter){
				div = div & '<li><span>' & Counter & '</span></li>';
			} else {
				div = div & '<a onclick="changePage(' & Counter & ')">' & Counter & '</a>';
			}
			div = div & '</li>';
		}
		if(pd.page_no IS pd.op_end){
			div = div & '<li>&nbsp;</li>';
		} else {
			div = div & '<li><a onclick="changePage(' & pd.after & ')">></a></li>';
		}

		div = div & '<li><a onclick="changePage(' & pd.last_page & ')">>></a></li>';
		div = div & '</ul>';
		div = div & '</div>';
		result["div"] = div;
		result["s_page"] = pd.s_page;
		result["e_page"] = pd.e_page;
		return result;
	}
}


  





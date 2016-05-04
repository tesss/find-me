using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Lang as Lang;
using _;

module Data {
	class Batches {
		var list;
		
		function initialize(_list){
			if(_list == null){
				list = new List();
			}
			else {
				list = _list;
			}
		}
		
		function sort(sortBy){
			var newList = list.sort(method(:batchComparer));
			var batch = newList.first;
			while(batch != null){
				batch.value.locations = batch.value.locations.sort(sortBy);
				batch = batch.getNext();
			}
			return new Batches(newList);
		}
		
		function delete(batch){
			batch.locations.list.clear();
			list.remove(batch);
		}
		
		function batchComparer(a, b){
			return b.date.compare(a.date);
		}
		
		function toString(){ // optimize size, filter input for separators
			var str = "";
			var batch = list.first;
			while(batch != null){
				str = str + Lang.format("[$1$,$2$,$3$]\n", [batch.value.name, batch.value.date.value(), batch.value.locations.toString()]);
				batch = batch.getNext();
			}
			return str;
		}
		
		static function fromString(str){
			var list = new List();
			var l = str.length();
			var begin = 0;
			var opened = 0;
			for(var i = 0; i < l; i++){
				var s = str.substring(i, 1);
				if(s == "["){
					if(opened == 0){
						begin = i;
					}
					opened++;
				} else if (s == "]"){
					opened--;
					if(opened == 0){
						list.add(str.substring(begin, i));
					}
				}
			}
			_.p(list.toArray());
		}
	}
}
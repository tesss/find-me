using Toybox.System;
using Toybox.Lang as Lang;
using _;

module Data {
	class List {
		var first;
		var last;
		
		function add(value){
			if(first == null){
				first = new ListItem(value, null);
				last = first;
			} else {
				last.setNext(new ListItem(value, null));
				last = last.getNext();
			}
		}

		function remove(value){
			var isPredicate = value instanceof Lang.Method;
			var item = first;
			while(item != null){
				if(item.value == value){
					if(item == first){
						first = item.getNext();
					}
					if(item == last){
						last.setNext(null);
					}
					if(isPredicate){
						item = item.getNext();
					} else {
						return true;
					}
				} else {
					item = item.getNext();
				}
			}
			return false;
		}
		
		function clear(){
			first = null;
			last = null;
		}

		function get(index){
			item = first;
			for(var i = 0; i < index; i++){
				if(item == null){
					Sys.error("Index out of bounds");
				}
				item = item.getNext();
			}
			return item;
		}
		
		function set(index, value){
			var item = get(index);
			if(item == null){
				Sys.error("Index out of bounds");
			}
			item.value = value;
		}
		
		function find(predicate){
			var item = first;
			while(item != null){
				if(predicate.invoke(item.value)){
					return item.value;
				}
				item = item.getNext();
			}
			return null;
		}
		
		function size(){
			var item = first;
			var size = 0;
			while(item != null){
				size++;
				item = item.getNext();
			}
			return size;
		}
		
		function sort(comparer){
			return fromArray(ArrayExt.sort(toArray(), comparer));
		}
		
		function filter(predicate){
			var result = new List();
			var item = first;
			while(item != null){
				if(predicate.invoke(item.value)){
					result.add(item.value);
				}
				item = item.getNext();
			}
			return result;
		}
		
		function each(method){
			var item = first;
			while(item != null){
				method.invoke(item.value);
				item = item.getNext();
			}
		}
		
		function toArray(){
			var size = size();
			var array = new[size];
			var item = first;
			for(var i = 0; i < size; i++){
				array[i] = item.value;
				item = item.getNext();
			}
			return array;
		}
		
		static function fromArray(array){
			var list = new List();
			if(array != null){
				for(var i = 0; i < array.size(); i++){
					list.add(array[i]);
				}
			}
			return list;
		}
	}
}
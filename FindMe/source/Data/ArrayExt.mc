using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using _;

module Data
{
	class ArrayExt {
		static function each(array, method){
			for(var i = 0; i < array.size(); i++){
				method.invoke(array[i]);
			}
		}
		
		static function sort(array, comparer){
			if(array.size() <= 1){
				return array;
			}
			var result = new[array.size()];
			for(var i = 0; i < array.size(); i++){
				result[i] = array[i];
			}
			quickSortRec(result, 0, result.size() - 1, comparer);
			return result;
		}
		
		static hidden function quickSortRec(array, left, right, comparer){
			var i = partition(array, left, right, comparer);
			if(left < i - 1){
				quickSortRec(array, left, i - 1, comparer);
			}
			if(i < right){
				quickSortRec(array, i, right, comparer);
			}
		}
		
		static hidden function partition(array, left, right, comparer){
			var pivot = array[(left + right)/2];
			while(left <= right){
				while(comparer.invoke(array[left], pivot) < 0){
					left++;
				}
				while(comparer.invoke(array[right], pivot) > 0){
					right--;
				}
				if(left <= right){
					swap(array, left, right);
					left++;
					right--;
				}
			}
			return left;
		}
		
		static function swap(array, i, j){
			var temp = array[i];
			array[i] = array[j];
			array[j] = temp;
		}
		
		static function insertIndex(array, value, comparer){
			var index = 0;
		    var lower = 0;
		    var upper = array.size() - 1;
		    var cur = 0;
			while (lower <= upper){
			    var curIn = (lower + upper ) / 2;
		        if(comparer.invoke(array[curIn], value) < 0){
		            lower = cur + 1;
		        }
		        else if(comparer.invoke(array[curIn], value) > 0){
		            upper = cur - 1;
		        }
		        else if (array[curIn] == value){
		            break;
		        }
			}
			if(comparer.invoke(array[curIn], value) <= 0){
			    index = curIn + 1;
			}
			else{
				index = curIn;
			}
			return index;
		}
		
		static function insert(array, value, comparer){
			var index = insertIndex(array, value, comparer);
			return insertAt(array, value, index);
		}

		static function insertAt(array, value, index){
			var result = new[array.size() + 1];
			for(var i = array.size(); i > index; i--){
		        result[i] = array[i-1];
		    }
		    result[index] = value;
		    for(var i = index-1; i >= 0; i--){
		    	result[i] = array[i];
		    }
		    return result;
		}
		
		static function removeAt(array, index){
			var result = new[array.size() - 1];
			for(var i = 0; i < index; i++){
				result[i] = array[i];
			}
			for(var i = index; i < result.size(); i++){
				result[i] = array[i + 1];
			}
			return result;
		}
		
		static function indexOf(array, value, comparer){
			var minIndex = 0;
		    var maxIndex = array.size() - 1;
		    var currentIndex;
		    var currentElement;
		 
		    while (minIndex <= maxIndex) {
		        currentIndex = (minIndex + maxIndex) / 2 | 0;
		        currentElement = array[currentIndex];
		 
		        if (comparer.invoke(currentElement, searchElement) < 0) {
		            minIndex = currentIndex + 1;
		        }
		        else if (comparer.invoke(currentElement, searchElement) > 0) {
		            maxIndex = currentIndex - 1;
		        }
		        else {
		            return currentIndex;
		        }
		    }
		 
		    return null;
		}
		
		static function union(array1, array2){
			var result = new[array1.size() + array2.size()];
			for(var i = 0; i < array1.size(); i++){
				result[i] = array1[i];
			}
			for(var i = 0; i < array2.size(); i++){
				result[array1.size() + i] = array2[i];
			}
			return result;
		}
		
		static function sortByIndex(array, indexes, getter){
			var result = new[indexes.size()];
			for(var i = 0; i < indexes.size(); i++){
				result[i] = array[getter.invoke(indexes[i])];
			}
			return result;
		}
	}
}
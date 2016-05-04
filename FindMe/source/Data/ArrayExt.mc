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
		
		static hidden function swap(array, i, j){
			var temp = array[i];
			array[i] = array[j];
			array[j] = temp;
		}
	}
}
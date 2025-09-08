// BubbleSortLib.sol
// Bubble Sort Library

/*
ZZZZZ IIIII N   N  GGGG IIIII EEEEE  SSSS TTTTT  SSSS N   N   A   IIIII L      9999  8888
   Z    I   NN  N G       I   E     S       T   S     NN  N  A A    I   L     9   9 8   8
  Z     I   N N N G  GG   I   EEE    SSS    T    SSS  N N N AAAAA   I   L      9999  888
 Z      I   N  NN G   G   I   E         S   T       S N  NN A   A   I   L         9 8   8
ZZZZZ IIIII N   N  GGGG IIIII EEEEE SSSS    T   SSSS  N   N A   A IIIII LLLLL  999   8888
*/

pragma solidity ^0.8.0;

library BubbleSortLib {
    /**
     * @dev Sorts an array of unsigned integers using the Bubble Sort algorithm.
     * This is an in-place sort with O(n^2) time complexity in the worst case.
     * Optimized to stop early if no swaps occur in a pass.
     * @param arr The array to sort (modified in-place).
     * @return The sorted array (same as input reference).
     */
    function bubbleSort(uint[] memory arr) internal pure returns (uint[] memory) {
        uint n = arr.length;
        bool swapped;
        for (uint i = 0; i < n - 1; i++) {
            swapped = false;
            for (uint j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
                    swapped = true;
                }
            }
            if (!swapped) break;
        }
        return arr;
    }
}
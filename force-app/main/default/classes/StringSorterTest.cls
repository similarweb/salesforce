/**
 * Created by Alon.Shalev on 10/12/2023.
 */

@isTest
private class StringSorterTest {
    @isTest static void testStringSorter() {
        StringSorter sorter = new StringSorter();

        List<String> inputStrings = new List<String> {
                'apple',
                '10,000 bananas',
                '5 oranges',
                'grapes',
                '2,000 cherries'
        };

        List<String> expectedStrings = new List<String> {
                '5 oranges',
                '2,000 cherries',
                '10,000 bananas',
                'apple',
                'grapes'
        };

        List<String> resultStrings = sorter.customSort(inputStrings);

        System.assertEquals(expectedStrings, resultStrings, 'The strings are not sorted as expected.');
    }
}
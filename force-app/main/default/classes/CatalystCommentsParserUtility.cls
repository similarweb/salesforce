public with sharing class CatalystCommentsParserUtility {
    @InvocableMethod(label = 'Parse Task Comments' description = 'Parses Comments of Tasks and returns Subtypes')
    public static List<String> parseTaskComments(List<String> taskIds) {
        List<String> parsedResults = new List<String>();
        List<Task> tasks = [SELECT Id, Description FROM Task WHERE Id IN :taskIds];

        for (Task t : tasks) {
            String parsed = parseComment(t.Description);
            parsedResults.add(parsed);
        }
        return parsedResults;
    }

    public static String parseComment(String comment) {
        if (String.isBlank(comment)) {
            return null;
        }
        String marker = 'Categories: ';
        Integer idx = comment.indexOf(marker);
        if (idx == -1) {
            return null;
        }

        Pattern p = Pattern.compile('Categories:\\s*([^\\n,]+)');
        Matcher m = p.matcher(comment);

        String subType;
        if (m.find()) {
            subType = m.group(1).trim();
        }
        return subType;
    }
}
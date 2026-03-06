public class PicklistValue {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    public PicklistValue(String label, String value){
        this.label = label;
        this.value = value;
    }
}
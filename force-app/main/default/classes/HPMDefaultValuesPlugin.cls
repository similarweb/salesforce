global class HPMDefaultValuesPlugin implements zqu.PaymentPageController.IHostedPageLitePlugin {
    global Map < String, String > getAdditionalParameters(String paymentMethodType) {
        Map < String, String > defaultValues = new Map < String, String >();
        // Default client parameters
        if (System.currentPageReference().getParameters().containsKey('field_accountId'))
            defaultValues.put('field_accountId', System.currentPageReference().getParameters().get('field_accountId'));
        defaultValues.put('retainValues', 'true');
        
        return defaultValues;
    }
}
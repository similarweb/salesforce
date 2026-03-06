public with sharing class BaseProductSettingController {

    static ZQuoteService service;

    static {
        if (Test.isRunningTest()) {
            service = (ZQuoteService)MockUtil.obtainMockProvider(ZQuoteService.class);
        } else {
            service = new ZQuoteService();
        }
    }
    
    @AuraEnabled
    public static Response retreiveBaseProductContractValues() {
        Response response;
        try {
            response = new Response(service.retreiveBaseProductContractValues());
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    /*

    @AuraEnabled
    public static Response addBaseProductContractValues(String valuesListRaw) {
        Response response;
        try {
            service.addBaseProductContractValues(valuesListRaw);
            response = new Response(true);
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response editBaseProductContractValues(String value, String label) {
        Response response;
        try {
            service.editBaseProductContractValues(value,label);
            response = new Response(true);
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response deleteBaseProductContractValues(String value) {
        Response response;
        try {
            service.deleteBaseProductContractValues(value);
            response = new Response(true);
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    } */

    @AuraEnabled
    public static Response retreiveBaseProductPicklistValues() {
        Response response;
        try {
            response = new Response(service.retreiveBaseProductPicklistValues());
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response addBaseProductPicklistValues(String fullNameListRaw) {
        Response response;
        try {
            String errors = service.addBaseProductPicklistValues(fullNameListRaw);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response deleteBaseProductPicklistValues(String fullNameToDelete) {
        Response response;
        try {
            String errors = service.deleteBaseProductPicklistValues(fullNameToDelete);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response editBaseProductPicklistValues(String fullName, String label) {
        Response response;
        try {
            String errors = service.editBaseProductPicklistValues(fullName,label);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response retreiveWorldListPicklistValuesForDependentValue(String controllingFieldValue) {
        Response response;
        try {
            response = new Response(service.retreiveWorldListPicklistValuesForDependentValue(controllingFieldValue));   
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response addWorldListPicklistValue(String fullNameListRaw) {
        Response response;
        try {
            String errors = service.addWorldListPicklistValue(fullNameListRaw);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response addDependencyWorldListPicklistValue(String controllingFieldValue,String fullNameListRaw) {
        Response response;
        try {
            String errors = service.addDependencyWorldListPicklistValue(controllingFieldValue,fullNameListRaw);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response deleteWorldListPicklistValue(String fullNameToDelete) {
        Response response;
        try {
            String errors = service.deleteWorldListPicklistValue(fullNameToDelete);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response editWorldListPicklistValues(String fullName, String label) {
        Response response;
        try {
            String errors = service.editWorldListPicklistValues(fullName,label);
            if (String.isNotBlank(errors)) {
                response = new Response(errors);    
            } else {
                response = new Response(true);   
            }
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response retrieveDefaultAddonsForBaseProduct(String controllingName) {
        Response response;
        try {
            List<String> defaultAddons = service.retrieveDefaultAddonsForBaseProduct(controllingName);
            response = new Response(defaultAddons);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response retrieveBaseProductsRestrictOptions() {
        Response response;
        try {
            Map<String,List<String>> restrictOptionsMap = service.retrieveBaseProductsRestrictOptions();
            response = new Response(restrictOptionsMap);
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response retrieveDynamicAddonsForBaseProduct(String controllingName) {
        Response response;
        try {
            List<String> dynamicAddons = service.retrieveDynamicAddonsForBaseProduct(controllingName);
            response = new Response(dynamicAddons);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response retrieveDefaultNumberOfUsersForBaseProduct(String controllingName) {
        Response response;
        try {
            Integer numOfUsers = service.retrieveDefaultNumberOfUsersForBaseProduct(controllingName);
            response = new Response(numOfUsers);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response setDefaultAddonsForBaseProduct(String fullNameListRaw, String controllingName) {
        Response response;
        try {
            service.setDefaultAddonsForBaseProduct(fullNameListRaw,controllingName);
            response = new Response(true);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response setDynamicAddonsForBaseProduct(String fullNameListRaw, String controllingName) {
        Response response;
        try {
            service.setDynamicAddonsForBaseProduct(fullNameListRaw,controllingName);
            response = new Response(true);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Response setDefaultNumberOfUsersForBaseProduct(Integer numberOfUsers, String controllingName) {
        Response response;
        try {
            service.setDefaultNumberOfUsersForBaseProduct(numberOfUsers,controllingName);
            response = new Response(true);   
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

}
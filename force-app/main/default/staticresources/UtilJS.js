function confirmCancel() {
    var isCancel = confirm("Are you sure you wish to cancel?");
    if (isCancel) return true;

    return false;
}


/**
 * The method marks the fields as required. If the field is not filled, a custom alert will appear.
 * Defines the field type and visibility, for further marking the field as required.
 *
 * @param {String} fieldName
 * @param {Boolean} isMandatory
 * @param {String} selector
 */
function setFieldAsMandatoryRequired(fieldName, isMandatory, selector){
    console.log('@@@ fieldName isMandatory ', fieldName, isMandatory);
    if (!selector) {
        selector = 'data-field-name';
    }
    const certificateIdSpanList = document.querySelectorAll('[' + selector + '=' + fieldName + ']');
    if(certificateIdSpanList != undefined && certificateIdSpanList.length > 0){
        const certificateIdSelectEl = certificateIdSpanList[0];
        let parent = certificateIdSelectEl.parentNode;
        let inputField;
        if (parent.getElementsByTagName('select').length > 0) {
            inputField = parent.getElementsByTagName('select')[0];
        } else if(parent.getElementsByTagName('input').length > 0) {
            inputField = parent.getElementsByTagName('input')[0];
        } else if(parent.getElementsByTagName('textarea').length > 0) {
            inputField = parent.getElementsByTagName('textarea')[0];
        }
        if(!inputField){
            return;
        }
        const isVisible = checkIfFieldIsVisible(inputField);
        if(isVisible){
            if (isMandatory) {
                markFieldAsRequired(inputField);
            } else {
                markFieldAsNotRequired(inputField);
            }
        }
    }
}

/**
 * Checks the visibility for a field
 *
 * @param {Node} mandatoryField
 */
function checkIfFieldIsVisible(mandatoryField){
    let quoteNameTr = mandatoryField.closest("tr");
    let quoteNameLabel = quoteNameTr.querySelectorAll("th.labelCol");
    let style = quoteNameLabel[0].style.display;
    if(style === "none"){
        return false;
    } else {
        return true;
    }
}

/**
 * Creates a Required Block around the element.
 *
 * @param {Node} spanElement
 */
function markFieldAsRequired(spanElement){
    let parent = spanElement.parentNode;
    const requiredInputArr = spanElement.parentNode.querySelectorAll('div.requiredInput');
    if (!requiredInputArr || requiredInputArr.length < 1) {
        let inputNodeArr = obtainElementByTagName(spanElement);

        if (!inputNodeArr || inputNodeArr.length < 1) {
            return;
        }
        let inputNode = inputNodeArr[0];
        parent.removeChild(inputNode);
        let requiredInput = document.createElement("div");
        requiredInput.classList.add('requiredInput');
        let requiredBlock = document.createElement("div");
        requiredBlock.classList.add('requiredBlock');
        requiredInput.appendChild(requiredBlock);
        inputNode.setAttribute("is-mandatory","true");
        requiredInput.appendChild(inputNode);
        parent.appendChild(requiredInput);
        let childList = parent.childNodes;
        let garbageChild;
        for (const child of childList) {
            if(child.nodeName == '#text'){
                garbageChild = child;
            }
        }
        if(garbageChild){
            parent.removeChild(garbageChild);
        }
    }
}

/**
 * Get element from parent Node by tag name.
 *
 * @param {Node} node
 */
function obtainElementByTagName(node){
    let tagNameList = ['input','select','textarea'];
    let inputNodeArr;
    for(tagName of tagNameList){
        inputNodeArr = node.parentNode.getElementsByTagName(tagName);
        if (inputNodeArr && inputNodeArr.length > 0) {
            break;
        }
    }
    return inputNodeArr;
}


/**
 * Remove the Required Block around the element.
 *
 * @param {Node} spanElement
 */
function markFieldAsNotRequired(spanElement){
    let parent = spanElement.parentNode;
    let requiredInputArr = spanElement.parentNode.getElementsByTagName('div');
    if (!requiredInputArr || requiredInputArr.length < 1) {
        return;
    }
    let requiredInput = requiredInputArr[0];
    let inputNodeArr = obtainElementByTagName(spanElement);
    if (inputNodeArr && inputNodeArr.length > 0) {
        let inputNode = inputNodeArr[0];
        inputNode.setAttribute("is-mandatory","false");
        inputNode.classList.remove('requiredBlock');
        parent.removeChild(requiredInput);
        parent.appendChild(inputNode);
    }
}

/**
 * Key custom validation to check that all required fields are filled in is triggered by the NEXT button.
 */
function checkIfMandatoryFieldsBlank(){
    const mandatroySpanList = document.querySelectorAll('[is-mandatory=true]');
    let blankFields = [];
    for(let mandatoryField of mandatroySpanList){
        const fieldValue = mandatoryField.value;
        if(!fieldValue){
            blankFields = getMandatoryFieldLabel(mandatoryField,blankFields);
        }
    }
    if(blankFields.length != 0){
        displayErrorMessage(blankFields);
        return true;
    } else {
        hideErrorMessageIfExists();
        return false;
    }
}

/**
 * Filling in an array with the names of required fields that are not filled.
 *
 * @param {Node} mandatoryField
 * @param {String[]} blankFields
 */
function getMandatoryFieldLabel(mandatoryField,blankFields){
    if(mandatoryField){
        let quoteNameTr = mandatoryField.closest("tr");
        let quoteNameLabels = quoteNameTr.querySelectorAll("th.labelCol");
        let baseNodeId = mandatoryField.id;
        for(const label of quoteNameLabels){
            let labelName = label.innerText;
            if(labelName != '' && !blankFields.includes(labelName) && label.nextSibling.innerHTML.includes(baseNodeId)){
                if(labelName.includes('*')){
                    labelName = labelName.replace('*','');
                }
                blankFields.push(labelName);
            }
        }
        return blankFields;
    }
}

/**
 * Displaying an error message depending on one of the cases
 * (Required fields are not filled, is wrong subsidiary, not relevant package, Trial quote with Sales - Pro package)
 *
 * @param {String[]} blankMandatoryFields
 * @param {Boolean} isUKSubsidiaryMessage (is wrong subsidiary)
 * @param {Boolean} isUnrelevantPackage
 * @param {Boolean} isSalesProTrial
 */
function displayErrorMessage(blankMandatoryFields, isUKSubsidiaryMessage, isUnrelevantPackage, isSalesProTrial){
    if(blankMandatoryFields == undefined){
        blankMandatoryFields = [];
    }

    if(isUKSubsidiaryMessage == undefined){
        isUKSubsidiaryMessage = false;
    }

    if(isUnrelevantPackage == undefined){
        isUnrelevantPackage = false;
    }

    if(isSalesProTrial == undefined){
        isSalesProTrial = false;
    }
    hideErrorMessageIfExists();
    const messageElementHtmlString = generateErrorMessage(blankMandatoryFields, isUKSubsidiaryMessage, isUnrelevantPackage, isSalesProTrial);
    const alertElement = createElementFromHTML(messageElementHtmlString);
    const propertyPageBlock = document.getElementById('quotePropertyContainer');
    let parentNode = propertyPageBlock.parentElement;
    parentNode.insertBefore(alertElement, propertyPageBlock);
}

/**
 * If an error alert is shown but the validation succeeds, hides the error alert.
 */
function hideErrorMessageIfExists(){
    let errorMessage = document.getElementById("custom-mandatory-error-message");
    if(errorMessage){
        errorMessage.remove();
    }
    //removePackageErrorMessage();//itzik
}

/**
 * Generates a message for an error alert, depending on the attributes entered.
 *
 * @param {String[]} blankMandatoryFields
 * @param {Boolean} isUKSubsidiaryMessage
 * @param {Boolean} isUnrelevantPackage
 * @param {Boolean} isSalesProTrial
 */
function generateErrorMessage(blankMandatoryFields, isUKSubsidiaryMessage, isUnrelevantPackage, isSalesProTrial){
    let messsageElement = "<div id=\"custom-mandatory-error-message\" class=\"msg-box msg-failure ltng-msg-box\">"+
        "<div class=\"msg-container\" style=\"display: block;\">"+
        "<div class=\"msg-content\">"+
        "<div class=\"header\">Error(s) occurred while submitting the page. The error details are:</div>"+
        "<div class=\"messageBody\" rendered=\"false\"></div>"+
        "<div class=\"message\" rendered=\"true\">"+
        "<ul role=\"alert\">";
    if(isUKSubsidiaryMessage == true){
        messsageElement += "<li>Please contact billing to switch this customer from Similarweb UK Ltd to Similarweb Germany GmbH after you send the required notification letter to your customer. You can contact billing for the template of the notification letter if you do not have a copy of this</li>";
    }
    if(isUnrelevantPackage == true){
        messsageElement += "<li>We are no longer selling the requested products</li>";
    }
    if(isSalesProTrial == true){
        messsageElement += "<li>If you are providing a Trial, please select the package: Sales Intelligence Pro - Trial</li>";
    }
    if(blankMandatoryFields.length > 0){
        for(const blankFieldLabel of blankMandatoryFields){
            messsageElement += "<li>" + blankFieldLabel + ": You must enter a value</li>";
        }
    }
    messsageElement +=                "</ul>"+
        "</div>"+
        "</div>"+
        "<div class=\"msg-actions\" style=\"display: block\"></div>"+
        "</div>"+
        "</div>";
    return messsageElement;
}

/**
 * Converts a string to an html element
 *
 * @param {String} htmlString
 */
function createElementFromHTML(htmlString){
    let div = document.createElement('div');
    div.innerHTML = htmlString.trim();
    return div.firstChild;
}

/**
 * Specifies the type of the field and changes the visibility on the page.
 *
 * @param {String} dataFieldNameString
 * @param {Boolean} isDisplayed
 * @param {String} saveValue
 * @param {Boolean} hidePartially
 * @param {String} selector
 */
function changeDisplayOfFieldUtil(dataFieldNameString , isDisplayed, saveValue,hidePartially,selector){
    if(!selector){
        selector = 'data-field-name';
    }
    var spanList = document.querySelectorAll('[' + selector + '='+ dataFieldNameString + ']');
    if(spanList != undefined &&  spanList.length > 0){
        var selectedSpan = spanList[0];
        var parent = selectedSpan.parentNode;
        var inputField;
        if (parent.getElementsByTagName('select').length > 0) {
            inputField = parent.getElementsByTagName('select')[0];
        } else if(parent.getElementsByTagName('input').length > 0) {
            inputField = parent.getElementsByTagName('input')[0];
        } else if(parent.getElementsByTagName('textarea').length > 0) {
            inputField = parent.getElementsByTagName('textarea')[0];
        }
        if(!inputField){
            return;
        }
        if(isDisplayed){
            if (!inputField.multiple) {
                inputField.style.display='inline-block';
            }
            var tdNode = selectedSpan;
            do {
                tdNode = tdNode.parentNode;
            } while (tdNode.tagName.toLowerCase() != 'td');
            var trNode = tdNode.parentNode;
            var indexOfTdNode = Array.from(trNode.childNodes).indexOf(tdNode);
            if (indexOfTdNode > 0) {
                var indexOfThNode = indexOfTdNode - 1;
                if (!hidePartially) {
                    trNode.childNodes[indexOfTdNode].style.display='';
                    trNode.childNodes[indexOfThNode].style.display='';
                } else {
                    trNode.childNodes[indexOfThNode].childNodes[0].style.display='';
                }
            }
        }
        else {
            if (!saveValue) {
                if (inputField.tagName.toLowerCase() == 'span' && inputField.classList.contains('dateOnlyInput')) {
                    inputField.childNodes[0].value = '';
                } else if (inputField.tagName.toLowerCase() == 'input' && inputField.type == 'checkbox') {
                    inputField.removeAttribute('checked');
                } else  {
                    inputField.value='';
                }
            }
            inputField.style.display='none';
            //selectedSpan.parentNode.parentNode.childNodes[Array.from(selectedSpan.parentNode.parentNode.childNodes).indexOf(selectedSpan.parentNode) - 1].childNodes[0].style.display='none';
            var tdNode = selectedSpan;
            do {
                tdNode = tdNode.parentNode;
            } while (tdNode.tagName.toLowerCase() != 'td');
            var trNode = tdNode.parentNode;
            var indexOfTdNode = Array.from(trNode.childNodes).indexOf(tdNode);
            if (indexOfTdNode > 0) {
                var indexOfThNode = indexOfTdNode - 1;
                if (!hidePartially) {
                    trNode.childNodes[indexOfTdNode].style.display='none';
                    trNode.childNodes[indexOfThNode].style.display='none';
                } else {
                    trNode.childNodes[indexOfThNode].childNodes[0].style.display='none';
                }
            }
        }
    }
}
var isWrongSubsidiary;
let defaultNextOnClickFunction;
let packagesForValidationLine;
let isNewSaleQuote;

/**
 * Overwriting the Next button to trigger custom validation.
 *
 * @param {Function} nextButtonClickEdit - If its a Details page.
 * @param {Boolean} isWrongSubsidiaryCountry
 * @param {String} packagesForValidation
 * @param {Boolean} isNewSale
 */
function onClickNextButton(nextButtonClickEdit, isWrongSubsidiaryCountry, packagesForValidation, isNewSale){
    let spanList = document.querySelectorAll('[data-id=saveButton]');
    if (spanList && spanList.length > 0 && (spanList[0].innerText.toLowerCase() == 'next' || spanList[0].innerText.toLowerCase() == 'save')) {
        defaultNextOnClickFunction = spanList[0].onclick;
        if(isNewSale){
            isNewSaleQuote = true;
        }
        if(nextButtonClickEdit != undefined){
            spanList[0].onclick = nextButtonClickEdit;
            isWrongSubsidiary = isWrongSubsidiaryCountry;
        } else {
            spanList[0].onclick = nextButtonClick;
            isWrongSubsidiary = isWrongSubsidiaryCountry;
        }
        packagesForValidationLine = packagesForValidation;
    }
}

/**
 * Redefined logic for the Next button. Stops the original event and starts custom logic.
 */
function nextButtonClick(){
    event.stopImmediatePropagation(); // in order to prevent default Zuora "Submit" button logic
    nextButtonClickAction();
}

/**
 * If the Additional services field exists, fires a function to listen for field changes.
 */
function clearHiddenAdditionalServicesFields(){
    let additionalServicesSpanList = document.querySelectorAll('[data-field-name=Additional_services_requested__c]');
    if(additionalServicesSpanList != undefined &&  additionalServicesSpanList.length > 0){
        listenAdditionalServicesUtil(additionalServicesSpanList,false);
    }
}

/**
 * Run all validations and if all fields are valid, then run the standard package logic for the Next button.
 */
function nextButtonClickAction(){
    const isFieldsBlank = checkIfMandatoryFieldsBlank();
    const isUKSubsidiary = checkIfSubsidiaryIsUK();
    const isUnrelevantPackage = checkIfUnrelevantPackage();
    const ifSalesProTrial = checkIfSalesProTrial();
    if(isFieldsBlank == false && isUKSubsidiary == false && isUnrelevantPackage == false && ifSalesProTrial == false){
        clearHiddenAdditionalServicesFields();
        defaultNextOnClickFunction();
    }
}

/**
 * @author Itzik Winograd
 * @date 07/04/2022
 * @description checks if there is a ".msg-failure" element - if an error appears.
 * @returns {boolean}
 */
function removePackageErrorMessage(){
    let element = document.querySelector('.msg-failure');
    if (element){
        element.remove();
        return true;
    }
    return false;
}

/**
 * Displays an alert with an error if the Subsidiary attribute is not valid.
 */
function checkIfSubsidiaryIsUK(){
    if(isWrongSubsidiary == true){
        let blankMandatoryFields = [];
        displayErrorMessage(blankMandatoryFields,true);
        return true;
    } else {
        return false;
    }
}

/**
 * If the current package is included in the list of non-valid packages, then an error is displayed.
 */
function checkIfUnrelevantPackage(){
    let unrelevantPackages = packagesForValidationLine;
    if(unrelevantPackages == undefined){
        return false;
    }

    let migrationCheckboxSpanList = document.querySelectorAll('[data-field-name=Migrating_to_New_Soultion__c]');
    let migrationCheckbox = getQuoteFieldValueNewUtil(migrationCheckboxSpanList);

    let quoteBusinessTypeSpanList = document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]');
    let quoteBusinessTypeValue = getQuoteFieldValueNewUtil(quoteBusinessTypeSpanList);

    let packageSpanList = document.querySelectorAll('[data-field-name=package__c]');
    let packageValue = getQuoteFieldValueNewUtil(packageSpanList);

    let validationResponse = false
    if(migrationCheckbox != undefined && quoteBusinessTypeValue != undefined && packageValue != undefined){
        if(
            migrationCheckbox != 'Yes' &&
            quoteBusinessTypeValue != 'Co-Term Upsell' &&
            unrelevantPackages.includes(packageValue)
        ){
            let blankMandatoryFields = [];
            displayErrorMessage(blankMandatoryFields,false,true);
            validationResponse = true;
        }
    }


    return validationResponse;
}

/**
 * If the quote is trial and the package is equal to "Sales - Pro", then an error is displayed in the custom alert.
 */
function checkIfSalesProTrial(){
    let packageSpanList = document.querySelectorAll('[data-field-name=package__c]');
    let packageValue;
    if(packageSpanList != undefined && packageSpanList.length > 0){
        packageValue = getQuoteFieldValueNewUtil(packageSpanList);
    }
    let trialSpanList = document.querySelectorAll('[data-field-name=Trial_Quote__c]');
    let trialValue;
    if(trialSpanList != undefined && trialSpanList.length > 0){
        trialValue = trialSpanList[0].previousElementSibling.checked;
    }

    let validationResponse = false;
    if(isNewSaleQuote && trialValue === true && packageValue === 'Sales - Pro'){
        validationResponse = true;
        displayErrorMessage(undefined, undefined, undefined, true);
    }
    return validationResponse;
}

/**
 * Overriding the standard functionality for the Cancel button.
 */
function onClickCancelButton(){
    let spanList = document.querySelectorAll('[data-id=cancelButton]');

    if (spanList && spanList.length > 0 && spanList[0].innerText.toLowerCase() == 'cancel') {
        spanList[0].onclick = cancelButtonClick;
    }
}
/**
 * Stop the standard event for the Cancel button and start custom logic.
 */
function cancelButtonClick(){
    event.stopImmediatePropagation();
    cancelButtonClickAction();
}

/**
 * Display a modal window asking you to confirm the action.
 */
function cancelButtonClickAction(){
    const popupElement =
        "<span>"+
        "<span class=\"popup-overlay\"></span>"+
        "<div class=\"config-box ltng-msg-box\">"+
        "<div class=\"msg-container\" style=\"display: block;\">"+
        "<div class=\"msg-content\">"+
        "<div class=\"header\">Warning</div>"+
        "<div class=\"messageBody\" rendered=\"false\"></div>"+
        "<div class=\"message\" rendered=\"true\">"+
        "<ul role=\"alert\"><li>Are you sure you want to cancel? This action will delete the quote you are currently creating.</li></ul></div></div><div class=\"msg-actions\" style=\"display: none\">"+
        "<span onclick=\"hidePopupNotification(); displayStatusModal(); doCancel()\""+
        "class=\"btn\">Yes</span><span onclick=\"hidePopupNotification(); initRenewalSetting();\""+
        "class=\"btn\">No</span></div></div><div class=\"actionBox\">"+
        "<span onclick=\"hidePopupNotification(); initRenewalSetting();\" class=\"btn remainAction\">No</span>"+
        "<span onclick=\"hidePopupNotification(); displayStatusModal(); doCancel()\" class=\"btn cancelAction\">Yes</span></div></div>"+
        "</span>";

    const alertElement = createElementFromHTML(popupElement);
    const propertyPageBlock = document.getElementById('quotePropertyContainer');
    let parentNode = propertyPageBlock.parentElement;
    parentNode.insertBefore(alertElement, propertyPageBlock);
}

/**
 * function to enable/disable for editing
 * Renewal Payment Type
 * Renewal Payment Frequency
 * Renewal Initial Term
 * Based on the Quote Business Type equals to
 *    Co-Term Upsell + Renewal
 * OR Feature Update + Renewal (with/without upsell)
 * @param {string} selectValue - Quote business type
 * @param {number} initialTerm - default value of Initial Term
 * @param {string} amendmentRenewalPaymentFrequency - default value of Payment Frequency
 * @param {string} paymentType - default value of Payment Type
 */
function setFeatureCoTermRenewalFieldsEditableUtil(selectValue, initialTerm, amendmentRenewalPaymentFrequency, paymentType){
    const isCoTermRenewal = checkIfCoTermRenewal(selectValue);
    const isFeatureRenewal = checkIfFeatureRenewal(selectValue);

    if(isCoTermRenewal || isFeatureRenewal){
        setFieldAsEditableUtil('Amendment_Renewal_Payment_Type__c');
        setFieldAsEditableUtil('Amendment_Renewal_Payment_Frequency__c');
        setFieldAsEditableUtil('Amendment_Initial_Term__c');
    } else {
        if(initialTerm){
            setQuoteFieldNewUtil('Amendment_Initial_Term__c',initialTerm);
        }
        if(amendmentRenewalPaymentFrequency){
            setQuoteFieldNewUtil('Amendment_Renewal_Payment_Frequency__c',amendmentRenewalPaymentFrequency);
        }
        if(paymentType){
            setQuoteFieldNewUtil('Amendment_Renewal_Payment_Type__c',paymentType);
        }
    }
}

/**
 * function te enable/disable for editing
 * Payment Frequency
 * Payment Type
 * depending on the Quote Business Type equals to
 * Renewal (with/without upsell)
 * @param {string} selectValue
 * @param {string} paymentFrequency
 * @param {string} paymentType
 */
function setStraightRenewalFieldsEditableUtil(selectValue, paymentFrequency, paymentType){
    const isRenewal = checkIfRenewal(selectValue);
    if(isRenewal){
        setFieldAsEditableUtil('Payment_Type__c');
        setFieldAsEditableUtil('payment_frequency1__c');
    } else {
        if(paymentFrequency){
            setQuoteFieldNewUtil('payment_frequency1__c',paymentFrequency);
        }
        if(paymentType){
            setQuoteFieldNewUtil('Payment_Type__c',paymentType);
        }
    }
}

/**
 * Utility function to verify, that Quote Business Type is
 * Co-Term Upsell + Renewal
 * @param {String} quoteBusinessType
 */
function checkIfCoTermRenewal(quoteBusinessType){
    const CO_TERM_UPSELL_RENEWAL = 'Co-Term Upsell + Renewal';
    if(quoteBusinessType === CO_TERM_UPSELL_RENEWAL){
        return true;
    } else {
        return false;
    }
}

/**
 * Utility function to verify, that Quote Business Type is
 * Feature Update + Renewal (with/without upsell)
 * @param {String} quoteBusinessType
 */
function checkIfFeatureRenewal(quoteBusinessType){
    const FEATURE_UPDATE_RENEWAL = 'Feature Update + Renewal (with/without upsell)';
    if(quoteBusinessType === FEATURE_UPDATE_RENEWAL){
        return true;
    } else {
        return false;
    }
}

/**
 * Utility function to verify, that Quote Business Type is
 * Renewal (with/without upsell)
 * @param {String} quoteBusinessType
 */
function checkIfRenewal(quoteBusinessType){
    const RENEWAL = 'Renewal (with/without upsell)';
    if(quoteBusinessType === RENEWAL){
        return true;
    } else {
        return false;
    }
}

/**
 * Make the field editable.
 * @param {String} fieldName
 */
function setFieldAsEditableUtil(fieldName){
    var fieldNode = getQuoteFileNodeNewUtil(document.querySelectorAll("[data-field-name=" + fieldName + "]"));
    if (!fieldNode) {
        return;
    }
    var value = fieldNode.value;
    var parent = fieldNode.parentNode;
    fieldNode.style.display='inline-block';
    var spanElArr = parent.querySelectorAll('span[data-mode="readOnly"]');
    if (spanElArr && spanElArr.length>0) {
        spanElArr[0].style.display='none';
    }
}

/**
 * Set value for a field of any type.
 * @param {String} fieldName
 * @param {String} fieldValue
 * @param {String} selector
 */
function setQuoteFieldNewUtil(fieldName, fieldValue, selector){
    if (!selector) {
        selector = 'data-field-name';
    }
    var spanList = document.querySelectorAll('[' + selector + '=' + fieldName + ']');
    if (!spanList || spanList.length < 1) {
        return;
    }
    var parent = spanList[0].parentNode;
    var selectElArr = parent.getElementsByTagName('select');
    if (selectElArr && selectElArr.length > 0) {
        var selectEl = selectElArr[0];

        selectEl.value = fieldValue;
        selectEl.dispatchEvent(new Event('change'));
    } else {
        selectElArr = parent.getElementsByTagName('input');
        if (selectElArr && selectElArr.length > 0) {
            var selectEl = selectElArr[0];
            if (selectEl.type == 'checkbox') {
                selectEl.checked = fieldValue;
            } else {
                selectEl.value = fieldValue;
            }
        }
    }
}

/**
 * Get field node from SpanList.
 * @param {NodeList} spanList
 */
function getQuoteFileNodeNewUtil(spanList){
    var inputElArr = spanList[0].parentNode.getElementsByTagName('select');
    if (inputElArr && inputElArr.length > 0) {
        return inputElArr[0];
    }
    inputElArr = spanList[0].parentNode.getElementsByTagName('input');
    if (inputElArr && inputElArr.length > 0) {
        return inputElArr[0];
    }
    inputElArr = spanList[0].parentNode.getElementsByTagName('span');
    if (inputElArr && inputElArr.length > 0) {
        for (const inputEl_i of inputElArr) {
            if (inputEl_i.id) {
                return inputEl_i;
            }
        }
    }
}

/**
 * Get multipicklist field node from SpanList.
 * @param {NodeList} spanList
 */
function getQuoteFileNodeMultiPickListUtil(spanList){
    let inputElArr = spanList[0].parentNode.getElementsByTagName('select');
    let responseNode;
    if (inputElArr && inputElArr.length > 0) {
        for (const inputEl_i of inputElArr) {
            responseNode = inputEl_i;
        }
    }
    return responseNode;
}

/**
 * Util function for listening to multi picklist Additional_services_requested__c.
 * Controls the display of related text fields.
 * @param additionalServicesSpanList
 */
function listenAdditionalServicesUtil(additionalServicesSpanList,saveValue){
    let multiPicklistValues = getQuoteFileNodeMultiPickListUtil(additionalServicesSpanList);
    let additionalServices = [];
    for (const child_i of multiPicklistValues.childNodes) {
        additionalServices.push(child_i.innerText);
    }
    if(additionalServices.length < 1){
        return;
    }
    let additionalServicesMap = {dI_reporting_description__c: 'Advisory Services Description',Shopper_Intelligence_Categories__c:'Shopper Intelligence Categories',List_of_Stock_Intelligence_Tiers__c:'List of Stock Intelligence Tiers',List_of_Datasets__c:'List of Datasets'};
    for (let key in additionalServicesMap) {
        if(additionalServices.includes(additionalServicesMap[key]) || additionalServices[0].includes(additionalServicesMap[key])){
            changeDisplayOfFieldUtil(key,true,saveValue,false);
        } else {
            changeDisplayOfFieldUtil(key,false,saveValue,false);
        }
    }
}

/**
 * Utility function to align field in section to the right side
 * using additional empty clone of </th></td> tags
 * that representing the basic element
 * @param {Array[String]} fieldDataArr
 */
function alignElementToRightSideInRowUtil(fieldDataArr){
    const blankElementArray = [];
    for(const fieldData_i of fieldDataArr){
        let blankElement = fieldData_i.cloneNode(false);
        blankElementArray.push(blankElement);
    }
    return blankElementArray.concat(fieldDataArr);
}

/**
 * Utility function to wrap the element
 * by read-only node
 * @param {String} fieldName - API Name of the field
 */
function setFieldAsReadOnlyUtil(fieldName){
    var fieldNode = getQuoteFileNodeNewUtil(document.querySelectorAll("[data-field-name=" + fieldName + "]"));
    if (!fieldNode) {
        return;
    }
    var value = fieldNode.value;
    var parent = fieldNode.parentNode;
    fieldNode.style.display='none';
    var spanElArr = parent.querySelectorAll('span[data-mode="readOnly"]');
    if (spanElArr && spanElArr.length>0) {
        spanElArr[0].style.display='inline-block';
        spanElArr[0].innerHTML = value;
    } else {
        var spanEl = document.createElement('span');
        spanEl.innerHTML = value;
        spanEl.dataset.mode='readOnly';
        parent.appendChild(spanEl);
    }
}

/**
 * Utility function to adjust the display of the Special_Frequency_Reason__c field
 * @param {String} selectValue - Payment Frequency Picklist value
 */
function displayOrNotPaymentFrequencyPicklistUtil(selectValue){
    if (selectValue != undefined) {
        let quoteBusinessTypeSpanList = document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]');
        let quoteBusinessTypeSelectValue = getQuoteFieldValueNewUtil(quoteBusinessTypeSpanList);

        if(
            selectValue == 'Other'
            && quoteBusinessTypeSelectValue != 'Feature Update'
            && quoteBusinessTypeSelectValue != 'Co-Term Upsell'
            && quoteBusinessTypeSelectValue != ''
        ){
            changeDisplayOfFieldUtil('Special_Frequency_Reason__c',true,false,true);
            setFieldAsMandatoryRequired('Special_Frequency_Reason__c',true);
        } else {
            setFieldAsMandatoryRequired('Special_Frequency_Reason__c',false);
            changeDisplayOfFieldUtil('Special_Frequency_Reason__c',false,false,true);
        }
    }
}

/**
 * Utility function to adjust the display of the Special_Frequency_Reason_Amend__c field
 * @param {String} selectValue - Renewal Payment Frequency value
 */
function displayOrNotAmendPaymentFrequencyPicklistUtil(selectValue){
    if (selectValue != undefined) {
        let quoteBusinessTypeSpanList = document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]');
        let quoteBusinessTypeSelectValue = getQuoteFieldValueNewUtil(quoteBusinessTypeSpanList);

        if(
            selectValue == 'Other'
            && (quoteBusinessTypeSelectValue == 'Co-Term Upsell + Renewal'
                || quoteBusinessTypeSelectValue == 'Feature Update + Renewal (with/without upsell)')
        ){
            changeDisplayOfFieldUtil('Special_Frequency_Reason_Amend__c',true,false,true);
            setFieldAsMandatoryRequired('Special_Frequency_Reason_Amend__c',true);
        } else {
            setFieldAsMandatoryRequired('Special_Frequency_Reason_Amend__c',false);
            changeDisplayOfFieldUtil('Special_Frequency_Reason_Amend__c',false,false,true);
        }
    }
}

/**
 * Utility function to adjust the display of the Special_Payment_Terms_Details__c field
 * @param {String} selectValue - Payment Term Picklist value
 */
function displayOrNotPaymentTermPicklistUtil(selectValue){
    if (selectValue != undefined) {
        let quoteBusinessTypeSpanList = document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]');
        let quoteBusinessTypeSelectValue = getQuoteFieldValueNewUtil(quoteBusinessTypeSpanList);
        if(
            selectValue == 'Other (Non Standard)' &&
            quoteBusinessTypeSelectValue != 'Feature Update' &&
            quoteBusinessTypeSelectValue != 'Co-Term Upsell' &&
            quoteBusinessTypeSelectValue != ''
        ){
            changeDisplayOfFieldUtil('Special_Payment_Terms_Details__c',true,false,true);
            setFieldAsMandatoryRequired('Special_Payment_Terms_Details__c',true);
        } else {
            setFieldAsMandatoryRequired('Special_Payment_Terms_Details__c',false);
            changeDisplayOfFieldUtil('Special_Payment_Terms_Details__c',false,false,true);
        }
    }
}

/**
 * Utility function to retrive zqu__Quote__c field values
 * @param {Array} spanList - list of span
 * @returns - field value
 */
function getQuoteFieldValueNewUtil(spanList){
    var inputElArr = spanList[0].parentNode.getElementsByTagName('select');
    if (inputElArr && inputElArr.length > 0) {
        return inputElArr[0].value;
    }
    inputElArr = spanList[0].parentNode.getElementsByTagName('input');
    if (inputElArr && inputElArr.length > 0) {
        return inputElArr[0].value;
    }
    inputElArr = spanList[0].parentNode.getElementsByTagName('span');
    if (inputElArr && inputElArr.length > 0) {
        for (const inputEl_i of inputElArr) {
            if (inputEl_i.id) {
                return inputEl_i.innerText;
            }
        }
    }
}

/**
 * Get field value from SpanList
 * @param {NodeList} spanList
 */
function getQuoteFieldValueUtil(spanList){
    if(!spanList[0]){
        return;
    }
    if (spanList[0].parentNode.childNodes[0].tagName && spanList[0].parentNode.childNodes[0].tagName.toLowerCase() == 'span' && spanList[0].parentNode.childNodes[0].classList.contains('dateOnlyInput')) {
        return spanList[0].parentNode.childNodes[0].childNodes[0].value;
    } else if (spanList[0].parentNode.childNodes[0].tagName && spanList[0].parentNode.childNodes[0].tagName.toLowerCase() == 'input' && spanList[0].parentNode.childNodes[0].type == 'checkbox') {
        if (spanList[0].parentNode.childNodes[0].checked) {
            return spanList[0].parentNode.childNodes[0].checked;
        } else {
            return false;
        }
    } else if (spanList[0].parentNode.childNodes[0].tagName && spanList[0].parentNode.childNodes[0].tagName.toLowerCase() == 'select') {
        return spanList[0].parentNode.childNodes[0].value;
    } else {
        return '';
    }
}

/*
    Setting the PaymentTerm and JPY license fee fields if JP parent name was selected
*/
function setPaymentTermForJPparentUtil(selectValue,paymentTermNode,defaultPaymentTerm){
    if (
        selectValue == 'Gaprise Collections'
    ) {
        changeDisplayOfFieldUtil('JPY_license_fee__c',true,false,false);
        setFieldAsMandatoryRequired('JPY_license_fee__c',true);
    } else {
        setFieldAsMandatoryRequired('JPY_license_fee__c',false);
        changeDisplayOfFieldUtil('JPY_license_fee__c',false,false,false);
    }

    var paymentMethodSpanList = document.querySelectorAll('[data-field-name=zqu__PaymentMethod__c]');
    var paymentMethodValue = getQuoteFieldValueNewUtil(paymentMethodSpanList);

    var paymentTypeSpanList = document.querySelectorAll('[data-field-name=Payment_Type__c]');
    var paymentTypeValue = getQuoteFieldValueNewUtil(paymentTypeSpanList);


    if (
        (selectValue == 'Gaprise Collections' ||
            selectValue == 'Gaprise inc.') &&
        paymentMethodValue == 'Other'
    ) {
        setQuoteFieldNewUtil('Payment_Type__c','Wire Transfer');
        changeDisableOfFielUtil('Payment_Type__c',false);
    } else {
        setQuoteFieldNewUtil('Payment_Type__c',paymentTypeValue);
        changeDisableOfFielUtil('Payment_Type__c',true);
    }

    if (
        selectValue == 'SW Japan Direct Account' ||
        selectValue == 'Gaprise Direct Contract JPY' ||
        selectValue == 'SW Japan Direct Account JPY' ||
        selectValue == 'Gaprise Collections' ||
        selectValue == 'Gaprise Direct Contract USD'
    ) {
        hidePicklictOptionsUtil(paymentTermNode);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Due Upon Receipt',true);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Net 15',true);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Net 30',true);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Net 45',true);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Net 60',true);
        changePicklistOptionVisibilityUtil(paymentTermNode,'EOM + 30',selectValue == 'Gaprise Collections');
        if(defaultPaymentTerm == undefined){
            setQuoteFieldNewUtil('zqu__PaymentTerm__c','Due Upon Receipt');
        }
    } else if(selectValue == 'Gaprise inc.'){
        hidePicklictOptionsUtil(paymentTermNode);
        changePicklistOptionVisibilityUtil(paymentTermNode,'Net 30',true);
        if(defaultPaymentTerm == undefined){
            setQuoteFieldNewUtil('zqu__PaymentTerm__c','Net 30');
        }
    }
}

function changeDisableOfFielUtil(dataFieldNameString , isDisplayed){
    var spanList = document.querySelectorAll('[data-field-name='+ dataFieldNameString + ']');
    if(spanList != undefined &&  spanList.length > 0){
        var selectedSpan = spanList[0];
        var childList = selectedSpan.parentNode.getElementsByTagName('select');

        if(isDisplayed){
            if(childList != undefined &&  childList.length > 0){
                childList[0].disabled=false;
            }
        }
        else {
            if(childList != undefined &&  childList.length > 0){
                childList[0].disabled=true;
            }
        }
    }
}

function changeDisableOfFieldNewUtil(dataFieldNameString , isDisplayed){
    var spanList = document.querySelectorAll('[data-field-name='+ dataFieldNameString + ']');
    if(spanList != undefined &&  spanList.length > 0){
        var selectedSpan = spanList[0];
        var childList = selectedSpan.parentNode.childNodes;
    }
    if(isDisplayed){
        if(childList != undefined &&  childList.length > 0){
            childList[0].disabled=false;
        }
    }
    else {
        if(childList != undefined &&  childList.length > 0){
            childList[0].disabled=true;
        }
    }
}

/**
 * Checks all picklist values and hides them
 * @param {Node} picklistNode - Picklist node
 */
function hidePicklictOptionsUtil(picklistNode){
    if (!picklistNode) {
        return;
    }
    for (const child_i of picklistNode.childNodes) {
        if (child_i.style) {
            child_i.style.display='none';
        }
    }
}

/**
 * Hides or displays an option in the selected picklist
 * @param {Node} picklistNode - Picklist node
 * @param {String} valueApiName - Option name
 * @param {Boolean} isShown - Show \ hide
 */
function changePicklistOptionVisibilityUtil(picklistNode,valueApiName,isShown){
    if (!picklistNode) {
        return;
    }
    let valueIsExist = false;
    for (const child_i of picklistNode.childNodes) {
        if (child_i.innerText && child_i.innerText.toLowerCase() == valueApiName.toLowerCase()) {
            if (isShown) {
                child_i.style.display='block';
            } else {
                child_i.style.display='none';
            }
            valueIsExist = true;
        }
    }

    if(!valueIsExist && isShown){
        addPicklistValueUtil(picklistNode,valueApiName);
    }
}

/**
 * Defines the type of order for the Proposal Information section if the country is Japan
 * @param {String} selectValue - Selected value in the JP Parent Name picklist
 * @param {Boolean} isTrialQuote - The Quote is a trial
 */
function reorderProposalInfForGapriseCollectionsUtil(selectValue, isTrialQuote){
    if(
        selectValue == 'Gaprise Direct Contract JPY' ||
        selectValue == 'SW Japan Direct Account JPY' ||
        selectValue == 'Gaprise inc.' ||
        selectValue == 'Gaprise Collections'
    ){
        if(!isTrialQuote){
            reorderProposalInformationFieldsByJPParentNameUtil(true,true);
        }
    } else {
        if(!isTrialQuote){
            reorderProposalInformationFieldsByJPParentNameUtil(true,false);
        }
    }
}

/**
 * Change the order of information fields of a proposal by JP parent name
 * @param {String} isJPParentShow - JP parent name displayed on the page
 * @param {Boolean} isGapriseCollections - JP parent name is part of Gaprise Collections
 */
function reorderProposalInformationFieldsByJPParentNameUtil(isJPParentShow,isGapriseCollections){

    var proposalInfoSection = getQuoteSectionUtil('new_proposal_information');
    if (!proposalInfoSection) {
        return;
    }

    var fieldDataArrList = [];
    var trialQuoteFieldData = getQuoteFieldDataUtil('Trial_Quote__c');
    fieldDataArrList.push(trialQuoteFieldData);
    var quoteNameFieldData = getQuoteFieldDataUtil('Name');
    fieldDataArrList.push(quoteNameFieldData);

    var currencyFieldData = [];
    var url = window.location.href;
    if (url.includes('billingAccountId=')) {
        currencyFieldData = createDisabledCurrencyUtil();
        var originalCurrency = document.querySelectorAll('[data-id=customRenderedCurrency]')[0].parentNode;
        originalCurrency.style = "display: none";
        currencyFieldData.push(originalCurrency);
    } else {
        currencyFieldData.push(document.querySelectorAll('[data-id=customRenderedCurrency]')[0].parentNode);
    }
    fieldDataArrList.push(currencyFieldData);

    var s1 = findElementByContainingPharseUtil('label', 'text()', 'Bill to Contact');

    var billToContactFieldData = [];
    var billToTh;
    if(s1.parentNode.tagName == 'SPAN'){
        billToTh = s1.parentNode.parentNode;
    } else {
        billToTh = s1.parentNode;
    }

    billToContactFieldData.push(billToTh);
    billToContactFieldData.push(billToTh.nextSibling);
    console.log('Bill to contact ',billToContactFieldData);

    fieldDataArrList.push(billToContactFieldData);

    var s2 = findElementByContainingPharseUtil('label', 'text()', 'Admin User');



    var adminUserFieldData = [];
    var soldToTh;
    if(s2.parentNode.tagName == 'SPAN'){
        soldToTh = s2.parentNode.parentNode;
    } else {
        soldToTh = s2.parentNode;
    }
    adminUserFieldData.push(soldToTh);
    adminUserFieldData.push(soldToTh.nextSibling);
    console.log('Admin User ',adminUserFieldData);
    fieldDataArrList.push(adminUserFieldData);


    var legacyOrNewSolutionDealFieldData = getQuoteFieldDataUtil('Legacy_or_New_solution_deal__c');
    fieldDataArrList.push(legacyOrNewSolutionDealFieldData);
    var initialTermFieldData = getQuoteFieldDataUtil('zqu__InitialTerm__c');
    fieldDataArrList.push(initialTermFieldData);
    var productTypeFieldData = getQuoteFieldDataUtil('New_solution_use_case__c');
    fieldDataArrList.push(productTypeFieldData);
    var renewalTermFieldData = getQuoteFieldDataUtil('zqu__RenewalTerm__c');
    fieldDataArrList.push(renewalTermFieldData);
    var packageFieldData = getQuoteFieldDataUtil('package__c');
    fieldDataArrList.push(packageFieldData);
    var trialPeriodFieldData = getQuoteFieldDataUtil('Trial_Length__c');
    fieldDataArrList.push(trialPeriodFieldData);
    var documentLangFieldData = getQuoteFieldDataUtil('document_language__c');
    fieldDataArrList.push(documentLangFieldData);
    let multiSubscriptionFieldData = getQuoteFieldDataUtil('MultiSubscription__c');
    fieldDataArrList.push(multiSubscriptionFieldData);
    let parentBillingAccount = getQuoteFieldDataUtil('Zuora_Parent_Billing_Account__c');
    fieldDataArrList.push(parentBillingAccount);
    var definePaymentTermFieldData = getQuoteFieldDataUtil('Add_Finance_Information__c');
    fieldDataArrList.push(definePaymentTermFieldData);
    var productCapailityFieldData = getQuoteFieldDataUtil('Product_Compatibility__c');
    fieldDataArrList.push(productCapailityFieldData);
    var jpParentName = getQuoteFieldDataUtil('JP_Parent_Name__c');
    fieldDataArrList.push(jpParentName);
    var licenseFee = getQuoteFieldDataUtil('JPY_license_fee__c');
    fieldDataArrList.push(licenseFee);

    var invoiceOwnerNode = [];
    invoiceOwnerNode.push(document.querySelector('[data-id=customRenderedInvoiceOwner]'));

    removeClassFromFieldDataArrList(fieldDataArrList,'last');
    removeClassFromFieldDataArrList(fieldDataArrList,'first');
    var tbodyEl;
    var tbodyTagList = proposalInfoSection.getElementsByTagName('tbody');
    if (tbodyTagList && tbodyTagList.length > 0) {
        tbodyEl = tbodyTagList[0];
    } else {
        return;
    }
    console.log('tbodyEl', tbodyEl);
    removeAllChildFromNodeUtil(tbodyEl);

    if(isJPParentShow){
        var tr1 = document.createElement('tr');
        appenArrayOfChild(tr1,quoteNameFieldData);
        appenArrayOfChild(tr1,initialTermFieldData);
        addClassToNodes(quoteNameFieldData, 'first');
        addClassToNodes(initialTermFieldData, 'first');
        var tr2 = document.createElement('tr');
        appenArrayOfChild(tr2,legacyOrNewSolutionDealFieldData);
        appenArrayOfChild(tr2,renewalTermFieldData);
        var tr3 = document.createElement('tr');
        appenArrayOfChild(tr3,productTypeFieldData);
        appenArrayOfChild(tr3,billToContactFieldData);
        var tr4 = document.createElement('tr');
        appenArrayOfChild(tr4,packageFieldData);
        appenArrayOfChild(tr4,adminUserFieldData);
        var tr5 = document.createElement('tr');
        appenArrayOfChild(tr5,documentLangFieldData);
        appenArrayOfChild(tr5,jpParentName);
        if (url.includes('billingAccountId=')) {
            if(isGapriseCollections){
                var tr6 = document.createElement('tr');
                let empty1 = [];
                empty1.push(document.createElement('th'));
                empty1.push(document.createElement('td'));
                appenArrayOfChild(tr6,empty1);
                appenArrayOfChild(tr6,licenseFee);
                var tr7 = document.createElement('tr');
                let empty = [];
                empty.push(document.createElement('th'));
                empty.push(document.createElement('td'));
                appenArrayOfChild(tr7,empty);
                appenArrayOfChild(tr7,currencyFieldData);
                var tr8 = document.createElement('tr');
                let empty2 = [];
                empty2.push(document.createElement('th'));
                empty2.push(document.createElement('td'));
                appenArrayOfChild(tr8,empty2);
                appenArrayOfChild(tr8,definePaymentTermFieldData);
                var tr9 = document.createElement('tr');
                let empty3 = [];
                empty3.push(document.createElement('th'));
                empty3.push(document.createElement('td'));
                appenArrayOfChild(tr9,empty3);
                appenArrayOfChild(tr9,trialQuoteFieldData);
                addClassToNodes(trialQuoteFieldData, 'last');
            } else {
                var tr6 = document.createElement('tr');
                let empty = [];
                empty.push(document.createElement('th'));
                empty.push(document.createElement('td'));
                appenArrayOfChild(tr6,multiSubscriptionFieldData);
                appenArrayOfChild(tr6,currencyFieldData);
                var tr7 = document.createElement('tr');
                let empty2 = [];
                empty2.push(document.createElement('th'));
                empty2.push(document.createElement('td'));
                appenArrayOfChild(tr7,empty2);
                appenArrayOfChild(tr7,definePaymentTermFieldData);
                var tr8 = document.createElement('tr');
                let empty3 = [];
                empty3.push(document.createElement('th'));
                empty3.push(document.createElement('td'));
                appenArrayOfChild(tr8,empty3);
                appenArrayOfChild(tr8,trialQuoteFieldData);
                addClassToNodes(trialQuoteFieldData, 'last');
                var tr9 = document.createElement('tr');
            }
        } else {
            if(isGapriseCollections){
                var tr6 = document.createElement('tr');
                appenArrayOfChild(tr6,trialQuoteFieldData);
                appenArrayOfChild(tr6,licenseFee);
                var tr7 = document.createElement('tr');
                let empty = [];
                empty.push(document.createElement('th'));
                empty.push(document.createElement('td'));
                appenArrayOfChild(tr7,multiSubscriptionFieldData);
                appenArrayOfChild(tr7,currencyFieldData);
                var tr8 = document.createElement('tr');
                let empty2 = [];
                empty2.push(document.createElement('th'));
                empty2.push(document.createElement('td'));
                appenArrayOfChild(tr8,parentBillingAccount);
                appenArrayOfChild(tr8,definePaymentTermFieldData);
                addClassToNodes(definePaymentTermFieldData, 'last');
                var tr9 = document.createElement('tr');
            } else {
                var tr6 = document.createElement('tr');
                appenArrayOfChild(tr6,trialQuoteFieldData);
                appenArrayOfChild(tr6,currencyFieldData);
                var tr7 = document.createElement('tr');
                let empty2 = [];
                empty2.push(document.createElement('th'));
                empty2.push(document.createElement('td'));
                appenArrayOfChild(tr7,multiSubscriptionFieldData);
                appenArrayOfChild(tr7,definePaymentTermFieldData);
                addClassToNodes(definePaymentTermFieldData, 'last');
                var tr8 = document.createElement('tr');
                appenArrayOfChild(tr8,parentBillingAccount);
                addClassToNodes(parentBillingAccount, 'last');
                var tr9 = document.createElement('tr');
            }
        }
        var trInvisible = document.createElement('tr');
        appenArrayOfChild(trInvisible,trialPeriodFieldData);
        appenArrayOfChild(trInvisible,productCapailityFieldData);
        appenArrayOfChild(trInvisible,invoiceOwnerNode);
        if ((url.includes('billingAccountId=') && !isGapriseCollections) || (!url.includes('billingAccountId=') && !isGapriseCollections)) {
            appenArrayOfChild(trInvisible,licenseFee);
        }


        //trInvisible.style = 'display:none;';
        tbodyEl.appendChild(tr1);
        tbodyEl.appendChild(tr2);
        tbodyEl.appendChild(tr3);
        tbodyEl.appendChild(tr4);
        tbodyEl.appendChild(tr5);
        tbodyEl.appendChild(tr6);
        tbodyEl.appendChild(tr7);
        tbodyEl.appendChild(tr8);
        tbodyEl.appendChild(tr9);
        tbodyEl.appendChild(trInvisible);
    } else {
        var tr1 = document.createElement('tr');
        appenArrayOfChild(tr1,quoteNameFieldData);
        appenArrayOfChild(tr1,initialTermFieldData);
        addClassToNodes(quoteNameFieldData, 'first');
        addClassToNodes(initialTermFieldData, 'first');
        var tr2 = document.createElement('tr');
        appenArrayOfChild(tr2,legacyOrNewSolutionDealFieldData);
        appenArrayOfChild(tr2,renewalTermFieldData);
        var tr3 = document.createElement('tr');
        appenArrayOfChild(tr3,productTypeFieldData);
        appenArrayOfChild(tr3,billToContactFieldData);
        var tr4 = document.createElement('tr');
        appenArrayOfChild(tr4,packageFieldData);
        appenArrayOfChild(tr4,adminUserFieldData);
        var tr5 = document.createElement('tr');
        appenArrayOfChild(tr5,documentLangFieldData);
        appenArrayOfChild(tr5,currencyFieldData);
        var tr6 = document.createElement('tr');
        appenArrayOfChild(tr6,trialQuoteFieldData);
        appenArrayOfChild(tr6,definePaymentTermFieldData);
        // addClassToNodes(trialQuoteFieldData, 'last');
        // addClassToNodes(definePaymentTermFieldData, 'last');
        var tr7 = document.createElement('tr');
        appenArrayOfChild(tr7,multiSubscriptionFieldData);
        appenArrayOfChild(tr7,parentBillingAccount);
        addClassToNodes(multiSubscriptionFieldData, 'last');
        addClassToNodes(parentBillingAccount, 'last');
        var trInvisible = document.createElement('tr');
        appenArrayOfChild(trInvisible,trialPeriodFieldData);
        appenArrayOfChild(trInvisible,productCapailityFieldData);
        appenArrayOfChild(trInvisible,invoiceOwnerNode);
        appenArrayOfChild(trInvisible,jpParentName);
        appenArrayOfChild(trInvisible,licenseFee);



        //trInvisible.style = 'display:none;';
        tbodyEl.appendChild(tr1);
        tbodyEl.appendChild(tr2);
        tbodyEl.appendChild(tr3);
        tbodyEl.appendChild(tr4);
        tbodyEl.appendChild(tr5);
        tbodyEl.appendChild(tr6);
        tbodyEl.appendChild(tr7);
        tbodyEl.appendChild(trInvisible);
    }

    function appenArrayOfChild(parentEl, childArray){
        console.log('childArray ', childArray);
        for (const child_i of childArray) {
            parentEl.appendChild(child_i);
        }
    }

    function removeClassFromFieldDataArrList(fieldDataArrList, className){
        for (const fieldDataArr_i of fieldDataArrList) {
            for (const fieldData_i of fieldDataArr_i) {
                if (fieldData_i.classList.contains(className)) {
                    fieldData_i.classList.remove(className);
                }
            }
        }
    }

    function addClassToNodes(fieldDataArr, className){
        for (const fieldData_i of fieldDataArr) {
            fieldData_i.classList.add(className);
        }
    }
}

/**
 * Getting value from the quota field
 * @param {String} fieldName - Field name
 */
function getQuoteFieldDataUtil(fieldName){
    var spanList = document.querySelectorAll('[data-field-name=' + fieldName + ']');
    if(spanList != undefined &&  spanList.length > 0){
        var tdNode = spanList[0].parentNode;
        var thNode;
        var indexOfTdNode = Array.from(tdNode.parentNode.childNodes).indexOf(tdNode);
        if (indexOfTdNode > 0) {
            var indexOfThNode = indexOfTdNode - 1;
            thNode = tdNode.parentNode.childNodes[indexOfThNode];
        }
        if (thNode && tdNode) {
            var quoteFieldData = [];
            quoteFieldData.push(thNode);
            quoteFieldData.push(tdNode);
            console.log('SUCCESS WITH ',fieldName,'. Data: ',quoteFieldData);
            return quoteFieldData;
        } else {
            console.log('FAIl WITH ',fieldName);
            return;
        }
    }
}

/**
 * Ð¡reates a disabled currency
 */
function createDisabledCurrencyUtil(){
    var currencyFieldData = [];
    var currencySelect = document.createElement('select');
    var option = document.createElement("option");
    let customerChild = document.querySelectorAll('[data-id=customRenderedCurrency]')[0].parentNode.childNodes[0].childNodes;
    option.text =  customerChild[customerChild.length - 1].innerText;
    currencySelect.add(option);
    currencySelect.classList.add('PICKLIST');
    currencySelect.classList.add('slds-input');
    currencySelect.classList.add('dataCol');
    currencySelect.style = 'height: 32px; width: 161.594px;';
    currencySelect.disabled = true;
    var currencySelectTh = document.createElement('th');
    var currencySelectTd = document.createElement('td');
    var header =  document.querySelectorAll('[data-id=customRenderedCurrency]')[0].parentNode.childNodes[0].childNodes[0].cloneNode(true);
    // var span = document.createElement('span');
    // span.setAttribute('data-id', 'customRenderedCurrency');
    header.style = 'padding: 0; float: right;'
    header.childNodes[0].style = 'margin: 0';
    currencySelectTh.appendChild(header);
    currencySelectTh.classList.add('labelCol');
    currencySelectTh.classList.add('vfLabelColTextWrap');
    currencySelectTd.appendChild(currencySelect);
    // currencySelectTd.appendChild(span);
    currencySelectTd.classList.add('dataCol');
    currencyFieldData.push(currencySelectTh);
    currencyFieldData.push(currencySelectTd);

    return currencyFieldData;
}

/**
 * Finds an element by phrase
 * @param {String} tagName - Name of tag to search
 * @param {String} targetOfSearch -  target of search
 * @param {String} phraseToSearch - Search phrase
 */
function findElementByContainingPharseUtil(tagName, targetOfSearch, phraseToSearch){
    var xpath = "//" + tagName + "[contains(" + targetOfSearch +",'"+ phraseToSearch +"')]";
    var matchingElement = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    return matchingElement;
}

/**
 * Finds a section by section name
 * @param {String} sectionName - section name
 */
function getQuoteSectionUtil(sectionName){
    var sectionDiv = document.querySelector('[data-section-name=' + sectionName + ']');
    if(sectionDiv != undefined ){
        return sectionDiv;
    }
    return;
}

/**
 * Removes all child from the selected node.
 * @param {Node} targetNode - node item
 */
function removeAllChildFromNodeUtil(targetNode){
    while (targetNode.firstChild) {
        targetNode.removeChild(targetNode.firstChild);
    }
}

/*
    Utility function that synchronizes the values in
    the "Amendment_Renewal_Payment_Term__c" picklist
    with the values in the "zqu__PaymentTerm__c" picklist
*/
function removeRenewalPaymentTermPicklistValues(){
    var paymentTermSpanList = document.querySelectorAll('[data-field-name=zqu__PaymentTerm__c]');
    var paymentTermNode = getQuoteFileNodeNewUtil(paymentTermSpanList);
    var renewalPaymentTermSpanList = document.querySelectorAll('[data-field-name=Amendment_Renewal_Payment_Term__c]');
    var renewalPaymentTermNode = getQuoteFileNodeNewUtil(renewalPaymentTermSpanList);
    hidePicklictOptionsUtil(renewalPaymentTermNode);
    for(var i = 0;i<paymentTermNode.length; i++){
        if(String(paymentTermNode[i].value).includes('Other')){
            changePicklistOptionVisibilityUtil(renewalPaymentTermNode,'Other (non - Standard)',true);
        } else if(paymentTermNode[i].style.display != 'none'){
            changePicklistOptionVisibilityUtil(renewalPaymentTermNode,String(paymentTermNode[i].value),true);
        }
    }
}

function picklistContainsValue(a, obj) {
    for (var j = 0; j < a.length; j++) {
        if (a[j].value === obj && a[j].style.display != 'none') {
            return true;
        }
    }
    return false;
}

function showPicklictOptionsUtil(picklistNode){
    if (!picklistNode) {
        return;
    }
    for (const child_i of picklistNode.childNodes) {
        if (child_i.style) {
            child_i.style.display='block';
        }
    }
}

function removePicklistValueUtil(picklistNode,valueApiName){
    if (!picklistNode) {
        return;
    }
    for (const child_i of picklistNode.childNodes) {
        if (child_i.innerText && child_i.innerText.toLowerCase() == valueApiName.toLowerCase()) {
            picklistNode.removeChild(child_i);
        }
    }
}

function removeInvalidPicklistValuesUtil(paymentTermPicklistNode,paymentTerm){
    let invalidValuesList = ['Net 120','Net 180','Net 50','Net 65','EOM + 40','EOM + 45'];
    removePicklistValueUtil(paymentTermPicklistNode,'--none--');
    for (const picklistValue_i of invalidValuesList) {
        if (picklistValue_i != paymentTerm) {
            removePicklistValueUtil(paymentTermPicklistNode,picklistValue_i);
        }
    }
}

function listenAdditionalServicesPicklistUtil(){
    let additionalServicesSpanList = document.querySelectorAll('[data-field-name=Additional_services_requested__c]');
    if(additionalServicesSpanList != undefined &&  additionalServicesSpanList.length > 0){
        let additionalServicesPicklistNode = getQuoteFileNodeNewUtil(additionalServicesSpanList);
        if (additionalServicesPicklistNode) {
            listenAdditionalServicesUtil(additionalServicesSpanList,true);
            additionalServicesPicklistNode.onchange = function(){
                listenAdditionalServicesUtil(additionalServicesSpanList,true);
            };
        }
    }
}

function setPaymentFrequencyPicklistValueUtil(specificBillingPeriod){
    var paymentMethodSpanList = document.querySelectorAll('[data-field-name=zqu__PaymentMethod__c]');
    var paymentMethodValue = getQuoteFieldValueNewUtil(paymentMethodSpanList);

    var paymentFrequencySpanList = document.querySelectorAll('[data-field-name=payment_frequency1__c]');
    var paymentFrequencyValue = getQuoteFieldValueNewUtil(paymentFrequencySpanList);

    if(
        specificBillingPeriod && paymentMethodValue != 'Wire Transfer'
    ){
        setQuoteFieldNewUtil('payment_frequency1__c',obtainPaymentFrequencyValue(specificBillingPeriod));
    } else {
        if(specificBillingPeriod || !paymentFrequencyValue){
            setQuoteFieldNewUtil('payment_frequency1__c','Annual');
        }
    }
}

function setAmendPaymentFrequencyPicklistValueUtil(specificBillingPeriod,quoteExist){
    var renewalPaymentMethodSpanList = document.querySelectorAll('[data-field-name=Amendment_Renewal_Payment_Method__c]');
    var renewalPaymentMethodValue = getQuoteFieldValueNewUtil(renewalPaymentMethodSpanList);
    if(
        specificBillingPeriod && renewalPaymentMethodValue != 'Wire Transfer'
    ){
        setQuoteFieldNewUtil('Amendment_Renewal_Payment_Frequency__c',obtainPaymentFrequencyValue(specificBillingPeriod));
    } else {
        if(!quoteExist){
            setQuoteFieldNewUtil('Amendment_Renewal_Payment_Frequency__c','Annual');
        }
    }
}

function obtainPaymentFrequencyValue(specificBillingPeriod){
    specificBillingPeriod = specificBillingPeriod.toString();
    let paymentFrequency = '';
    switch(specificBillingPeriod){
        case '12':
            paymentFrequency = 'Annual';
            break;
        case '6':
            paymentFrequency = 'Semi-Annual';
            break;
        case '3':
            paymentFrequency = 'Quarterly';
            break;
        case '24':
            paymentFrequency = 'Every 2 Years';
            break;
        case '36':
            paymentFrequency = 'Every 3 years';
            break;
        default:
            paymentFrequency = 'Other';
    }

    return paymentFrequency;
}

function displayOrNotRenewalConfirmationUtil(isCreatePage,subscriptionType){
    let isDisplayed = false;

    var quoteBusinessTypeSpanList = document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]');
    var paymentMethodSpanList = document.querySelectorAll('[data-field-name=zqu__PaymentMethod__c]');
    var paymentTypeSpanList =document.querySelectorAll('[data-field-name=Payment_Type__c]');

    if(
        (quoteBusinessTypeSpanList != undefined &&  quoteBusinessTypeSpanList.length > 0) &&
        (paymentMethodSpanList != undefined &&  paymentMethodSpanList.length > 0)
        // && (paymentTypeSpanList != undefined && paymentTypeSpanList.length > 0)
    ){
        var quoteBusinessTypeValue = getQuoteFieldValueNewUtil(quoteBusinessTypeSpanList);
        var paymentMethodValue = getQuoteFieldValueNewUtil(paymentMethodSpanList);
        if(
            quoteBusinessTypeValue == 'Renewal (with/without upsell)' &&
            paymentMethodValue == 'Other' &&
            (subscriptionType == 'Amend Subscription' || isCreatePage)
        ){
            isDisplayed = true;
        }
        if(paymentMethodValue == 'Other' && paymentTypeSpanList != undefined && paymentTypeSpanList.length > 0){
            var paymentType = getQuoteFieldValueNewUtil(paymentTypeSpanList);
            if(quoteBusinessTypeValue == 'Renewal (with/without upsell)' && paymentMethodValue == 'Other'  && paymentType == 'Credit Card'){
                isDisplayed = true;
            }
        }
        if(quoteBusinessTypeValue == 'Renewal (with/without upsell)' && paymentMethodValue == 'Credit Card'){
            isDisplayed = true;
        }
    }
    changeDisplayOfFieldUtil('Renewal_by_client_confirmation__c',isDisplayed,false,false);
}

function validateNewTermTotalUtil(newTermsTotal, currentTermsTotal, renewalByClientConfirmation, newTermsTotalEl){

    newTermsTotal = String(newTermsTotal).replace(',','');
    currentTermsTotal = currentTermsTotal.replace(',','');
    let percentageNewTermTotal = (Math.abs(Number(newTermsTotal) * 100 / Number(currentTermsTotal)-100));
    percentageNewTermTotal = Math.round((percentageNewTermTotal + Number.EPSILON) * 100) / 100;
    if (renewalByClientConfirmation && percentageNewTermTotal > 7) {
        showMessageUtil(newTermsTotalEl, 'warning', 'Renewal by client confirmation can only be done when the price stays the same or increases by up to 7%. <br>For any other price change, please go back to the quote details and uncheck the â€œRenewal by client confirmationâ€ box, and proceed with an amendment.', 'newTermTotalValidationMessage');
    } else {
        clearMessageUtil('newTermTotalValidationMessage');
    }
}

function showMessageUtil(el, mode, message, messageContainerId){
    var messageContainer = document.getElementById(messageContainerId);
    if (!messageContainer) {
        var messageContainer = document.createElement("div");
        messageContainer.id = messageContainerId;
    }
    messageContainer.innerHTML = message;
    if (mode == 'success') {
        messageContainer.setAttribute('style', 'color:green !important');
    } else if(mode == 'warning') {
        messageContainer.setAttribute('style', 'color:red !important');
    }
    var elParent = el.parentNode;
    elParent.insertBefore(messageContainer,el);
}

function clearMessageUtil(elementId){
    var messageContainer = document.getElementById(elementId);
    if (messageContainer) {
        messageContainer.remove();
    }
}

function onChangeNewTermTotalUtil(selectedValue){
    var newTermTotalSpanList = document.querySelectorAll('[data-field-name=Renewal_Fee__c]');

    var currentTermTotalSpanList = document.querySelectorAll('[data-field-name=Current_Contract_TCV__c]');
    var renewalByClientConfirmationSpanList = document.querySelectorAll('[data-field-name=Renewal_by_client_confirmation__c]');
    if (currentTermTotalSpanList != undefined && currentTermTotalSpanList.length > 0 &&
        renewalByClientConfirmationSpanList != undefined && renewalByClientConfirmationSpanList.length > 0 &&
        newTermTotalSpanList != undefined && newTermTotalSpanList.length > 0
    ) {
        var newTermTotalNode = getQuoteFileNodeNewUtil(newTermTotalSpanList);
        var currentTermTotal = getQuoteFieldValueNewUtil(currentTermTotalSpanList);
        var renewalByClientConfirmation = getQuoteFieldValueUtil(renewalByClientConfirmationSpanList);
        if (selectedValue) {
            validateNewTermTotalUtil(selectedValue, currentTermTotal, renewalByClientConfirmation, newTermTotalNode);
        } else {
            clearMessageUtil('newTermTotalValidationMessage');
        }
    }
}

function onChangeRenewalConfirmationUtil(selectedValue) {
    if (selectedValue) {
        changeDisableOfFielUtil('Payment_Type__c',false);
        changeDisableOfFielUtil('payment_frequency1__c', false);
        changeDisableOfFieldNewUtil('zqu__InitialTerm__c', false);
        changeDisableOfFieldNewUtil('zqu__RenewalTerm__c', false);
        changeDisableOfFielUtil('zqu__PaymentTerm__c', false);
    } else {
        changeDisableOfFielUtil('Payment_Type__c', true);
        changeDisableOfFielUtil('payment_frequency1__c', true);
        changeDisableOfFieldNewUtil('zqu__InitialTerm__c', true);
        changeDisableOfFieldNewUtil('zqu__RenewalTerm__c', true);
        changeDisableOfFielUtil('zqu__PaymentTerm__c', true);
    }
    var newTermTotalSpanList = document.querySelectorAll('[data-field-name=Renewal_Fee__c]');
    if (newTermTotalSpanList != undefined && newTermTotalSpanList.length > 0){
        var newTermTotalValue = getQuoteFieldValueNewUtil(newTermTotalSpanList);
        onChangeNewTermTotalUtil(newTermTotalValue);
    }
}

function checkPackageAmendmentsByPackageUtil(isRenewal, isRenewalByClientConfirmation, isMigrationToNewSolution, packageAmendmentsByPackage) {
    var package = getQuoteFieldValueNewUtil(document.querySelectorAll('[data-field-name=package__c]'));
    var productType = getQuoteFieldValueNewUtil(document.querySelectorAll('[data-field-name=Product_Type_Amendment__c]'));
    var productTypeNode = getQuoteFileNodeNewUtil(document.querySelectorAll("[data-field-name=Product_Type_Amendment__c]"));
    var packageAmendmentNode = getQuoteFileNodeNewUtil(document.querySelectorAll("[data-field-name=Package_Amendment__c]"));
    if (isRenewal && isRenewalByClientConfirmation && isMigrationToNewSolution) {
        setProductTypeByPackageUtil(productTypeNode);
        if (packageAmendmentsByPackage && packageAmendmentsByPackage[package] && packageAmendmentsByPackage[package][productType]) {
            setPackageAmendmentsByPackageUtil(packageAmendmentNode, packageAmendmentsByPackage, package, productType);
            setQuoteFieldNewUtil('Pre_Approved_Migration__c', true);
        }
    } else {
        showPicklictOptionsUtil(productTypeNode);
        showPicklictOptionsUtil(packageAmendmentNode);
        setQuoteFieldNewUtil('Pre_Approved_Migration__c', false);
    }
}

function setProductTypeByPackageUtil(productTypeNode, packageAmendmentsByPackage, package) {
    showPicklictOptionsUtil(productTypeNode);
    hidePicklictOptionsUtil(productTypeNode);
    changePicklistOptionVisibilityUtil(productTypeNode, '--None--', true);
    changePicklistOptionVisibilityUtil(productTypeNode, 'Digital Suite', true);
}

function setPackageAmendmentsByPackageUtil(packageAmendmentNode, packageAmendmentsByPackage, package, productType){
    showPicklictOptionsUtil(packageAmendmentNode);
    hidePicklictOptionsUtil(packageAmendmentNode);
    changePicklistOptionVisibilityUtil(packageAmendmentNode, '--None--', true);
    for (const packageAmend_i of packageAmendmentsByPackage[package][productType]) {
        changePicklistOptionVisibilityUtil(packageAmendmentNode, packageAmend_i, true);
    }
}

function countPlacesUtil(num) {
    var text = num.toString();
    var index = text.indexOf(".");
    return index == -1 ? 0 : (text.length - index - 1);
}

function calcucateNewTermTotalByPercentageUtil(selectValue, eventTarget){
    if(selectValue != undefined && selectValue != ''){
        if(
            String(Number(selectValue)) != 'NaN' &&
            Number(selectValue) >= -100 && Number(selectValue) <=100 &&
            countPlacesUtil(selectValue) < 3
        ){
            var currentTermTotalSpanList = document.querySelectorAll('[data-field-name=Current_Contract_TCV__c]');
            var currentTermTotalValue = getQuoteFieldValueNewUtil(currentTermTotalSpanList);
            currentTermTotalValue = String(currentTermTotalValue).replace(',','');
            let newValue = Number(currentTermTotalValue) + (Number(currentTermTotalValue) * Number(selectValue)/100);
            setQuoteFieldNewUtil('Renewal_Fee__c',newValue);
            onChangeNewTermTotalUtil(String(newValue));
            clearMessageUtil('percentageTermTotalValidationMessage');
        } else {
            showMessageUtil(eventTarget, 'warning', 'Not valid', 'percentageTermTotalValidationMessage');
            setQuoteFieldNewUtil('Renewal_Fee__c','');
            clearMessageUtil('newTermTotalValidationMessage');
        }
    } else {
        clearMessageUtil('percentageTermTotalValidationMessage');
    }
}

function setPaymentFrequencyByInitialTerm(initialTerm, isAmendment){
    let paymentMethodValue;
    let paymentMethodSpanList;

    if(isAmendment){
        paymentMethodSpanList = document.querySelectorAll('[data-field-name=Amendment_Renewal_Payment_Method__c]');
    } else {
        paymentMethodSpanList = document.querySelectorAll('[data-field-name=zqu__PaymentMethod__c]');
    }

    if(paymentMethodSpanList != undefined &&  paymentMethodSpanList.length > 0){
        paymentMethodValue = getQuoteFieldValueNewUtil(paymentMethodSpanList);
    }

    if(initialTerm && (paymentMethodValue == 'Credit Card' || paymentMethodValue == 'Wire Transfer')){
        let paymentFrequencyValue = obtainPaymentFrequencyValue(initialTerm);
        if(isAmendment){
            setQuoteFieldNewUtil('Amendment_Renewal_Payment_Frequency__c',paymentFrequencyValue);
        } else {
            setQuoteFieldNewUtil('payment_frequency1__c',paymentFrequencyValue);
        }
    }
}

function addPicklistValueUtil(picklistNode,valueApiName){
    if (!picklistNode) {
        return;
    }
    for (const child_i of picklistNode.childNodes) {
        if (child_i.innerText && child_i.innerText.toLowerCase() == valueApiName.toLowerCase()) {
            return;
        }
    }
    let optionEl = document.createElement('option');
    optionEl.innerHTML=valueApiName;
    optionEl.value=valueApiName;
    picklistNode.appendChild(optionEl);
}

function populateRenewalPaymentTermUtil(selectValue,quoteExist,paymentTerm){
    const businessType = getQuoteFieldValueNew(document.querySelectorAll('[data-field-name=zqu__QuoteBusinessType__c]'));
    const isRenewalBusinessType = checkIfQBTisPlusRenewalUtil(businessType);
    if (
        selectValue != undefined &&
        selectValue != '' &&
        isRenewalBusinessType
    ) {
        if (selectValue == 'Credit Card'  || selectValue == 'PayPal') {
            setQuoteFieldNew('Amendment_Renewal_Payment_Term__c','Due Upon Receipt');
            changeDisableOfFieldNew('Amendment_Renewal_Payment_Term__c',false);
        } else {
            changeDisableOfFieldNew('Amendment_Renewal_Payment_Term__c',true);
            if(paymentTerm){
                setQuoteFieldNew('Amendment_Renewal_Payment_Term__c',paymentTerm);
            } else {
                setQuoteFieldNew('Amendment_Renewal_Payment_Term__c','Net 30');
            }
        }
        let specificBillingPeriod = "{!specificBillingPeriod}";
        setAmendPaymentFrequencyPicklistValueUtil(specificBillingPeriod,quoteExist);
        changeDisableOfFieldNew('Amendment_Renewal_Payment_Frequency__c',true);
    } else {
        setQuoteFieldNew('Amendment_Renewal_Payment_Term__c','');
    }
}

function checkIfQBTisPlusRenewalUtil(businessType){
    const CO_TERM_UPSELL_RENEWAL = 'Co-Term Upsell + Renewal';
    const FEATURE_UPDATE_RENEWAL = 'Feature Update + Renewal (with/without upsell)';

    const isCoTermRenewal = (businessType == CO_TERM_UPSELL_RENEWAL);
    const isFeatureRenewal = (businessType == FEATURE_UPDATE_RENEWAL);

    return isCoTermRenewal || isFeatureRenewal;
}

function populateGroupDescriptionUtil(groupDescription){
    if(groupDescription && groupDescription.length > 0){
        setQuoteFieldNewUtil('Group_Description__c', groupDescription);
    }
}